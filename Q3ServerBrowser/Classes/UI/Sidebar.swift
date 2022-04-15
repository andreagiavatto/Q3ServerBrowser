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
            .frame(minWidth: 250, idealWidth: 250, maxWidth: 300)
    }
}

struct SideBarContent: View {
    @EnvironmentObject var game: CurrentGame
    
    var body: some View {
        List(game.masterServers, id: \.description) { masterServer in
            Text(masterServer.description)
        }
        .listStyle(SidebarListStyle())
    }
}
