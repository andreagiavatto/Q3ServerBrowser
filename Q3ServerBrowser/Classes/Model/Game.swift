//
//  Game.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 11/16/13.
//
//

import Foundation

class Game: NSObject {
    
    let title: String
    var masterServerAddress: String
    var serverPort: String

    init(title: String, masterServerAddress: String, serverPort: String) {
        self.title = title
        self.masterServerAddress = masterServerAddress
        self.serverPort = serverPort
    }
    
    override var description: String {
        return "<Game : \(self)> title: \(title), masterServerAddress: \(masterServerAddress), masterServerPort: \(serverPort)"
    }
}
