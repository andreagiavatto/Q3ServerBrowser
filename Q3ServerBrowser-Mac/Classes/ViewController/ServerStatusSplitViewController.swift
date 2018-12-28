//
//  ServerStatusSplitViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 08/06/2018.
//

import Cocoa
import SQL_Mac

class ServerStatusSplitViewController: NSSplitViewController {
    
    var serverRulesViewController: ServerRulesViewController? {
        return splitViewItems.first?.viewController as? ServerRulesViewController
    }
    
    var playersViewController: PlayersViewController? {
        return splitViewItems.last?.viewController as? PlayersViewController
    }
    
    func updateStatus(for server: Server?) {
        serverRulesViewController?.updateStatus(for: server)
        playersViewController?.updateStatus(for: server)
    }
}
