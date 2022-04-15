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
}

extension CurrentGame: CoordinatorDelegate {
    func didStartFetchingServersList(for coordinator: Coordinator) {
        
    }
    
    func didFinishFetchingServersList(for coordinator: Coordinator) {
        coordinator.fetchServersInfo()
    }
    
    func didFinishFetchingServersInfo(for coordinator: Coordinator) {
        isUpdating = false
    }
    
    func coordinator(_ coordinator: Coordinator, didFinishFetchingInfoFor server: Server) {
        DispatchQueue.main.async {
            self.servers.append(server)
        }
    }
    
    func coordinator(_ coordinator: Coordinator, didFinishFetchingStatusFor server: Server) {
        
    }
    
    func coordinator(_ coordinator: Coordinator, didFailWith error: GSQLError) {
        print(error.localizedDescription)
    }
}
