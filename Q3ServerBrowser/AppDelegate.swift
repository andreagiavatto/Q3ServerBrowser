//
//  AppDelegate.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 19/09/10.
//  Copyright 2010 Andrea Giavatto. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var refreshServersMenuItem: NSMenuItem!
    @IBOutlet weak var clearCachedServersMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
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
    
    func updateMenuItemsStatuses() {
        clearCachedServersMenuItem.isEnabled = !Settings.shared.serverCacheIsEmpty()
    }
}
