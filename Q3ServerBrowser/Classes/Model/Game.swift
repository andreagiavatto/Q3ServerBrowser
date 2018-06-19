//
//  Game.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 11/16/13.
//
//

import Foundation
import SQL

class Game: NSObject {
    
    let type: SupportedGame
    var masterServerAddress: String
    var serverPort: String
    let launchArguments: String

    init(type: SupportedGame, masterServerAddress: String, serverPort: String, launchArguments: String) {
        self.type = type
        self.masterServerAddress = masterServerAddress
        self.serverPort = serverPort
        self.launchArguments = launchArguments
    }
    
    override var description: String {
        return "<Game: \(self)> master server: \(masterServerAddress):\(serverPort)"
    }
}
