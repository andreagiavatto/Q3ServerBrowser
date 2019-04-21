//
//  Q3ServerInfo.h
//  ServerQueryLibrary
//
//  Created by Andrea Giavatto on 3/16/14.
//

import Foundation

class Q3Server: NSObject, Server {
    
    @objc var ping: String = ""
    @objc let ip: String
    let port: String
    var originalName: String = ""
    @objc var name: String = ""
    @objc var map: String = ""
    var maxPlayers: String = "0"
    @objc var currentPlayers: String = "0"
    @objc var mod: String = ""
    @objc var gametype: String = ""
    var rules: [String: String] = [:]
    var players: [Player]? = nil
    @objc var inGamePlayers: String {
        return "\(currentPlayers) / \(maxPlayers)"
    }
    @objc var hostname: String {
        return "\(ip):\(port)"
    }

    required public init(ip: String, port: String) {
        self.ip = ip
        self.port = port
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.ping = aDecoder.decodeObject(forKey: "ping") as? String ?? ""
        self.ip = aDecoder.decodeObject(forKey: "ip") as? String ?? ""
        self.port = aDecoder.decodeObject(forKey: "port") as? String ?? ""
        self.originalName = aDecoder.decodeObject(forKey: "originalName") as? String ?? ""
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.map = aDecoder.decodeObject(forKey: "map") as? String ?? ""
        self.maxPlayers = aDecoder.decodeObject(forKey: "maxPlayers") as? String ?? ""
        self.currentPlayers = aDecoder.decodeObject(forKey: "currentPlayers") as? String ?? ""
        self.mod = aDecoder.decodeObject(forKey: "mod") as? String ?? ""
        self.gametype = aDecoder.decodeObject(forKey: "gametype") as? String ?? ""
        self.rules = aDecoder.decodeObject(forKey: "rules") as? [String: String] ?? [:]
        self.players = aDecoder.decodeObject(forKey: "players") as? [Player]? ?? nil
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(ping, forKey: "ping")
        aCoder.encode(ip, forKey: "ip")
        aCoder.encode(port, forKey: "port")
        aCoder.encode(originalName, forKey: "originalName")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(map, forKey: "map")
        aCoder.encode(maxPlayers, forKey: "maxPlayers")
        aCoder.encode(currentPlayers, forKey: "currentPlayers")
        aCoder.encode(mod, forKey: "mod")
        aCoder.encode(gametype, forKey: "gametype")
        aCoder.encode(rules, forKey: "rules")
        aCoder.encode(players, forKey: "players")
    }

    func update(with serverInfo: [String: String]?, ping: String) {
        
        guard let serverInfo = serverInfo, !serverInfo.isEmpty else {
            return
        }
        
        guard
            let originalName = serverInfo["hostname"],
            let map = serverInfo["mapname"],
            let maxPlayers = serverInfo["sv_maxclients"],
            let currentPlayers = serverInfo["clients"],
            let gametype = serverInfo["gametype"]
        else {
            return
        }

        self.name = ""
        self.ping = ping
        self.originalName = originalName
        self.map = map
        self.maxPlayers = maxPlayers
        self.currentPlayers = currentPlayers
        self.mod = serverInfo["game"] ?? "baseq3"
        
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
    
    func update(currentPlayers: String, ping: String) {
        
        guard ping.count > 0 else {
            return
        }
        self.ping = ping
        self.currentPlayers = currentPlayers
    }
}

extension Q3Server {
    
    public override var description: String {
        return "<Q3Server>: \(ip):\(port)"
    }
}
