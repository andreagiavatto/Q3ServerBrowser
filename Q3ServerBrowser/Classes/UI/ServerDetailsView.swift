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
    
    @Binding var selectedServer: Server.ID?
    
    var server: Server? {
        game.server(by: selectedServer)
    }
    
    var body: some View {
        if let server = server {
            if server.isATeamMode {
                VStack {
                    teamRedView
                    teamBlueView
                }
            } else {
                playersView
            }
        } else {
            Text("Select a server")
        }
    }
    
    var teamRedView: some View {
        VStack {
            Text("Team Red")
            Table {
                TableColumn("Name", value: \.name)
                    .width(125)
                TableColumn("Ping (ms)", value: \.ping)
                    .width(70)
                TableColumn("Score", value: \.score)
                    .width(70)
            } rows: {
                let redPlayers = server?.teamRed?.players ?? []
                ForEach(redPlayers) { player in
                    TableRow(player)
                }
            }
        }
    }
    
    var teamBlueView: some View {
        VStack {
            Text("Team Blue")
            Table {
                TableColumn("Name", value: \.name)
                    .width(100)
                TableColumn("Ping (ms)", value: \.ping)
                    .width(60)
                TableColumn("Score", value: \.score)
                    .width(60)
            } rows: {
                let bluePlayers = server?.teamBlue?.players ?? []
                ForEach(bluePlayers) { player in
                    TableRow(player)
                }
            }
        }
    }
        
    var playersView: some View {
        Table {
            TableColumn("Name", value: \.name)
                .width(100)
            TableColumn("Ping (ms)", value: \.ping)
                .width(60)
            TableColumn("Score", value: \.score)
                .width(60)
        } rows: {
            let allPlayers = server?.players ?? []
            ForEach(allPlayers) { player in
                TableRow(player)
            }
        }
    }
}
