//
//  Q3ServerInfo.h
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//

import Foundation

class Q3ServerInfo: ServerInfoProtocol {
    
    var ping: String = ""
    let ip: String
    let port: String
    var originalHostname: String = ""
    var hostname: String = ""
    var map: String = ""
    var maxPlayers: String = ""
    var currentPlayers: String = ""
    var mod: String = ""
    var gametype: String = ""
    var rules: [String: String] = [:]
    var players: [Q3ServerPlayer]? = nil

    required init(ip: String, port: String) {
        self.ip = ip
        self.port = port
    }
    
    func update(dictionary serverInfo: [String: String]) {
        
        guard !serverInfo.isEmpty else {
            return
        }
        
        guard
            let originalHostname = serverInfo["hostname"] as? String,
            let map = serverInfo["mapname"] as? String,
            let maxPlayers = serverInfo["sv_maxclients"] as? String,
            let currentPlayers = serverInfo["clients"] as? String,
            let gametype = serverInfo["gametype"] as? String
        else {
            return
        }

        self.hostname = ""
        self.originalHostname = originalHostname
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
        
        self.hostname = self.originalHostname.stripQ3Colors()
    }
}

extension Q3ServerInfo: CustomStringConvertible {

    var description: String {
        return "<Q3ServerInfo> \(hostname) -- (\(ip):\(port))\n\t\(map) (\(currentPlayers)/\(maxPlayers))\n\t\(mod)\n\t\(ping)"
    }
}

extension Q3ServerInfo: Equatable { }

func ==(lhs: Q3ServerInfo, rhs: Q3ServerInfo) -> Bool {
    
    if lhs.ip == rhs.ip && lhs.port == rhs.port {
        return true
    }
    
    return false
}

