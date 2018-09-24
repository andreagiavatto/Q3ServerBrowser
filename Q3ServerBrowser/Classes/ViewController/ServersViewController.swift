//
//  ServersViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 08/06/2018.
//

import Cocoa
import SQL

protocol ServersViewControllerDelegate: class {
    
    func serversViewController(_ controller: ServersViewController, didSelect server: Server)
}

class ServersViewController: NSViewController {
    
    @IBOutlet weak var serversTableView: NSTableView!
    @IBOutlet weak var serversArrayController: NSArrayController!
    
    weak var delegate: ServersViewControllerDelegate?
    @objc dynamic fileprivate var servers = [Server]()
    var numOfServers: Int {
        return servers.count
    }
    
    @IBAction func update(server: Server) {
//        if let index = servers.firstIndex(where: { (s) -> Bool in
//            return server.ip == s.ip && server.port == s.port
//        }) {
//            DispatchQueue.main.async {
//                self.servers[index] = server
////                self.serversTableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integersIn: self.serversTableView.tableColumns.indices))
//            }
//        }
    }
    
    func updateServers(with newServers: [Server]) {
        // must do a diff!!!
        
        let toDelete = arrayDifference(between: servers, and: newServers)
        let toAdd = arrayDifference(between: newServers, and: servers)
        
        if !toDelete.isEmpty {
//            servers = servers.filter { existing in
//                return toDelete.contains(where: { toBeDeleted in
//                    return existing.hostname == toBeDeleted.hostname
//                })
//            }
//            servers.(contentsOf: toDelete)
        }
        
        if !toAdd.isEmpty {
//            servers.append(contentsOf: toAdd)
            servers.append(contentsOf: toAdd)
        }
//        DispatchQueue.main.async {
//            self.serversArrayController.content = newServers
//        }
    }
    
    func clearServers() {
        DispatchQueue.main.async {
            self.servers = []
        }
    }
    
    func arrayDifference(between first: [Server], and second: [Server]) -> [Server] {
        return first.filter { existing in
            !second.contains(where: { (new) -> Bool in
                return new.hostname == existing.hostname
            })
        }
    }
}

extension ServersViewController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ aNotification: Notification) {
        
        if let server = serversArrayController.selectedObjects.first as? Server {
            delegate?.serversViewController(self, didSelect: server)
        }
    }
}

