//
//  LogsViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 16/06/2018.
//

import AppKit

class LogsViewController: NSViewController {
    
    @IBOutlet weak var logsTextView: NSTextView!
}

extension NSTextView {
    func append(string: String?) {
        guard let string = string else { return }
        self.textStorage?.append(NSAttributedString(string: string))
        self.scrollToEndOfDocument(nil)
    }
}
