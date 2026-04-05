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
    private var filter: String?
    private var showFull: Bool = true
    private var showEmpty: Bool = true
    private var lastFetchedServers: [Server] = []
    private var currentSortOrder: [KeyPathComparator<Server>] = []
        
    @MainActor @Published private(set) var currentMasterServer: MasterServer?
    @MainActor @Published var servers: [Server] = []
    @MainActor @Published private(set) var isUpdating: Bool = false
    @MainActor @Published var currentSelectedServer: Server.ID?
    
    var masterServers: [MasterServer] {
        game.masterServers
    }

    init(type: SupportedGames) {
        // Construct Game once and reuse it for the coordinator so we never
        // accidentally create two different coordinator instances.
        let newGame = Game(type: type)
        game = newGame
        coordinator = newGame.coordinator
    }

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
        filter = nil
    }
    
    @MainActor
    func server(by id: Server.ID?) -> Server? {
        guard let id else {
            return nil
        }
        return servers.first { $0.id == id }
    }
    
    @MainActor
    func updateMasterServer(_ masterServer: MasterServer) async {
        currentMasterServer = masterServer
        currentSelectedServer = nil
        isUpdating = true
        await startUpdatingMasterServerList(for: masterServer)
    }
    
    @MainActor
    func refreshCurrentList() async {
        guard let currentMasterServer = currentMasterServer else {
            return
        }
        servers = []
        currentSelectedServer = nil
        isUpdating = true
        await startUpdatingMasterServerList(for: currentMasterServer)
    }
    
    @MainActor
    func updateFullServersVisibility(allowFullServers: Bool) {
        showFull = allowFullServers
        filter(with: filter)
    }
    
    @MainActor
    func updateEmptyServersVisibility(allowEmptyServers: Bool) {
        showEmpty = allowEmptyServers
        filter(with: filter)
    }
    
    @MainActor
    func sort(using comparators: [KeyPathComparator<Server>]) {
        currentSortOrder = comparators
        servers.sort(using: comparators)
    }

    @MainActor
    func filter(with text: String?) {
        guard let text = text, !text.isEmpty else {
            filter = nil
            servers = lastFetchedServers.filter { satisfiesAllCurrentFilterCriteria(server: $0) }
            if !currentSortOrder.isEmpty { servers.sort(using: currentSortOrder) }
            return
        }

        self.filter = text
        self.servers = self.lastFetchedServers.filter { satisfiesAllCurrentFilterCriteria(server: $0) }
        if !currentSortOrder.isEmpty { servers.sort(using: currentSortOrder) }
    }
    
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
    
    @MainActor
    private func startUpdatingMasterServerList(for masterServer: MasterServer) async {
        do {
            self.lastFetchedServers.removeAll()
            let servers = try await coordinator.getServersList(ip: masterServer.hostname, port: masterServer.port)
            
            let serverUpdateStream = await coordinator.fetchServersInfo(for: servers)
            for try await updatedServer in serverUpdateStream {
                let statusServer = try await coordinator.updateServerStatus(updatedServer)
                await self.addServerToList(statusServer)
                await self.filter(with: self.filter)
            }
            await MainActor.run {
                self.isUpdating = false
            }
        } catch {
            NLog.error(error)
            await MainActor.run {
                self.isUpdating = false
            }
        }
    }
    
    @MainActor
    private func addServerToList(_ server: Server) {
        lastFetchedServers.append(server)
    }
    
    private func satisfiesAllCurrentFilterCriteria(server: Server) -> Bool {
        if !showFull, isFull(server: server) {
            return false
        }
        if !showEmpty, isEmpty(server: server) {
            return false
        }
        return isIncludedInFilter(server: server)
    }
    
    private func isIncludedInFilter(server: Server) -> Bool {
        guard let text = filter else {
            return true
        }
        return server.name.localizedCaseInsensitiveContains(text) ||
        server.mod.localizedCaseInsensitiveContains(text) ||
        server.gametype.localizedCaseInsensitiveContains(text) ||
        server.hostname.localizedCaseInsensitiveContains(text) ||
        server.players.contains(where: { player in
            player.name.localizedCaseInsensitiveContains(text)
        })
    }
    
    private func isFull(server: Server) -> Bool {
        Int(server.currentPlayers) == Int(server.maxPlayers)
    }
    
    private func isEmpty(server: Server) -> Bool {
        Int(server.currentPlayers) == 0
    }
}
