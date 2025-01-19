//
//  MainView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct MainView: View {
    let supportedGames: [SupportedGames]

    @StateObject private var gameViewModel = GameViewModel(type: .quake3)
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var showFull: Bool = true
    @State private var showEmpty: Bool = true
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(gameViewModel: gameViewModel)
                .frame(minWidth: 300, idealWidth: 400)
        } content: {
            ServersView(gameViewModel: gameViewModel)
                .frame(minWidth: 740, idealWidth: 750)
        } detail: {
            ServerDetailsView(gameViewModel: gameViewModel)
        }
        .toolbar {
            Button(action: refreshList) {
                Label("Refresh List", systemImage: "arrow.triangle.2.circlepath")
            }
            
            Toggle(isOn: $showFull) {
                Text("Show Full")
            }
            .toggleStyle(CheckboxToggleStyle())
            .onChange(of: showFull) { newValue in
                gameViewModel.updateFullServersVisibility(allowFullServers: newValue)
            }
            
            Toggle(isOn: $showEmpty) {
                Text("Show Empty")
            }
            .toggleStyle(CheckboxToggleStyle())
            .onChange(of: showEmpty) { newValue in
                gameViewModel.updateEmptyServersVisibility(allowEmptyServers: newValue)
            }
        }
        .navigationTitle("Q3ServerBrowser")
        .navigationSubtitle(Text("\(gameViewModel.servers.count) servers found"))
    }
    
    func refreshList() {
        Task {
            await gameViewModel.refreshCurrentList()
        }
    }
}
