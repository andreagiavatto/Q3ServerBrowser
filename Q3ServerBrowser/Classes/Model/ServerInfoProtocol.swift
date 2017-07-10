//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  ServerInfoProtocol.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/19/14.
//
//

import Foundation

protocol ServerInfoProtocol {
    
    var ping: String { get }
    var ip: String { get }
    var hostname: String { get }
    var map: String { get }
    var maxPlayers: String { get }
    var currentPlayers: String { get }
    var mod: String { get }
    var gametype: String { get }

    init?(dictionary serverInfo: [String: String])
}
