//
//  Settings.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 03/09/2018.
//

import Foundation
import SQL_Mac

class Settings {
    
    static let shared = Settings()
    
    func serverCacheIsEmpty() -> Bool {
        
        guard let applicationDirectoryPath = getAppDirectory() else {
            return false
        }
        let fileManager = FileManager()
        do {
            let filePaths = try fileManager.contentsOfDirectory(at: applicationDirectoryPath, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles])
            return filePaths.isEmpty
        } catch {}
        return false
    }
    
    func clearAllStoredServers() {
        
        guard let applicationDirectoryPath = getAppDirectory() else {
            return
        }
        let fileManager = FileManager()
        do {
            let filePaths = try fileManager.contentsOfDirectory(at: applicationDirectoryPath, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles])
            for filePath in filePaths {
                try fileManager.removeItem(at: filePath)
            }
        } catch {}
    }
    
    func saveServers(servers: [Server], for game: Game, from masterServer: String) {
        let filename = game.name.appending(masterServer).components(separatedBy: .whitespaces).joined()
        guard let filePath = getAppDirectory()?.appendingPathComponent(filename) else {
            return
        }
        let value = NSKeyedArchiver.archivedData(withRootObject: servers)
        do {
            try value.write(to: filePath, options: .atomicWrite)
        } catch {}
    }
    
    func getServers(for game: Game, from masterServer: String) -> [Server]? {
        let filename = game.name.appending(masterServer).components(separatedBy: .whitespaces).joined()
        guard
            let filePath = getAppDirectory()?.appendingPathComponent(filename),
            let value = try? Data(contentsOf: filePath)
        else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: value) as? [Server]
    }
    
    private func getApplicationSupportURL() -> URL? {
        
        let fileManager = FileManager()
        var applicationSupportURL: URL? = nil
        do {
            applicationSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
        catch {}
        return applicationSupportURL
    }
    
    private func getAppDirectory() -> URL? {
        
        let fileManager = FileManager()
        guard let applicationSupportURL = getApplicationSupportURL() else {
            return nil
        }
        
        let appDirectory = applicationSupportURL.appendingPathComponent("Q3ServerBrowser")
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: appDirectory.absoluteString, isDirectory: &isDir) {
            if !isDir.boolValue {
                return nil
            }
        } else {
            do {
                try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return nil
            }
        }
        return appDirectory
    }
}
