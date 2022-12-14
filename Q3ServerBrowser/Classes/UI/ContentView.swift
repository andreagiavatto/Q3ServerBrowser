//
//  ContentView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct ContentView: View {
    @EnvironmentObject var game: CurrentGame
    @State private var selectedServer: Server.ID?
    
    var body: some View {
        NavigationView {
            Sidebar()
            NavigationView {
                ServersView(selectedServer: $selectedServer)
                    .frame(minWidth: 850, idealWidth: 900, minHeight: 500, idealHeight: 850)
                    .onChange(of: selectedServer) { newSelectedServer in
                        let server = game.server(by: newSelectedServer)
                        game.updateServerStatus(server)
                    }
                ServerDetailsView(selectedServer: $game.currentSelectedServer)
                    .frame(minWidth: 300, idealWidth: 300, maxWidth: 300)
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
}
