//
//  AppDelegate.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 19/09/10.
//  Copyright 2010 Andrea Giavatto. All rights reserved.
//

import Cocoa
import SQL_Mac

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var refreshServersMenuItem: NSMenuItem!
    @IBOutlet weak var clearCachedServersMenuItem: NSMenuItem!
    @IBOutlet weak var gamesMenu: NSMenu!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadAvailableGames()
        refreshServersMenuItem.isEnabled = true
        clearCachedServersMenuItem.isEnabled = !Settings.shared.serverCacheIsEmpty()
    }
    
    @IBAction func refreshServerList(_ sender: Any) {
        if let windowController = NSApplication.shared.keyWindow?.windowController as? MainWindowController {
            windowController.refreshServersList(sender)
        }
    }
    
    @IBAction func clearSavedServerLists(_ sender: Any) {
        Settings.shared.clearAllStoredServers()
        updateMenuItemsStatuses()
    }

    func loadAvailableGames() {
        guard SupportedGames.allCases.count > 0 else {
            print("WTF no games!")
            abort()
        }
        SupportedGames.allCases.forEach { supportedGame in
            gamesMenu.addItem(withTitle: supportedGame.name, action: #selector(gameSelectionChanged), keyEquivalent: "")
        }
        gamesMenu.performActionForItem(at: 0)
    }

    func updateMenuItemsStatuses() {
        clearCachedServersMenuItem.isEnabled = !Settings.shared.serverCacheIsEmpty()
    }

    @objc func gameSelectionChanged(_ sender: NSMenuItem) {
        if let windowController = NSApplication.shared.keyWindow?.windowController as? MainWindowController, let index = gamesMenu.items.firstIndex(of: sender) {
            let supportedGameType = SupportedGames.allCases[index]
            let game = Game(type: supportedGameType)
            windowController.selectGame(game)
        }
    }
}
