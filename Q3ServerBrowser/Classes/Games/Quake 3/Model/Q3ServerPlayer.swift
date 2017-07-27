//
//  Q3ServerPlayer.swift
//  ServerBrowser
//
//  Created by Andrea Giavatto on 3/23/14.
//

import Foundation

struct Q3ServerPlayer: ServerPlayerProtocol {
    
    let name: String
    let ping: String
    let score: String
    
    init?(line: String) {
        
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

extension Q3ServerPlayer: CustomStringConvertible {
    var description: String {
        return "<Q3ServerPlayer> \(name) (\(ping)) - \(score)"
    }
}
