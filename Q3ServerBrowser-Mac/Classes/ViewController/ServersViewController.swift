//
//  ServersViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 08/06/2018.
//

import Cocoa
import SQL_Mac

protocol ServersViewControllerDelegate: class {
    
    func serversViewController(_ controller: ServersViewController, didSelect server: Server)
    func serversViewController(_ controller: ServersViewController, didDoubleClickOn server: Server)
}

class ServersViewController: NSViewController {
    
    @IBOutlet weak var serversTableView: NSTableView!
    @IBOutlet weak var serversArrayController: NSArrayController!
    
    weak var delegate: ServersViewControllerDelegate?
    @objc dynamic fileprivate var servers = [Server]()
    var currentSelection: Server?
    var numOfServers: Int {
        return servers.count
    }
    
    @IBAction func copyHostnameToPasteboard(_ sender: NSTableView) {
        guard let servers = serversArrayController.content as? [Server] else {
            return
        }
        
        let server = servers[sender.clickedRow]
        delegate?.serversViewController(self, didDoubleClickOn: server)
    }
    
    func update(server: Server) {
        guard
            var servers = serversArrayController.content as? [Server],
            let index = servers.firstIndex(where: { (s) -> Bool in
                return server.ip == s.ip && server.port == s.port
            })
        else {
            return
        }
        
        DispatchQueue.main.async {
            servers[index] = server
        }
    }
    
    func updateServers(with newServers: [Server]) {
        DispatchQueue.main.async {
            self.servers.removeAll(where: { (existing) -> Bool in
                !newServers.contains(where: { (new) -> Bool in
                    return new.hostname == existing.hostname
                })
            })
            
            let toAdd = self.elementDifference(between: newServers, and: self.servers)
            if !toAdd.isEmpty {
                self.servers.append(contentsOf: toAdd)
            }
        }
    }
    
    func clearServers() {
        DispatchQueue.main.async {
            self.servers = []
        }
    }
    
    func elementDifference(between first: [Server], and second: [Server]) -> [Server] {
        return first.filter { existing in
            !second.contains(where: { (new) -> Bool in
                return new.hostname == existing.hostname
            })
        }
    }
}

extension ServersViewController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ aNotification: Notification) {
        
        guard
            let server = serversArrayController.selectedObjects.first as? Server,
            server.hostname != currentSelection?.hostname
        else {
            return
        }
        
        currentSelection = server
        delegate?.serversViewController(self, didSelect: server)
    }
}

