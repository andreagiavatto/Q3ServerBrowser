//
//  Game.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 11/16/13.
//
//

import Foundation

public class Game: NSObject {
    
    public let type: SupportedGames
    public let launchArguments: String
    public var name: String {
        return type.name
    }
    public var masterServersList: [String] {
        return type.masterServersList
    }

    public init(type: SupportedGames, launchArguments: String) {
        self.type = type
        self.launchArguments = launchArguments
    }
    
    override public var description: String {
        return "<Game: \(self)> Name: \(type.name)"
    }
}
