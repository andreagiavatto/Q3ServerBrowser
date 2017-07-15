//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  Q3ServerInfo.h
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//

import Foundation

struct Q3ServerInfo: ServerInfoProtocol {
    
    var ping: String = ""
    var ip: String = ""
    var port: String = ""
    let hostname: String
    let map: String
    let maxPlayers: String
    let currentPlayers: String
    let mod: String
    let gametype: String

    init?(dictionary serverInfo: [String: String]) {
        
        guard !serverInfo.isEmpty else {
            return nil
        }
        
        guard
            let hostname = serverInfo["hostname"] as? String,
            let map = serverInfo["mapname"] as? String,
            let maxPlayers = serverInfo["sv_maxclients"] as? String,
            let currentPlayers = serverInfo["clients"] as? String,
            let mod = serverInfo["game"] as? String,
            let gametype = serverInfo["gametype"] as? String
        else {
            return nil
        }

        self.hostname = hostname
        self.map = map
        self.maxPlayers = maxPlayers
        self.currentPlayers = currentPlayers
        self.mod = mod
        
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
    }
}

extension Q3ServerInfo: CustomStringConvertible {

    var description: String {
        return "<Q3ServerInfo : \(self)> \(["hostname": hostname, "ip": ip, "map": map, "current players": currentPlayers, "max players": maxPlayers, "mod": mod, "ping": ping])"
    }
}

