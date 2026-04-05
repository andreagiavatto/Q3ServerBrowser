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

    @State var searchText: String = ""
    @State private var sortOrder = [KeyPathComparator(\Server.name)]

    var body: some View {
        Group {
            if gameViewModel.currentMasterServer == nil {
                // Nothing selected yet — prompt the user
                ContentUnavailableView(
                    "Select a Master Server",
                    systemImage: "server.rack",
                    description: Text("Choose a master server from the sidebar to browse active game servers.")
                )
            } else {
                ZStack {
                    serverTable
                        .opacity(gameViewModel.isUpdating ? 0.45 : 1.0)

                    if gameViewModel.isUpdating {
                        ProgressView("Fetching servers…")
                            .progressViewStyle(.circular)
                    } else if gameViewModel.servers.isEmpty {
                        // Loaded, but nothing matched (or master returned nothing)
                        ContentUnavailableView(
                            "No Servers Found",
                            systemImage: "magnifyingglass",
                            description: Text("Try a different master server or adjust your filter settings.")
                        )
                    }
                }
            }
        }
        .searchable(text: $searchText)
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
            // Name column — status dot embedded in the leading edge of the cell
            TableColumn("Name", value: \.name) { server in
                HStack(spacing: 8) {
                    statusDot(for: server)
                    Text(server.name)
                        .font(.system(size: 13))
                        .lineLimit(1)
                }
            }
            .width(min: 210)

            // Players column — fill bar + numeric label
            TableColumn("Players", value: \.inGamePlayers) { server in
                PlayerCapacityView(current: server.currentPlayers, max: server.maxPlayers)
            }
            .width(78)

            // Ping column — colour-coded badge; sorts numerically via pingInt

            TableColumn("Ping", value: \.pingInt) { server in
                PingBadge(ping: server.ping)
            }
            .width(68)

            TableColumn("Gametype", value: \.gametype)
                .width(70)

            TableColumn("Map", value: \.map)
                .width(90)

            TableColumn("Mod", value: \.mod)
                .width(70)

            TableColumn("Address", value: \.hostname)
                .width(150)
        } rows: {
            ForEach(gameViewModel.servers) { server in
                TableRow(server)
                    .contextMenu {
                        Button {
                            copyToClipboard(server.hostname)
                        } label: {
                            Label("Copy Address", systemImage: "doc.on.doc")
                        }
                    }
            }
        }
        .tableStyle(.inset)
    }

    // MARK: - Helpers

    /// 6 pt circle: green (has players), red (full), secondary (empty / unknown).
    @ViewBuilder
    private func statusDot(for server: Server) -> some View {
        let current = Int(server.currentPlayers) ?? 0
        let max     = Int(server.maxPlayers)     ?? 0
        let colour: Color = {
            if current == 0                          { return .secondary }
            if max > 0 && current >= max             { return .red }
            return .green
        }()
        Circle()
            .fill(colour)
            .frame(width: 6, height: 6)
    }

    private func copyToClipboard(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
    }
}
