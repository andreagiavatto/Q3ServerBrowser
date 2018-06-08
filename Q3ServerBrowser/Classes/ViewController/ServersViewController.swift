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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serversTableView.allowsMultipleSelection = false
        setupSortDescriptors()
    }
    
    func addServer(_ server: Server) {
        servers.append(server)
        serversTableView.insertRows(at: IndexSet(integer: servers.count - 1), withAnimation: .effectFade)
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
                sortDescriptor = NSSortDescriptor(key: "ping", ascending: true)
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
                    textColor = NSColor(named: NSColor.Name(rawValue: "goodPing"))
                } else if ping <= 100 {
                    textColor = NSColor(named: NSColor.Name(rawValue: "averagePing"))
                } else {
                    textColor = NSColor(named: NSColor.Name(rawValue: "badPing"))
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
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        return configureViewForServers(serversTableView, viewFor: tableColumn, row: row)
    }
}

extension ServersViewController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ aNotification: Notification) {
        
        guard let tableView = aNotification.object as? NSTableView else {
            return
        }
        
        let selectedRow = serversTableView.selectedRow
        let server = servers[selectedRow]
        delegate?.serversViewController(self, didSelect: server)
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        if let sortedServers = (servers as NSArray).sortedArray(using: tableView.sortDescriptors) as? [Server] {
            servers = sortedServers
            serversTableView.reloadData()
        }
    }
}
