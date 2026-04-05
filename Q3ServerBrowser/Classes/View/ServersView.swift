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
        ZStack {
            Table(selection: $gameViewModel.currentSelectedServer, sortOrder: $sortOrder) {
                TableColumn("Name", value: \.name)
                    .width(min: 250)

                TableColumn("Map", value: \.map)
                    .width(100)

                TableColumn("Mod", value: \.mod)
                    .width(70)

                TableColumn("Gametype", value: \.gametype)
                    .width(70)

                TableColumn("Players", value: \.inGamePlayers)
                    .width(55)

                TableColumn("Ping", value: \.ping)
                    .width(50)

                TableColumn("Ip Address", value: \.hostname)
                    .width(150)
            } rows: {
                ForEach(gameViewModel.servers) { server in
                    TableRow(server)
                        .contextMenu {
                            Button {
                                copyToClipBoard(textToCopy: server.hostname)
                            } label: {
                                Label("Copy hostname to ClipBoard", systemImage: "doc.on.doc")
                            }
                        }
                }
            }
            .opacity(gameViewModel.isUpdating ? 0.4 : 1.0)

            if gameViewModel.isUpdating {
                ProgressView("Fetching servers…")
                    .progressViewStyle(.circular)
            }
        }
        .tableStyle(.inset)
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
    
    private func copyToClipBoard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
}

