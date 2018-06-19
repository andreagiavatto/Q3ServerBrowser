//
//  LogsWindowController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 16/06/2018.
//

import AppKit

class LogsWindowController: NSWindowController {
    
    weak var logsViewController: LogsViewController? {
        return contentViewController as? LogsViewController
    }
    
    func append(_ text: String?) {
        logsViewController?.logsTextView.append(string: text)
    }
}

