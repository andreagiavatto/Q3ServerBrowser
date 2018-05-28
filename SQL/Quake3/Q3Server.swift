//
//  Q3ServerInfo.h
//  ServerQueryLibrary
//
//  Created by Andrea Giavatto on 3/16/14.
//

import Foundation

public class Q3Server: NSObject, Server {
    
    @objc public internal(set) var ping: String = ""
    @objc public let ip: String
    public let port: String
    public internal(set) var originalName: String = ""
    @objc public internal(set) var name: String = ""
    @objc public internal(set) var map: String = ""
    public internal(set) var maxPlayers: String = ""
    @objc public internal(set) var currentPlayers: String = ""
    @objc public internal(set) var mod: String = ""
    @objc public internal(set) var gametype: String = ""
    public var rules: [String: String] = [:]
    public var players: [Player]? = nil

    required public init(ip: String, port: String) {
        self.ip = ip
        self.port = port
        super.init()
    }
    
    public func update(with serverInfo: [String: String]?, ping: String) {
        
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
}

extension Q3Server {
    
    public override var description: String {
        return "<Q3Server>: \(ip): \(port)"
    }
}
