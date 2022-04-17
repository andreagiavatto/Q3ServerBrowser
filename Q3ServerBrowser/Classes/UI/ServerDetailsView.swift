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
            VStack {
                VStack {
                    Group {
                        HStack {
                            Text("Name:")
                            Spacer()
                            Text(server.name)
                        }
                        HStack {
                            Text("Map:")
                            Spacer()
                            Text(server.map)
                        }
                    }
                }.padding(10)
                Spacer()
                if server.isATeamMode {
                    Group {
                        HStack {
                            Text("Team Red")
                            Spacer()
                            Text(server.teamRed?.score ?? "0")
                        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        teamRedView
                    }
                    Group {
                        HStack {
                            Text("Team Blue")
                            Spacer()
                            Text(server.teamBlue?.score ?? "0")
                        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        teamBlueView
                    }
                } else {
                    playersView
                }
                serverRulesView
                    .frame(idealHeight: 300, maxHeight: 300, alignment: .center)
                Text("")
                    .padding(.bottom, 18)
            }
        } else {
            Text("Select a server")
        }
    }
    
    var teamRedView: some View {
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
    
    var teamBlueView: some View {
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
    
    var serverRulesView: some View {
        Table {
            TableColumn("Setting", value: \.key)
                .width(125)
            TableColumn("Value", value: \.value)
        } rows: {
            let allSettings = server?.rules ?? []
            ForEach(allSettings) { setting in
                TableRow(setting)
            }
        }
    }
}
