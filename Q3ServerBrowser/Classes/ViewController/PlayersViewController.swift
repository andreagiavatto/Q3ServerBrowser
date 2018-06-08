//
//  PlayersViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 08/06/2018.
//

import Cocoa
import SQL

class PlayersViewController: NSViewController {
    
    @IBOutlet weak var playersTableView: NSTableView!
    
    fileprivate var server: Server?
    
    func updateStatus(for server: Server?) {
        self.server = server
        playersTableView.reloadData()
    }
    
    fileprivate func configureViewForPlayers(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard
            let server = server,
            let columnId = tableColumn?.identifier,
            let players = server.players,
            let player = players[row] as? Player
        else {
            return nil
        }
        
        var text = ""
        
        switch columnId.rawValue {
        case "name":
            text = player.name
        case "ping":
            text = player.ping
        case "score":
            text = player.score
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

extension PlayersViewController: NSTableViewDataSource {
    
    func numberOfRows(in aTableView: NSTableView) -> Int {

        return server?.players?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        return configureViewForPlayers(playersTableView, viewFor: tableColumn, row: row)
    }
}
