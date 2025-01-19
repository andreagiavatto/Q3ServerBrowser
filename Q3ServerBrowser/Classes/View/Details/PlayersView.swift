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
        VStack(alignment: .leading) {
            if server.isATeamMode {
                teamRedView
                    .frame(maxHeight: 300)
                teamBlueView
                    .frame(maxHeight: 300)
                if let spectators = server.teamSpectator?.players, !spectators.isEmpty {
                    teamSpectatorsView
                        .frame(maxHeight: 300)
                }
            } else {
                playersView
                    .frame(maxHeight: 300)
                if let spectators = server.teamSpectator?.players, !spectators.isEmpty {
                    teamSpectatorsView
                        .frame(maxHeight: 300)
                }
            }
        }
    }
    
    var teamRedView: some View {
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
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
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
            .tableStyle(.inset)
        }
    }
    
    var teamBlueView: some View {
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
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
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
            .tableStyle(.inset)
        }
    }
    
    var teamSpectatorsView: some View {
        VStack {
            HStack {
                Text("Spectators")
                Spacer()
            }
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
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
            .tableStyle(.inset)
        }
    }
    
    var playersView: some View {
        VStack {
            HStack {
                Text("Players")
                Spacer()
            }
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
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
            .tableStyle(.inset)
        }
    }
}
