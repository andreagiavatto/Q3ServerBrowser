//
//  Q3ServerPlayer.swift
//  ServerQueryLibrary
//
//  Created by Andrea Giavatto on 3/23/14.
//

import Foundation

public struct Q3Player: Player {
    
    public let name: String
    public let ping: String
    public let score: String
    
    public init?(line: String) {
        
        guard !line.isEmpty else {
            return nil
        }
        
        let playerComponents = line.components(separatedBy: CharacterSet.whitespaces)
        guard playerComponents.count == 3 else {
            return nil
        }

        self.score = playerComponents[0]
        self.ping = playerComponents[1]
        self.name = playerComponents[2].stripQ3Colors()
    }
}

extension Q3Player: CustomStringConvertible {
    
    public var description: String {
        return "<Q3Player> \(name) (\(ping)) - \(score)"
    }
}
