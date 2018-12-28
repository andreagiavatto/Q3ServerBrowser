//
//  NSWindowController+Alert.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 20/06/2018.
//

import AppKit

extension NSWindowController {
    
    func displayAlert(message: String, informativeText: String) {
        
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = informativeText
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
