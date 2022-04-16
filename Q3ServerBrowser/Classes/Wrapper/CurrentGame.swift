//
//  CurrentGame.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import Combine
import GameServerQueryLibrary

final class CurrentGame: NSObject, ObservableObject {
    private let game: Game
    private var coordinator: Coordinator
    private var filter: String?
    private var showFull: Bool = true
    private var showEmpty: Bool = false
    private var lastFetchedServers: [Server] = []
    
    @Published var currentMasterServer: MasterServer?
    @Published var servers: [Server] = []
    @Published var isUpdating: Bool = false
    
    var masterServers: [MasterServer] {
        game.masterServers
    }

    init(type: SupportedGames) {
        game = Game(type: type)
        coordinator = game.coordinator
        super.init()
        coordinator.delegate = self
    }
    
    func updateMasterServer(_ masterServer: MasterServer?) {
        guard let masterServer = masterServer else {
            return
        }
        currentMasterServer = masterServer
        servers = []
        isUpdating = true
        coordinator.getServersList(host: masterServer.hostname, port: masterServer.port)
    }
    
    func refreshCurrentList() {
        guard let currentMasterServer = currentMasterServer else {
            return
        }
        servers = []
        isUpdating = true
        coordinator.getServersList(host: currentMasterServer.hostname, port: currentMasterServer.port)
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
        server.hostname.localizedCaseInsensitiveContains(text)
    }
    
    private func isFull(server: Server) -> Bool {
        Int(server.currentPlayers) == Int(server.maxPlayers)
    }
    
    private func isEmpty(server: Server) -> Bool {
        Int(server.currentPlayers) == 0
    }
}

extension CurrentGame: CoordinatorDelegate {
    func didStartFetchingServersList(for coordinator: Coordinator) {
        
    }
    
    func didFinishFetchingServersList(for coordinator: Coordinator) {
        coordinator.fetchServersInfo()
    }
    
    func didFinishFetchingServersInfo(for coordinator: Coordinator) {
        DispatchQueue.main.async {
            self.isUpdating = false
        }
    }
    
    func coordinator(_ coordinator: Coordinator, didFinishFetchingInfoFor server: Server) {
        DispatchQueue.main.async {
            self.lastFetchedServers.append(server)
            if self.satisfiesAllCurrentFilterCriteria(server: server) {
                self.servers.append(server)
            }
        }
    }
    
    func coordinator(_ coordinator: Coordinator, didFinishFetchingStatusFor server: Server) {
        
    }
    
    func coordinator(_ coordinator: Coordinator, didFailWith error: GSQLError) {
        print(error.localizedDescription)
    }
}
