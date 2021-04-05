//
//  LogsViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 16/06/2018.
//

import AppKit

class LogsViewController: NSViewController {
    
    @IBOutlet var logsTextView: NSTextView!
    
    func append(_ output: String) {
        logsTextView.append(string: output)
    }
}

extension NSTextView {
    
    func append(string: String) {
        self.textStorage?.append(NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : NSColor.controlTextColor]))
        self.scrollToEndOfDocument(nil)
    }
}
