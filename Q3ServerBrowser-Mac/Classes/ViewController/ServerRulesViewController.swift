//
//  ServerRulesViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 08/06/2018.
//

import Cocoa
import SQL_Mac

class ServerRulesViewController: NSViewController {
    
    @IBOutlet weak var rulesTableView: NSTableView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    fileprivate var server: Server?
    
    func updateStatus(for server: Server?) {
        self.server = server
        rulesTableView.reloadData()
    }
    
    fileprivate func configureViewForRules(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard
            let server = server,
            let columnId = tableColumn?.identifier,
            let key = Array(server.rules.keys)[row] as? String,
            let value = server.rules[key] as? String
        else {
            return nil
        }
        
        var text = ""
        switch columnId.rawValue {
        case "setting":
            text = key
        case "value":
            text = value
        default:
            return nil
        }
        
        if let cell = tableView.makeView(withIdentifier: columnId, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }
}

extension ServerRulesViewController: NSTableViewDataSource {
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return server?.rules.keys.count ?? 0
    }
}
    
extension ServerRulesViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return configureViewForRules(tableView, viewFor: tableColumn, row: row)
    }
}
