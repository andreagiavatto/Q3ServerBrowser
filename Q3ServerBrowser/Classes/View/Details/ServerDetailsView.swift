//
//  ServerDetailsView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 15/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct ServerDetailsView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @State private var sortOrder = [KeyPathComparator(\Setting.key)]
            
    var body: some View {
        Group {
            if let selection = gameViewModel.currentSelectedServer, let server = gameViewModel.server(by: selection) {
                VStack(alignment: .leading, spacing: .zero) {
                    serverInfo(server: server)
                        .frame(maxHeight: 160)
                    Divider()
                    PlayersView(server: server)
                    serverRulesView(server: server)
                }
            } else {
                ContentUnavailableView("Select a server from the list", image: "list.bullet")
            }
        }
    }
    
    @ViewBuilder
    func serverInfo(server: Server) -> some View {
        HStack {
            AsyncImage(url: URL(string: "https://ws.q3df.org/images/levelshots/512x384/\(server.map).jpg")) { image in
                image
                    .resizable()
                    .aspectRatio(4/3, contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Server:")
                    Spacer()
                    Text(server.name)
                }
                HStack {
                    Text("Map:")
                    Spacer()
                    Text(server.map)
                }
                HStack {
                    Text("Time:")
                    Spacer()
                    Text(server.rules.first(where: { $0.key.lowercased().contains("score_time") })?.value ?? "")
                }
            }
            .font(.title3)
        }
        .padding(.trailing, 16)
    }
    
    @ViewBuilder
    func serverRulesView(server: Server) -> some View {
        VStack {
            HStack {
                Text("Server Info")
                Spacer()
            }
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            Table(sortOrder: $sortOrder) {
                TableColumn("Setting", value: \.key)
                    .width(min: 100, ideal: 100)
                TableColumn("Value", value: \.value)
                    .width(min: 170, ideal: 250)
            } rows: {
                let sortedRules = server.rules.sorted(by: { $0.key < $1.key })
                let allSettings = sortedRules ?? []
                ForEach(allSettings) { setting in
                    TableRow(setting)
                }
            }
            .tableStyle(.inset)
        }
    }
}
