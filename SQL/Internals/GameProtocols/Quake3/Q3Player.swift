//
//  Q3ServerPlayer.swift
//  ServerQueryLibrary
//
//  Created by Andrea Giavatto on 3/23/14.
//

import Foundation

class Q3Player: NSObject, Player {
    
    let name: String
    let ping: String
    let score: String
    
    required init?(line: String) {
        
        guard !line.isEmpty else {
            return nil
        }
        
        let playerComponents = line.components(separatedBy: CharacterSet.whitespaces)
        guard playerComponents.count == 3 else {
            return nil
        }

        self.score = playerComponents[0]
        self.ping = playerComponents[1]
        self.name = playerComponents[2].stripQ3Colors().replacingOccurrences(of: "\"", with: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.ping = aDecoder.decodeObject(forKey: "ping") as? String ?? ""
        self.score = aDecoder.decodeObject(forKey: "score") as? String ?? ""
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(ping, forKey: "ping")
        aCoder.encode(score, forKey: "score")
    }
}

extension Q3Player {
    
    public override var description: String {
        return "<Q3Player> \(name) (\(ping)) - \(score)"
    }
}
