//
//  Q3ServerInfo.h
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//

import Foundation

class Q3ServerInfo: NSObject, ServerInfoProtocol {
    
    @objc var ping: String = ""
    @objc let ip: String
    let port: String
    var originalName: String = ""
    @objc var name: String = ""
    @objc var map: String = ""
    var maxPlayers: String = ""
    @objc var currentPlayers: String = ""
    @objc var mod: String = ""
    @objc var gametype: String = ""
    var rules: [String: String] = [:]
    var players: [Q3ServerPlayer]? = nil

    required init(ip: String, port: String) {
        self.ip = ip
        self.port = port
        super.init()
    }
    
    func update(dictionary serverInfo: [String: String]) {
        
        guard !serverInfo.isEmpty else {
            return
        }
        
        guard
            let originalName = serverInfo["hostname"] as? String,
            let map = serverInfo["mapname"] as? String,
            let maxPlayers = serverInfo["sv_maxclients"] as? String,
            let currentPlayers = serverInfo["clients"] as? String,
            let gametype = serverInfo["gametype"] as? String
        else {
            return
        }

        self.name = ""
        self.originalName = originalName
        self.map = map
        self.maxPlayers = maxPlayers
        self.currentPlayers = currentPlayers
        self.mod = serverInfo["game"] as? String ?? "baseq3"
        
        if !gametype.isEmpty, let gtype = Int(gametype) {
            switch gtype {
            case 0, 2:
                self.gametype = "ffa"
            case 1:
                self.gametype = "tourney"
            case 3:
                self.gametype = "tdm"
            case 4:
                self.gametype = "ctf"
            default:
                self.gametype = "unknown"
            }
        } else {
            self.gametype = "unknown"
        }
        
        self.name = self.originalName.stripQ3Colors()
    }
}
