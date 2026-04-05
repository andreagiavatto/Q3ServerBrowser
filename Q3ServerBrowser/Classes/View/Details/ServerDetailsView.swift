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
            AsyncImage(url: URL(string: "https://ws.q3df.org/images/levelshots/512x384/\(server.map).jpg")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(4/3, contentMode: .fit)
                case .failure:
                    // The map image is unavailable (unknown map, network error, etc.)
                    Image(systemName: "photo.slash")
                        .resizable()
                        .aspectRatio(4/3, contentMode: .fit)
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                    EmptyView()
                }
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
                    // Q3 reports elapsed match time as "score_time"; many mods
                    // use "timelimit" or "g_timelimit" for the configured limit.
                    // Check all known keys in priority order so real servers
                    // that don't report score_time still show something useful.
                    Text(server.rules.first(where: {
                        let k = $0.key.lowercased()
                        return k == "score_time" || k == "timelimit" || k == "g_timelimit"
                    })?.value ?? "")
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
                let sortedRules = server.rules.sorted(using: sortOrder)
                ForEach(sortedRules) { setting in
                    TableRow(setting)
                }
            }
            .tableStyle(.inset)
        }
    }
}
