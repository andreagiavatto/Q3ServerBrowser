//
//  ServerDetailsViewModel.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 16/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

class ServerDetailsViewModel: ObservableObject {
    @EnvironmentObject var game: CurrentGame
    @Published var server: Server?
    var selectedServer: Binding<Server.ID?>
    
    init(selectedServer: Binding<Server.ID?>) {
        self.selectedServer = selectedServer
        setupObservers()
    }
    
    private func setupObservers() {
        selectedServer.onChange(of: selectedServer) { newSelectedServer in
            if let server = server {
                game.updateServerStatus(server)
            }
        }
    }
    
    func updateServerStatus() {
        
    }
}
