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
        Text("\(server?.name ?? "Nothing selected")")
    }
}
