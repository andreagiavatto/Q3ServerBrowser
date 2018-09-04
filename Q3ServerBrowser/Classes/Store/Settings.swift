//
//  Settings.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 03/09/2018.
//

import Foundation
import SQL

class Settings {
    
    static let shared = Settings()
    
    enum SettingsKey: String {
        case lastFetchedServersKey
    }
    
    private let userDefaults = UserDefaults.standard
    
    func saveServers(servers: [Server], for game: Game, from masterServer: String) {
        let key = SettingsKey.lastFetchedServersKey.rawValue.appending(game.name).appending(masterServer)
        let value = NSKeyedArchiver.archivedData(withRootObject: servers)
        userDefaults.set(value, forKey: key)
    }
    
    func getServers(for game: Game, from masterServer: String) -> [Server]? {
        let key = SettingsKey.lastFetchedServersKey.rawValue.appending(game.name).appending(masterServer)
        guard let value = userDefaults.object(forKey: key) as? Data else {
            return nil
        }
        let obj = NSKeyedUnarchiver.unarchiveObject(with: value) as? [Server]
        return obj as? [Server]
    }
}
