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
        
    @Published var currentMasterServer: MasterServer?
    @Published var servers: [Server] = []
    @Published var isUpdating: Bool = false
    @Published var currentSelectedServer: Server?
    
    var masterServers: [MasterServer] {
        game.masterServers
    }

    init(type: SupportedGames) {
        game = Game(type: type)
        coordinator = game.coordinator
    }
    
    func server(by id: Server.ID?) -> Server? {
        guard let id = id else {
            return nil
        }
        return servers.first { $0.id == id }
    }
    
    @MainActor
    func updateMasterServer(_ masterServer: MasterServer?) {
        guard let masterServer = masterServer else {
            return
        }
        currentMasterServer = masterServer
        currentSelectedServer = nil
        isUpdating = true
        startUpdatingMasterServerList(for: masterServer)
    }
    
    @MainActor
    func refreshCurrentList() {
        guard let currentMasterServer = currentMasterServer else {
            return
        }
        servers = []
        currentSelectedServer = nil
        isUpdating = true
        startUpdatingMasterServerList(for: currentMasterServer)
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
    
    func updateServerStatus(_ server: Server?) {
        guard let server = server else {
            self.currentSelectedServer = nil
            return
        }
        Task {
            do {
                let updatedServer = try await coordinator.updateServerStatus(server)
                await MainActor.run {
                    self.currentSelectedServer = updatedServer
                }
            } catch {
                NLog.error(error)
            }
        }
    }
    
    private func startUpdatingMasterServerList(for masterServer: MasterServer) {
        Task {
            do {
                self.lastFetchedServers.removeAll()
                let servers = try await coordinator.getServersList(ip: masterServer.hostname, port: masterServer.port)

                let serverUpdateStream = coordinator.fetchServersInfo(for: servers, waitTimeInMilliseconds: 100)
                for await updatedServer in serverUpdateStream {
                    let statusServer = try await coordinator.updateServerStatus(updatedServer)
                    self.lastFetchedServers.append(statusServer)
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
