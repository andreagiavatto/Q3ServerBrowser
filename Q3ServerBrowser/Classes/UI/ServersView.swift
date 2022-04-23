//
//  ServersView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 15/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct ServersView: View {
    @EnvironmentObject var game: CurrentGame
    @Binding var selectedServer: Server.ID?
    
    @State var searchText: String = ""
    @State var showFull: Bool = true
    @State var showEmpty: Bool = true
    @State private var sortOrder = [KeyPathComparator(\Server.name)]
    
    var body: some View {
        Group {
            Table(selection: $selectedServer, sortOrder: $sortOrder) {
                TableColumn("Name", value: \.name)
                    .width(250)
                
                TableColumn("Map", value: \.map)
                    .width(90)
                
                TableColumn("Mod", value: \.mod)
                    .width(70)
                
                TableColumn("Gametype", value: \.gametype)
                    .width(70)
                
                TableColumn("Players", value: \.inGamePlayers)
                    .width(50)
                
                TableColumn("Ping (ms)", value: \.ping)
                    .width(50)
                
                TableColumn("Ip Address", value: \.hostname)
                    .width(150)
            } rows: {
                ForEach(game.servers) { server in
                    TableRow(server)
                }
            }
            Text("\(game.servers.count) servers found.")
                .frame(width: 150, height: 20.0, alignment: .leading)
                .padding(.bottom, 5)
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { newQuery in
            game.filter(with: newQuery)
        }
        .onChange(of: sortOrder) {
            game.servers.sort(using: $0)
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
                game.updateFullServersVisibility(allowFullServers: newValue)
            }
            
            Toggle(isOn: $showEmpty) {
                Text("Show Empty")
            }
            .toggleStyle(CheckboxToggleStyle())
            .onChange(of: showEmpty) { newValue in
                game.updateEmptyServersVisibility(allowEmptyServers: newValue)
            }
        }
        .navigationTitle("Q3ServerBrowser")
    }
    
    func refreshList() {
        game.refreshCurrentList()
    }
}

private struct StringComparator: SortComparator {
    typealias Compared = String

    func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
        if lhs > rhs {
            return .orderedDescending
        } else if lhs < rhs {
            return .orderedAscending
        } else {
            return .orderedSame
        }
    }

    var order: SortOrder = .forward
}
