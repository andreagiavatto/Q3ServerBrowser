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
    @State private var selectedGame: SupportedGames = .quake3

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(
                gameViewModel: gameViewModel,
                supportedGames: supportedGames,
                selectedGame: $selectedGame
            )
            .frame(minWidth: 260, idealWidth: 280, maxWidth: 300)
        } content: {
            ServersView(gameViewModel: gameViewModel)
                .frame(minWidth: 680, idealWidth: 720)
        } detail: {
            ServerDetailsView(gameViewModel: gameViewModel)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: refreshList) {
                    Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                }
                .keyboardShortcut("r", modifiers: .command)
                .help("Refresh server list (⌘R)")
            }
        }
        .navigationTitle("Q3ServerBrowser")
        .navigationSubtitle(Text("\(gameViewModel.servers.count) servers"))
    }

    private func refreshList() {
        Task {
            await gameViewModel.refreshCurrentList()
        }
    }
}
