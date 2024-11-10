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
    private let game: Game
    private var coordinator: Coordinator
    private var filter: String?
    private var showFull: Bool = true
    private var showEmpty: Bool = true
    private var lastFetchedServers: [Server] = []
        
    @MainActor @Published private(set) var currentMasterServer: MasterServer?
    @MainActor @Published var servers: [Server] = []
    @MainActor @Published private(set) var isUpdating: Bool = false
    @MainActor @Published var currentSelectedServer: Server.ID?
    
    var masterServers: [MasterServer] {
        game.masterServers
    }

    init(type: SupportedGames) {
        game = Game(type: type)
        coordinator = game.coordinator
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
    func filter(with text: String?) {
        guard let text = text, !text.isEmpty else {
            filter = nil
            servers = lastFetchedServers.filter({ [weak self] server in
                return self?.satisfiesAllCurrentFilterCriteria(server: server) ?? false
            })
            return
        }

        self.filter = text
        self.servers = self.lastFetchedServers.filter({ [weak self] server in
            return self?.satisfiesAllCurrentFilterCriteria(server: server) ?? false
        })
    }
    
    @MainActor
    func updateServerStatus(_ server: Server) async {
        do {
            let updatedServer = try await coordinator.updateServerStatus(server)
            await replaceServerInList(with: updatedServer)
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
    private func replaceServerInList(with server: Server) {
        guard let index = servers.firstIndex(where: { $0 == server }) else {
            return
        }
        servers[index] = server
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
