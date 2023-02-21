//
//  GameViewModel.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import Combine
import GameServerQueryLibrary

final class GameViewModel: NSObject, ObservableObject {
    private let game: Game
    private var coordinator: Coordinator
    private var filter: String?
    private var showFull: Bool = true
    private var showEmpty: Bool = true
    private var lastFetchedServers: [Server] = []
    private var cancellables = Set<AnyCancellable>()
        
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
        super.init()
        setupObservers()
    }
    
    func server(by id: Server.ID?) -> Server? {
        guard let id = id else {
            return nil
        }
        return servers.first { $0.id == id }
    }
    
    func updateMasterServer(_ masterServer: MasterServer?) {
        guard let masterServer = masterServer else {
            return
        }
        currentMasterServer = masterServer
        currentSelectedServer = nil
        isUpdating = true
        startUpdatingMasterServerList(for: masterServer)
    }
    
    func refreshCurrentList() {
        guard let currentMasterServer = currentMasterServer else {
            return
        }
        servers = []
        currentSelectedServer = nil
        isUpdating = true
        startUpdatingMasterServerList(for: currentMasterServer)
    }
    
    func updateFullServersVisibility(allowFullServers: Bool) {
        showFull = allowFullServers
        filter(with: filter)
    }
    
    func updateEmptyServersVisibility(allowEmptyServers: Bool) {
        showEmpty = allowEmptyServers
        filter(with: filter)
    }
    
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
            return
        }
        Task {
            let updatedServer = await coordinator.updateServerStatus(server)
            await MainActor.run {
                self.currentSelectedServer = updatedServer
            }
        }
    }
    
    private func startUpdatingMasterServerList(for masterServer: MasterServer) {
        Task {
            do {
                try await coordinator.getServersList(ip: masterServer.hostname, port: masterServer.port)
                await MainActor.run {
                    self.isUpdating = false
                }
            } catch {
                print(">>> Error updating master server list \(error.localizedDescription)")
                await MainActor.run {
                    self.isUpdating = false
                }
            }
        }
    }
    
    private func setupObservers() {
        coordinator.servers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] servers in
                guard let self else {
                    return
                }
                self.lastFetchedServers = servers
                print(">>> Showing \(servers.count) servers")
                self.filter(with: self.filter)
            }
            .store(in: &cancellables)
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
