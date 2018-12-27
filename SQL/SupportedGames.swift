//
//  SupportedGames.swift
//  SQL
//
//  Created by Andrea on 08/06/2018.
//

import Foundation

public struct MasterServer {
    public let hostname: String
    public let port: String
}

public enum SupportedGames {
    
    case quake3
    
    public var name: String {
        switch self {
        case .quake3:
            return "Quake 3 Arena"
        }
    }
    
    public var masterServers: [MasterServer] {
        switch self {
        case .quake3:
            return [MasterServer(hostname: "master.ioquake3.org", port:"27950"),
                    MasterServer(hostname: "master3.idsoftware.com", port:"27950"),
                    MasterServer(hostname: "master0.excessiveplus.net", port:"27950"),
                    MasterServer(hostname: "master.maverickservers.com", port:"27950"),
                    MasterServer(hostname: "dpmaster.deathmask.net", port:"27950")]
        }
    }
    
    public var coordinator: Coordinator {
        switch self {
        case .quake3:
            return Q3Coordinator()
        }
    }
}
