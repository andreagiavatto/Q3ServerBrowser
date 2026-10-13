//
//  Sidebar.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

/// One section per game, listing its master servers. Selecting a master from
/// another game switches game automatically.
struct Sidebar: View {
    @ObservedObject var gameViewModel: GameViewModel
    let supportedGames: [SupportedGames]

    @State private var selection: MasterServer.ID?

    var body: some View {
        List(selection: $selection) {
            ForEach(supportedGames, id: \.self) { gameType in
                let game = Game(type: gameType)
                Section(game.name) {
                    ForEach(game.masterServers) { masterServer in
                        masterServerRow(masterServer, defaultPort: game.defaultMasterServer.port)
                            .tag(masterServer.id)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            footer
        }
        .onChange(of: selection) { _, newSelection in
            select(newSelection)
        }
    }

    // MARK: - Rows

    private func masterServerRow(_ masterServer: MasterServer, defaultPort: String) -> some View {
        // Count badge appears once the master has responded (a zero badge is hidden).
        let count = gameViewModel.masterServerResults[masterServer.id] ?? 0
        let title = masterServer.port == defaultPort ? masterServer.hostname : masterServer.description
        return Text(title)
            .lineLimit(1)
            .truncationMode(.middle)
            .badge(count)
            .help(masterServer.description)
    }

    @ViewBuilder
    private var footer: some View {
        if gameViewModel.isUpdating || gameViewModel.lastRefreshed != nil {
            HStack(spacing: 6) {
                if gameViewModel.isUpdating {
                    ProgressView()
                        .controlSize(.small)
                    Text("Refreshing…")
                } else if let refreshed = gameViewModel.lastRefreshed {
                    Text("Updated \(refreshed, style: .time)")
                }
                Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Selection

    private func select(_ id: MasterServer.ID?) {
        guard let id else { return }
        for gameType in supportedGames {
            guard let masterServer = Game(type: gameType).masterServers.first(where: { $0.id == id }) else {
                continue
            }
            if gameType != gameViewModel.currentGameType {
                gameViewModel.switchGame(to: gameType)
            }
            Task { await gameViewModel.updateMasterServer(masterServer) }
            return
        }
    }
}
