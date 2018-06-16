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

    func applicationDidFinishLaunching(_ aNotification: Notification) {

    }
    
    @IBAction func refreshServerList(_ sender: Any) {
        if let windowController = NSApplication.shared.keyWindow?.windowController as? MainWindowController {
            windowController.refreshServersList(sender)
        }
    }
}
