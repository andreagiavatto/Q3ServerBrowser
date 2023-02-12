//
//  ServerDetailsView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 15/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct ServerDetailsView: View {
    @EnvironmentObject var game: CurrentGame
        
    @Binding var selectedServer: Server?
    
    var body: some View {
        if let server = selectedServer {
            VStack {
                serverInfo
                Spacer()
                if server.isATeamMode {
                    teamRedView
                    Spacer()
                    teamBlueView
                    if let spectators = selectedServer?.teamSpectator?.players, !spectators.isEmpty {
                        Spacer()
                        teamSpectatorsView
                    }
                } else {
                    playersView
                    if let spectators = selectedServer?.teamSpectator?.players, !spectators.isEmpty {
                        Spacer()
                        teamSpectatorsView
                    }
                }
                Spacer()
                serverRulesView
                Text("")
                    .padding(.bottom, 18)
            }
        } else {
            Text("Select a server from the list")
        }
    }
    
    var serverInfo: some View {
        Group {
            VStack {
                Spacer()
                Text("\(selectedServer?.name ?? "")")
                    .font(.headline)
                Spacer()
                AsyncImage(url: URL(string: "https://ws.q3df.org/images/levelshots/512x384/\(selectedServer?.map ?? "").jpg")) { image in
                    image
                        .resizable()
                        .aspectRatio(4/3, contentMode: .fill)
                        .frame(maxWidth: 400)
                        .cornerRadius(8.0)
                } placeholder: {
                    ProgressView()
                }
                .padding(10)
            }
        }
    }
    
    var teamRedView: some View {
        Group {
            HStack {
                Text("Team Red")
                Spacer()
                Text("\(selectedServer?.teamRed?.score ?? "0")")
            }
            .font(.headline)
            .foregroundColor(.red)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Table {
                TableColumn("Name", value: \.name)
                    .width(min: 125, ideal: 125)
                TableColumn("Ping (ms)", value: \.ping)
                    .width(70)
                TableColumn("Score", value: \.score)
                    .width(70)
            } rows: {
                let redPlayers = selectedServer?.teamRed?.players ?? []
                ForEach(redPlayers) { player in
                    TableRow(player)
                }
            }
        }

    }
    
    var teamBlueView: some View {
        Group {
            HStack {
                Text("Team Blue")
                Spacer()
                Text("\(selectedServer?.teamBlue?.score ?? "0")")
            }
            .font(.headline)
            .foregroundColor(.blue)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Table {
                TableColumn("Name", value: \.name)
                    .width(min: 125, ideal: 125)
                TableColumn("Ping (ms)", value: \.ping)
                    .width(70)
                TableColumn("Score", value: \.score)
                    .width(70)
            } rows: {
                let bluePlayers = selectedServer?.teamBlue?.players ?? []
                ForEach(bluePlayers) { player in
                    TableRow(player)
                }
            }
        }
    }
    
    var teamSpectatorsView: some View {
        Group {
            HStack {
                Text("Spectators")
                Spacer()
            }
            .font(.headline)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Table {
                TableColumn("Name", value: \.name)
                    .width(min: 180, ideal: 180)
                TableColumn("Ping (ms)", value: \.ping)
                    .width(70)
            } rows: {
                let specPlayers = selectedServer?.teamSpectator?.players ?? []
                ForEach(specPlayers) { player in
                    TableRow(player)
                }
            }
        }
    }
        
    var playersView: some View {
        Group {
            HStack {
                Text("Players")
                Spacer()
            }
            .font(.headline)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Table {
                TableColumn("Name", value: \.name)
                    .width(min: 125, ideal: 125)
                TableColumn("Ping (ms)", value: \.ping)
                    .width(70)
                TableColumn("Score", value: \.score)
                    .width(70)
            } rows: {
                let allPlayers = selectedServer?.players ?? []
                ForEach(allPlayers) { player in
                    TableRow(player)
                }
            }
        }
    }
    
    var serverRulesView: some View {
        Group {
            HStack {
                Text("Server Info")
                Spacer()
            }
            .font(.headline)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Table {
                TableColumn("Setting", value: \.key)
                    .width(min: 100, ideal: 100)
                TableColumn("Value", value: \.value)
                    .width(min: 170, ideal: 170)
            } rows: {
                let sortedRules = selectedServer?.rules.sorted(by: { $0.key < $1.key })
                let allSettings = sortedRules ?? []
                ForEach(allSettings) { setting in
                    TableRow(setting)
                }
            }
        }
    }
}
