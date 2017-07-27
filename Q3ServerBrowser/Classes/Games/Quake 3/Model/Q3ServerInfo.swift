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
    let originalHostname: String
    private(set) var hostname: String
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
            let originalHostname = serverInfo["hostname"] as? String,
            let map = serverInfo["mapname"] as? String,
            let maxPlayers = serverInfo["sv_maxclients"] as? String,
            let currentPlayers = serverInfo["clients"] as? String,
            let gametype = serverInfo["gametype"] as? String
        else {
            return nil
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

