//
//  Q3ServerBrowser.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

@main
struct Q3ServerBrowser: App {
    @StateObject private var gameViewModel = GameViewModel(type: .quake3)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameViewModel)
        }
        .commands {
            SidebarCommands()
        }
    }
}

struct Q3ServerBrowser_Previews {
    
}
