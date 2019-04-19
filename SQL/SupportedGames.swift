//
//  SupportedGames.swift
//  SQL
//
//  Created by Andrea on 08/06/2018.
//

import Foundation

public struct MasterServer: CustomStringConvertible {
    public let hostname: String
    public let port: String
    
    public var description: String {
        return "\(hostname):\(port)"
    }
}

public enum SupportedGames: CaseIterable {
    
    case quake3
    case urbanTerror
    case rtcw
    
    public var name: String {
        switch self {
        case .quake3:
            return "Quake 3 Arena"
        case .urbanTerror:
            return "UrbanTerror"
        case .rtcw:
            return "Return to Castle Wolfenstein"
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
        case .urbanTerror:
            return [MasterServer(hostname: "master.urbanterror.info", port: "27900")]
        case .rtcw:
            return [MasterServer(hostname: "wolfmaster.idsoftware.com", port: "27950"),
                    MasterServer(hostname: "master.iortcw.org", port: "27950")]
        }
    }
    
    public var coordinator: Coordinator {
        switch self {
        case .quake3:
            return Q3Coordinator()
        case .urbanTerror:
            return Q3Coordinator()
        case .rtcw:
            return RTCWCoordinator()
        }
    }

    public var launchArguments: String {
        return "+connect"
    }
}
