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
    var body: some Scene {
        WindowGroup {
            MainView(supportedGames: SupportedGames.allCases)
        }
        .commands {
            SidebarCommands()
        }
    }
}
