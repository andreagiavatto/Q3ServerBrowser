//
//  ServersView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 15/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct ServersView: View {
    @ObservedObject var gameViewModel: GameViewModel

    @State private var searchText: String = ""
    @State private var sortOrder = GameViewModel.defaultSortOrder

    var body: some View {
        Group {
            if gameViewModel.currentMasterServer == nil {
                ContentUnavailableView(
                    "Select a Master Server",
                    systemImage: "server.rack",
                    description: Text("Choose a master server from the sidebar to browse its game servers.")
                )
            } else {
                // Servers stream in while refreshing, so the table stays fully visible;
                // an overlay is only shown while there is nothing to list yet.
                serverTable
                    .overlay {
                        if gameViewModel.servers.isEmpty {
                            if gameViewModel.isUpdating {
                                ProgressView("Fetching servers…")
                            } else {
                                ContentUnavailableView(
                                    "No Servers Found",
                                    systemImage: "magnifyingglass",
                                    description: Text("Try another master server or change the filters.")
                                )
                            }
                        }
                    }
            }
        }
        .searchable(text: $searchText, prompt: "Name, map, mod or player")
        .onChange(of: searchText) { _, newQuery in
            gameViewModel.filter(with: newQuery)
        }
        .onChange(of: sortOrder) { _, newOrder in
            gameViewModel.sort(using: newOrder)
        }
        .onChange(of: gameViewModel.currentSelectedServer) { _, newSelectedServer in
            Task {
                if let server = await gameViewModel.server(by: newSelectedServer) {
                    await gameViewModel.updateServerStatus(server)
                }
            }
        }
    }

    // MARK: - Table

    private var serverTable: some View {
        Table(selection: $gameViewModel.currentSelectedServer, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.displayName) { server in
                HStack(spacing: 4) {
                    Text(server.displayName)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if server.isPasswordProtected {
                        Image(systemName: "lock.fill")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                            .help("Password protected")
                    }
                }
                .foregroundStyle(server.rowStyle)
            }
            .width(min: 200, ideal: 320)

            TableColumn("Players", value: \.currentPlayerCount) { server in
                PlayerCapacityView(server: server)
            }
            .width(min: 56, ideal: 64, max: 80)

            TableColumn("Ping", value: \.pingInt) { server in
                PingBadge(ping: server.pingInt)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .width(min: 40, ideal: 48, max: 64)

            TableColumn("Mode", value: \.modeLabel) { server in
                Text(server.modeLabel)
                    .foregroundStyle(server.rowStyle)
            }
            .width(min: 40, ideal: 52, max: 72)

            TableColumn("Map", value: \.map) { server in
                Text(server.map)
                    .lineLimit(1)
                    .foregroundStyle(server.rowStyle)
            }
            .width(min: 80, ideal: 130)

            TableColumn("Mod", value: \.displayMod) { server in
                Text(server.displayMod)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
            .width(min: 60, ideal: 100)
        } rows: {
            ForEach(gameViewModel.servers) { server in
                TableRow(server)
            }
        }
        .contextMenu(forSelectionType: Server.ID.self) { ids in
            if let id = ids.first, let server = gameViewModel.server(by: id) {
                Button("Connect") { connect(to: server) }
                Divider()
                Button("Copy Address") { Pasteboard.copy(server.hostname) }
                Button("Copy Connect Command") { Pasteboard.copy("/connect \(server.hostname)") }
                Divider()
                Button("Choose Game Application…") {
                    GameLauncher.chooseApplication(for: gameViewModel.currentGameType)
                }
            }
        } primaryAction: { ids in
            // Double-click (or Return) connects.
            if let id = ids.first, let server = gameViewModel.server(by: id) {
                connect(to: server)
            }
        }
        .tableStyle(.inset)
    }

    private func connect(to server: Server) {
        GameLauncher.connect(to: server, game: gameViewModel.currentGameType)
    }
}
