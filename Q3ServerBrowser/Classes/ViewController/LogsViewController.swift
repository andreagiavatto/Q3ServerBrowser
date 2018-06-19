//
//  LogsViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 16/06/2018.
//

import AppKit

class LogsViewController: NSViewController {
    
    @IBOutlet weak var logsTextView: NSTextView!
    
    func append(_ output: String) {
        logsTextView.append(string: "\n")
        logsTextView.append(string: output)
    }
}

extension NSTextView {
    
    func append(string: String) {
        self.textStorage?.append(NSAttributedString(string: string))
        self.scrollToEndOfDocument(nil)
    }
}
