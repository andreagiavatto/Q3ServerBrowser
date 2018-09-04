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
    
    weak var delegate: ServersViewControllerDelegate?
    fileprivate var servers = [Server]()
    var numOfServers: Int {
        return servers.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serversTableView.allowsMultipleSelection = false
        setupSortDescriptors()
    }
    
    func addServer(_ server: Server) {
        servers.append(server)
        serversTableView.insertRows(at: IndexSet(integer: servers.count - 1), withAnimation: .effectFade)
    }
    
    func update(server: Server) {
        if let index = servers.firstIndex(where: { (s) -> Bool in
            return server.ip == s.ip && server.port == s.port
        }) {
            servers[index] = server
            serversTableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 5))
        }
    }
    
    func updateServers(_ servers: [Server]) {
        clearServers()
        self.servers = servers
        serversTableView.reloadData()
    }
    
    func clearServers() {
        self.servers = []
        serversTableView.reloadData()
    }
    
    private func setupSortDescriptors() {
        
        for (index, column) in serversTableView.tableColumns.enumerated() {
            var sortDescriptor: NSSortDescriptor? = nil
            switch index {
            case 0:
                sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            case 1:
                sortDescriptor = NSSortDescriptor(key: "map", ascending: true)
            case 2:
                sortDescriptor = NSSortDescriptor(key: "mod", ascending: true)
            case 3:
                sortDescriptor = NSSortDescriptor(key: "gametype", ascending: true)
            case 4:
                sortDescriptor = NSSortDescriptor(key: "currentPlayers", ascending: true)
            case 5:
                sortDescriptor = NSSortDescriptor.init(key: "ping", ascending: true, comparator: { (first, second) -> ComparisonResult in
                    if let first = first as? String, let second = second as? String, let f = Int(first), let s = Int(second) {
                        if f > s {
                            return .orderedDescending
                        } else if f == s {
                            return .orderedSame
                        } else {
                            return .orderedAscending
                        }
                    }
                    
                    return .orderedSame
                })
            case 6:
                sortDescriptor = NSSortDescriptor(key: "ip", ascending: true)
            default:
                break
            }
            if let sd = sortDescriptor {
                column.sortDescriptorPrototype = sd
            }
        }
    }
    
    fileprivate func configureViewForServers(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard
            let columnId = tableColumn?.identifier,
            let server = servers[row] as? Server
            else {
                return nil
        }
        
        var text = ""
        var textColor: NSColor?
        
        switch columnId.rawValue {
        case "name":
            text = server.name
        case "map":
            text = server.map
        case "mod":
            text = server.mod
        case "gametype":
            text = server.gametype
        case "players":
            text = "\(server.currentPlayers) / \(server.maxPlayers)"
        case "ping":
            text = server.ping
            if let ping = Int(server.ping) {
                if ping <= 60 {
                    textColor = NSColor(named: "goodPing")
                } else if ping <= 100 {
                    textColor = NSColor(named: "averagePing")
                } else {
                    textColor = NSColor(named: "badPing")
                }
            }
        case "ip":
            text = "\(server.ip):\(server.port)"
        default:
            return nil
        }
        
        if let cell = tableView.makeView(withIdentifier: columnId, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.textField?.textColor = textColor
            return cell
        }
        
        return nil
    }
}

extension ServersViewController: NSTableViewDataSource {
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        
        return servers.count
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        if let sortedServers = (servers as NSArray).sortedArray(using: tableView.sortDescriptors) as? [Server] {
            servers = sortedServers
            serversTableView.reloadData()
        }
    }
}

extension ServersViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        return configureViewForServers(tableView, viewFor: tableColumn, row: row)
    }
    
    func tableViewSelectionDidChange(_ aNotification: Notification) {
        
        let selectedRow = serversTableView.selectedRow

        guard let tableView = aNotification.object as? NSTableView, selectedRow >= 0 else {
            return
        }
        
        let server = servers[selectedRow]
        delegate?.serversViewController(self, didSelect: server)
    }
}
