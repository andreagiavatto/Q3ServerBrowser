//
//  ServerDetailsView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 15/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct ServerDetailsView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
            
    var body: some View {
        if let server = gameViewModel.currentSelectedServer {
            VStack {
                HStack {
                    serverInfo
//                    Spacer()
                    serverRulesView
                }
                .frame(maxHeight: 400)
                Spacer()
                HStack {
                    if server.isATeamMode {
                        teamRedView
                        Spacer()
                        teamBlueView
                        if let spectators = gameViewModel.currentSelectedServer?.teamSpectator?.players, !spectators.isEmpty {
                            Spacer()
                            teamSpectatorsView
                        }
                    } else {
                        playersView
                        if let spectators = gameViewModel.currentSelectedServer?.teamSpectator?.players, !spectators.isEmpty {
                            Spacer()
                            teamSpectatorsView
                        }
                    }
                }
                .frame(maxHeight: 400)
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
                Text("\(gameViewModel.currentSelectedServer?.name ?? "")")
                    .font(.headline)
                Spacer()
                AsyncImage(url: URL(string: "https://ws.q3df.org/images/levelshots/512x384/\(gameViewModel.currentSelectedServer?.map ?? "").jpg")) { image in
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
                Text("\(gameViewModel.currentSelectedServer?.teamRed?.score ?? "0")")
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
                let redPlayers = gameViewModel.currentSelectedServer?.teamRed?.players ?? []
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
                Text("\(gameViewModel.currentSelectedServer?.teamBlue?.score ?? "0")")
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
                let bluePlayers = gameViewModel.currentSelectedServer?.teamBlue?.players ?? []
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
                let specPlayers = gameViewModel.currentSelectedServer?.teamSpectator?.players ?? []
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
                let allPlayers = gameViewModel.currentSelectedServer?.players.sorted { (first, second) -> Bool in
                    guard let firstScore = Int(first.score), let secondScore = Int(second.score) else {
                        return false
                    }
                    return firstScore > secondScore
                } ?? []
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
                    .width(min: 170, ideal: 250)
            } rows: {
                let sortedRules = gameViewModel.currentSelectedServer?.rules.sorted(by: { $0.key < $1.key })
                let allSettings = sortedRules ?? []
                ForEach(allSettings) { setting in
                    TableRow(setting)
                }
            }
        }
    }
}
