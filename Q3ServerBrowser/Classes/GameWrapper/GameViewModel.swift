//
//  GameViewModel.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import Combine
import GameServerQueryLibrary

final class GameViewModel: ObservableObject {
    private var game: Game
    private var coordinator: Coordinator
    private var filterText: String?
    private var lastFetchedServers: [Server] = []
    private var currentSortOrder: [KeyPathComparator<Server>] = GameViewModel.defaultSortOrder

    /// Busiest servers first.
    static var defaultSortOrder: [KeyPathComparator<Server>] {
        [KeyPathComparator(\Server.currentPlayerCount, order: .reverse)]
    }

    // MARK: - Published state

    @MainActor @Published private(set) var currentMasterServer: MasterServer?
    @MainActor @Published var servers: [Server] = []
    @MainActor @Published private(set) var isUpdating: Bool = false
    @MainActor @Published var currentSelectedServer: Server.ID?

    // Filters, toggled from the toolbar filter menu. Changing any of them re-applies the filter.
    @MainActor @Published var hideEmpty: Bool = false { didSet { applyFilters() } }
    @MainActor @Published var hideFull: Bool = false { didSet { applyFilters() } }
    @MainActor @Published var hideLocked: Bool = false { didSet { applyFilters() } }
    @MainActor @Published var hideHighPing: Bool = false { didSet { applyFilters() } }

    @MainActor var hasActiveFilters: Bool {
        hideEmpty || hideFull || hideLocked || hideHighPing
    }

    /// Maps each MasterServer's `id` to the raw server count it returned.
    /// Updated as soon as `getServersList` responds; used by the Sidebar for count badges.
    @MainActor @Published private(set) var masterServerResults: [String: Int] = [:]

    /// The time the most recent full refresh completed (both `isUpdating` transitions to `false`).
    @MainActor @Published private(set) var lastRefreshed: Date?

    var masterServers: [MasterServer] {
        game.masterServers
    }

    var currentGameType: SupportedGames {
        game.type
    }

    /// Number of servers fetched from the current master, before filtering.
    var totalServerCount: Int {
        lastFetchedServers.count
    }

    // MARK: - Init

    init(type: SupportedGames) {
        // Construct Game once and reuse it for the coordinator so we never
        // accidentally create two different coordinator instances.
        let newGame = Game(type: type)
        game = newGame
        coordinator = newGame.coordinator
    }

    // MARK: - Game switching

    @MainActor
    func switchGame(to type: SupportedGames) {
        // Both game and coordinator are updated from the same Game instance so
        // they are always in sync.
        let newGame = Game(type: type)
        game = newGame
        coordinator = newGame.coordinator
        servers = []
        lastFetchedServers = []
        currentSortOrder = GameViewModel.defaultSortOrder
        currentMasterServer = nil
        currentSelectedServer = nil
        filterText = nil
        masterServerResults = [:]
        lastRefreshed = nil
    }

    // MARK: - Server lookup

    @MainActor
    func server(by id: Server.ID?) -> Server? {
        guard let id else { return nil }
        return servers.first { $0.id == id }
    }

    // MARK: - Master server refresh

    @MainActor
    func updateMasterServer(_ masterServer: MasterServer) async {
        currentMasterServer = masterServer
        currentSelectedServer = nil
        isUpdating = true
        await startUpdatingMasterServerList(for: masterServer)
    }

    @MainActor
    func refreshCurrentList() async {
        guard let currentMasterServer = currentMasterServer else { return }
        servers = []
        currentSelectedServer = nil
        isUpdating = true
        await startUpdatingMasterServerList(for: currentMasterServer)
    }

    // MARK: - Filtering and sorting

    @MainActor
    private func applyFilters() {
        filter(with: filterText)
    }

    @MainActor
    func sort(using comparators: [KeyPathComparator<Server>]) {
        currentSortOrder = comparators
        servers.sort(using: comparators)
    }

    @MainActor
    func filter(with text: String?) {
        guard let text = text, !text.isEmpty else {
            filterText = nil
            servers = lastFetchedServers.filter { satisfiesAllCurrentFilterCriteria(server: $0) }
            if !currentSortOrder.isEmpty { servers.sort(using: currentSortOrder) }
            return
        }
        filterText = text
        servers = lastFetchedServers.filter { satisfiesAllCurrentFilterCriteria(server: $0) }
        if !currentSortOrder.isEmpty { servers.sort(using: currentSortOrder) }
    }

    // MARK: - Server status update

    @MainActor
    func updateServerStatus(_ server: Server) async {
        do {
            // Server is a value type — capture the returned updated copy and
            // write it back into both the visible list and the backing store so
            // that ping, players, and rules are actually persisted.
            let updated = try await coordinator.updateServerStatus(server)
            if let idx = servers.firstIndex(where: { $0.id == updated.id }) {
                servers[idx] = updated
            }
            if let idx = lastFetchedServers.firstIndex(where: { $0.id == updated.id }) {
                lastFetchedServers[idx] = updated
            }
        } catch {
            NLog.error(error)
        }
    }

    // MARK: - Private

    @MainActor
    private func startUpdatingMasterServerList(for masterServer: MasterServer) async {
        do {
            lastFetchedServers.removeAll()
            let rawServers = try await coordinator.getServersList(
                ip: masterServer.hostname, port: masterServer.port)

            // Record how many addresses the master returned immediately so the
            // sidebar badge appears before individual servers are queried.
            masterServerResults[masterServer.id] = rawServers.count

            let serverUpdateStream = await coordinator.fetchServersInfo(for: rawServers)
            for try await updatedServer in serverUpdateStream {
                let statusServer = try await coordinator.updateServerStatus(updatedServer)
                addServerToList(statusServer)
                filter(with: filterText)
            }
            isUpdating = false
            lastRefreshed = Date()
        } catch {
            NLog.error(error)
            isUpdating = false
        }
    }

    @MainActor
    private func addServerToList(_ server: Server) {
        lastFetchedServers.append(server)
    }

    @MainActor
    private func satisfiesAllCurrentFilterCriteria(server: Server) -> Bool {
        if hideFull, server.isFullServer { return false }
        if hideEmpty, server.isEmptyServer { return false }
        if hideLocked, server.isPasswordProtected { return false }
        if hideHighPing, server.pingInt >= PingThreshold.critical { return false }
        return isIncludedInFilter(server: server)
    }

    private func isIncludedInFilter(server: Server) -> Bool {
        guard let text = filterText else { return true }
        return server.displayName.localizedCaseInsensitiveContains(text)
            || server.map.localizedCaseInsensitiveContains(text)
            || server.mod.localizedCaseInsensitiveContains(text)
            || server.gametype.localizedCaseInsensitiveContains(text)
            || server.hostname.localizedCaseInsensitiveContains(text)
            || server.players.contains { $0.name.localizedCaseInsensitiveContains(text) }
    }
}
