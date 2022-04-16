//
//  ContentView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct ContentView: View {
    @EnvironmentObject var game: CurrentGame
    
    var body: some View {
        NavigationView {
            Sidebar()
                .environmentObject(game)
            NavigationView {
                ServersView()
                    .frame(minWidth: 850, idealWidth: 900, maxWidth: 1000)
                ServerDetailsView()
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
}
