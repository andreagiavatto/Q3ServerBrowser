//
//  SupportedGames.swift
//  SQL
//
//  Created by Andrea on 08/06/2018.
//

import Foundation

public enum SupportedGames {
    
    case quake3
    
    public var name: String {
        switch self {
        case .quake3:
            return "Quake 3 Arena"
        }
    }
    
    public var masterServersList: [String] {
        switch self {
        case .quake3:
            return ["master.ioquake3.org:27950", "master3.idsoftware.com:27950", "master0.excessiveplus.net:27950", "master.maverickservers.com:27950", "dpmaster.deathmask.net:27950"]
        }
    }
    
    public var coordinator: Coordinator {
        switch self {
        case .quake3:
            return Q3Coordinator()
        }
    }
}
