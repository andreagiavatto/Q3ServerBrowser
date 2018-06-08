//
//  Games.swift
//  SQL
//
//  Created by Andrea on 08/06/2018.
//

import Foundation

public enum SupportedGame {
    case quake3
    
    public var coordinator: Coordinator {
        switch self {
        case .quake3:
            return Q3Coordinator()
        }
    }
}
