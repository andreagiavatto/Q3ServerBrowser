//
//  PlayersView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 25/02/2023.
//

import SwiftUI
import GameServerQueryLibrary

struct PlayersView: View {
    let server: Server
    
    var body: some View {
        HSplitView {
            if server.isATeamMode {
                teamRedView
                HStack {
                    Divider()
                }
                teamBlueView
                if let spectators = server.teamSpectator?.players, !spectators.isEmpty {
                    HStack {
                        Divider()
                    }
                    teamSpectatorsView
                }
            } else {
                playersView
                if let spectators = server.teamSpectator?.players, !spectators.isEmpty {
                    HStack {
                        Divider()
                    }
                    teamSpectatorsView
                }
            }
        }
        .frame(minHeight: 200, idealHeight: 250, maxHeight: 400)
    }
    
    var teamRedView: some View {
        Group {
            VStack {
                HStack {
                    Text("Team Red")
                    Spacer()
                    Divider()
                        .frame(height: 16)
                    Text("\(server.teamRed?.score ?? "0")")
                }
                .font(.headline)
                .foregroundColor(.red)
                .padding(EdgeInsets(top: 4, leading: 12, bottom: 0, trailing: 12))
                Table(of: Player.self) {
                    TableColumn("Name", value: \.name)
                        .width(min: 125, ideal: 125)
                    TableColumn("Ping (ms)", value: \.ping)
                        .width(min: 70)
                    TableColumn("Score", value: \.score)
                        .width(min: 70)
                } rows: {
                    let redPlayers = server.teamRed?.players ?? []
                    ForEach(redPlayers) { player in
                        TableRow(player)
                    }
                }
            }
        }

    }
    
    var teamBlueView: some View {
        Group {
            VStack {
                HStack {
                    Text("Team Blue")
                    Spacer()
                    Divider()
                        .frame(height: 16)
                    Text("\(server.teamBlue?.score ?? "0")")
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding(EdgeInsets(top: 4, leading: 12, bottom: 0, trailing: 12))
                Table(of: Player.self) {
                    TableColumn("Name", value: \.name)
                        .width(min: 125, ideal: 125)
                    TableColumn("Ping (ms)", value: \.ping)
                        .width(min: 70)
                    TableColumn("Score", value: \.score)
                        .width(min: 70)
                } rows: {
                    let bluePlayers = server.teamBlue?.players ?? []
                    ForEach(bluePlayers) { player in
                        TableRow(player)
                    }
                }
            }
        }
    }
    
    var teamSpectatorsView: some View {
        Group {
            VStack {
                HStack {
                    Text("Spectators")
                    Spacer()
                }
                .font(.headline)
                .padding(EdgeInsets(top: 4, leading: 12, bottom: 0, trailing: 12))
                Table(of: Player.self) {
                    TableColumn("Name", value: \.name)
                        .width(min: 180, ideal: 180)
                    TableColumn("Ping (ms)", value: \.ping)
                        .width(min: 70)
                } rows: {
                    let specPlayers = server.teamSpectator?.players ?? []
                    ForEach(specPlayers) { player in
                        TableRow(player)
                    }
                }
            }
        }
    }
        
    var playersView: some View {
        Group {
            VStack {
                HStack {
                    Text("Players")
                    Spacer()
                }
                .font(.headline)
                .padding(EdgeInsets(top: 4, leading: 12, bottom: 0, trailing: 12))
                Table(of: Player.self) {
                    TableColumn("Name", value: \.name)
                        .width(min: 125, ideal: 125)
                    TableColumn("Ping (ms)", value: \.ping)
                        .width(min: 70)
                    TableColumn("Score", value: \.score)
                        .width(min: 70)
                } rows: {
                    let allPlayers = server.players.sorted { (first, second) -> Bool in
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
    }
}
