//
//  Sidebar.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct Sidebar: View {
    @EnvironmentObject var game: CurrentGame
    
    var body: some View {
        SideBarContent()
            .environmentObject(game)
            .frame(minWidth: 275, idealWidth: 275, maxWidth: 300)
    }
}

struct SideBarContent: View {
    @EnvironmentObject var game: CurrentGame
    
    @State var selectedMasterServer: MasterServer? {
        didSet {
            game.updateMasterServer(selectedMasterServer)
        }
    }
    
    var body: some View {
        Section("Master Servers") {
            List(game.masterServers, id: \.description) { masterServer in
                HStack {
                    Text(masterServer.description)
                    Spacer()
                    if masterServer.description == selectedMasterServer?.description {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }.onTapGesture {
                    self.selectedMasterServer = masterServer
                }
            }
            .listStyle(SidebarListStyle())
        }
    }
}
