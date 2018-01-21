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
    var ip: String { get }
    var port: String { get }
    var originalHostname: String { get set }
    var hostname: String { get set }
    var map: String { get set }
    var maxPlayers: String { get set }
    var currentPlayers: String { get set }
    var mod: String { get set }
    var gametype: String { get set }
    var rules: [String: String] { get set }
    var players: [Q3ServerPlayer]? { get set }

    init(ip: String, port: String)
    func update(dictionary serverInfo: [String: String])
}
