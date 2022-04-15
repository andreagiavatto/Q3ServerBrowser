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
    
    @State var nameSortOrder: [KeyPathComparator<Server>] = [
        .init(\.name, order: SortOrder.forward)
    ]
    
    var body: some View {
        Group {
            Table(selection: $selection, sortOrder: $nameSortOrder) {
                TableColumn("Name", value: \.name)
                
                TableColumn("Map", value: \.map)
                
                TableColumn("Mod", value: \.mod)
                
                TableColumn("Gametype", value: \.gametype)
                
                //            TableColumn("Players", value: \.players)
                
                TableColumn("Ping", value: \.ping)
                
                TableColumn("Ip Address", value: \.ip)
            } rows: {
                ForEach(game.servers) { server in
                    TableRow(server)
                }
            }
        }
        .searchable(text: $searchText)
        .toolbar {
//            DisplayModePicker(mode: $mode)
            Button(action: refreshList) {
                Label("Refresh List", systemImage: "arrow.triangle.2.circlepath")
            }
//            .rotationEffect(.degrees(game.$isUpdating ? 360 : 0), anchor: .center)
//            .animation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false))
        }
        .navigationTitle("Q3ServerBrowser")
        .navigationSubtitle("\(game.servers.count) servers found.")
    }
    
    func refreshList() {
        game.refreshCurrentList()
    }
}
