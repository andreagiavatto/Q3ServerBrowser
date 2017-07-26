//
//  ServerInfoProtocol.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/19/14.
//
//

import Foundation

protocol ServerInfoProtocol {
    
    var ping: String { get set }
    var ip: String { get set }
    var port: String { get set }
    var originalHostname: String { get }
    var hostname: String { get }
    var map: String { get }
    var maxPlayers: String { get }
    var currentPlayers: String { get }
    var mod: String { get }
    var gametype: String { get }

    init?(dictionary serverInfo: [String: String])
}
