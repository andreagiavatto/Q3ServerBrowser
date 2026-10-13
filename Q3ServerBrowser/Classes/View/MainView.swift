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

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(gameViewModel: gameViewModel, supportedGames: supportedGames)
                .navigationSplitViewColumnWidth(min: 200, ideal: 230, max: 300)
        } content: {
            ServersView(gameViewModel: gameViewModel)
                .navigationSplitViewColumnWidth(min: 560, ideal: 760)
        } detail: {
            ServerDetailsView(gameViewModel: gameViewModel)
                .navigationSplitViewColumnWidth(min: 320, ideal: 360)
        }
        .toolbar {
            ToolbarItemGroup {
                filterMenu

                Button(action: refreshList) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
                .help("Refresh server list (⌘R)")
                .disabled(gameViewModel.currentMasterServer == nil || gameViewModel.isUpdating)
            }
        }
        .navigationTitle(gameViewModel.currentMasterServer?.hostname ?? "Q3ServerBrowser")
        .navigationSubtitle(subtitle)
    }

    // MARK: - Toolbar

    private var filterMenu: some View {
        Menu {
            Toggle("Hide Empty Servers", isOn: $gameViewModel.hideEmpty)
            Toggle("Hide Full Servers", isOn: $gameViewModel.hideFull)
            Toggle("Hide Password-Protected Servers", isOn: $gameViewModel.hideLocked)
            Divider()
            Toggle("Hide Ping Over \(PingThreshold.critical) ms", isOn: $gameViewModel.hideHighPing)
        } label: {
            Label("Filters",
                  systemImage: gameViewModel.hasActiveFilters
                    ? "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease.circle")
        }
        .help("Filter servers")
    }

    private var subtitle: String {
        guard gameViewModel.currentMasterServer != nil else { return "" }
        let shown = gameViewModel.servers.count
        let total = gameViewModel.totalServerCount
        return shown == total ? "\(total) servers" : "\(shown) of \(total) servers"
    }

    private func refreshList() {
        Task {
            await gameViewModel.refreshCurrentList()
        }
    }
}
