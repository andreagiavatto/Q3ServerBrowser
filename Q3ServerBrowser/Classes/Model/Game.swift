//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
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
    let masterServerAddress: String
    let serverPort: UInt16

    init(title: String, masterServerAddress: String, serverPort: UInt16) {
        self.title = title
        self.masterServerAddress = masterServerAddress
        self.serverPort = serverPort
    }
    
    override var description: String {
        return "<Game : \(self)> title: \(title), masterServerAddress: \(masterServerAddress), masterServerPort: \(serverPort)"
    }
}
