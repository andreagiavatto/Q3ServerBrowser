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
    
    @State private var selection = Set<Server.ID>()
    @State var searchText: String = ""
    @State var showFull: Bool = true
    @State var showEmpty: Bool = true
    @State var nameSortOrder: [KeyPathComparator<Server>] = [
        .init(\.name, order: SortOrder.forward)
    ]
    
    var body: some View {
        Group {
            Table(selection: $selection, sortOrder: $nameSortOrder) {
//                TableColumn("Name", value: \.name, comparator: StringComparator()) { server in
//                    Text(server.name)
//                        .multilineTextAlignment(.center)
//                }.width(250)
                
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
                
                TableColumn("Ping", value: \.ping)
                    .width(40)
                
                TableColumn("Ip Address", value: \.hostname)
                    .width(150)
            } rows: {
                ForEach(game.servers) { server in
                    TableRow(server)
                }
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { newQuery in
            game.filter(with: newQuery)
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
        .navigationSubtitle("\(game.servers.count) servers found.")
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
