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
    private var currentSortOrder: [KeyPathComparator<Server>] = []

    // MARK: - Published state

    @MainActor @Published private(set) var currentMasterServer: MasterServer?
    @MainActor @Published var servers: [Server] = []
    @MainActor @Published private(set) var isUpdating: Bool = false
    @MainActor @Published var currentSelectedServer: Server.ID?

    /// Whether to include servers that have reached their maximum player count.
    /// Promoted to @Published so the Sidebar can observe and toggle it directly.
    @MainActor @Published private(set) var showFull: Bool = true

    /// Whether to include servers with zero players.
    /// Promoted to @Published so the Sidebar can observe and toggle it directly.
    @MainActor @Published private(set) var showEmpty: Bool = true

    /// Maps each MasterServer's `id` to the raw server count it returned.
    /// Updated as soon as `getServersList` responds; used by the Sidebar for count badges.
    @MainActor @Published private(set) var masterServerResults: [String: Int] = [:]

    /// The time the most recent full refresh completed (both `isUpdating` transitions to `false`).
    @MainActor @Published private(set) var lastRefreshed: Date?

    var masterServers: [MasterServer] {
        game.masterServers
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
        currentSortOrder = []
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
    func updateFullServersVisibility(allowFullServers: Bool) {
        showFull = allowFullServers
        filter(with: filterText)
    }

    @MainActor
    func updateEmptyServersVisibility(allowEmptyServers: Bool) {
        showEmpty = allowEmptyServers
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
        if !showFull, isFull(server: server) { return false }
        if !showEmpty, isEmpty(server: server) { return false }
        return isIncludedInFilter(server: server)
    }

    private func isIncludedInFilter(server: Server) -> Bool {
        guard let text = filterText else { return true }
        return server.name.localizedCaseInsensitiveContains(text)
            || server.mod.localizedCaseInsensitiveContains(text)
            || server.gametype.localizedCaseInsensitiveContains(text)
            || server.hostname.localizedCaseInsensitiveContains(text)
            || server.players.contains { $0.name.localizedCaseInsensitiveContains(text) }
    }

    private func isFull(server: Server) -> Bool {
        Int(server.currentPlayers) == Int(server.maxPlayers)
    }

    private func isEmpty(server: Server) -> Bool {
        Int(server.currentPlayers) == 0
    }
}
