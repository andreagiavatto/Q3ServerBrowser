//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  ViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 19/09/10.
//  Copyright 2010 Andrea Giavatto. All rights reserved.
//

import Cocoa

class ViewController: NSObject {
    
    @IBOutlet weak var serversTableView: NSTableView!
    @IBOutlet weak var rulesTableView: NSTableView!
    @IBOutlet weak var playersTableView: NSTableView!
    @IBOutlet weak var refreshServersItem: NSToolbarItem!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var numOfServersFound: NSTextField!

    private var game = Game(title: "Quake 3 Arena", masterServerAddress: "master.ioquake3.org", serverPort: "27950")
    fileprivate let coordinator = Q3Coordinator()
    fileprivate var servers = [ServerInfoProtocol]()
    fileprivate var players = [Q3ServerPlayer]()
    fileprivate var rules = [String: String]()
    fileprivate var selectedServerIndex: Int = 0

    func windowShouldClose(_ sender: Any) -> Bool {
        NSApp.terminate(nil)
        return true
    }

    override func awakeFromNib() {
        // -- Init data sources
        coordinator.delegate = self
        clearUI()
    }
    
    // MARK: - Actions
    
    @IBAction func refreshServersList(_ sender: Any) {
        clearUI()
        coordinator.refreshServersList(host: game.masterServerAddress, port: game.serverPort)
        loadingIndicator.startAnimation(self)
    }
    
    @IBAction func didChangeMasterServer(_ sender: NSComboBox) {
        if let selected = sender.objectValueOfSelectedItem as? String {
            let newMaster = selected.components(separatedBy: ":")
            let host = newMaster.first!
            let port = newMaster.last!
            game.masterServerAddress = host
            game.serverPort = port
            clearUI()
        }
    }

    // MARK: - Private methods
    private func clearUI() {
        clearDataSource()
        reloadDataSource()
        self.loadingIndicator.stopAnimation(self)
        numOfServersFound.stringValue = NSLocalizedString("EmptyServersList", comment: "")
    }
    
    private func clearDataSource() {
        servers.removeAll()
        players.removeAll()
        rules.removeAll()
    }

    private func reloadDataSource() {
        serversTableView.reloadData()
        rulesTableView.reloadData()
        playersTableView.reloadData()
    }
}

extension ViewController: CoordinatorDelegate {
    
    func didFinishRequestingServers(for coordinator: CoordinatorProtocol) {
        self.loadingIndicator.stopAnimation(self)
    }
    
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishWithError error: Error?) {
        self.loadingIndicator.stopAnimation(self)
    }
    
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingServerInfo serverInfo: ServerInfoProtocol) {
        DispatchQueue.main.async {
            [unowned self] in
            self.servers.append(serverInfo)
            self.numOfServersFound.stringValue = "\(self.servers.count) servers found."
            self.serversTableView.reloadData()
        }
    }
    
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingStatusInfo statusInfo: (rules: [String : String], players: [Q3ServerPlayer])?, for ip: String) {
        
        DispatchQueue.main.async {
            [unowned self] in
            if let statusInfo = statusInfo {
                self.rules = statusInfo.rules
                self.rulesTableView.reloadData()
                self.players = statusInfo.players
                self.playersTableView.reloadData()
            }
        }
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        if aTableView == serversTableView {
            return servers.count
        }
        if aTableView == rulesTableView {
            return rules.keys.count
        }
        if aTableView == playersTableView {
            return players.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableView == serversTableView {
            return configureViewForServers(serversTableView, viewFor: tableColumn, row: row)
        }
        
        if tableView == rulesTableView {
            return configureViewForRules(serversTableView, viewFor: tableColumn, row: row)
        }
        
        if tableView == playersTableView {
            return configureViewForPlayers(serversTableView, viewFor: tableColumn, row: row)
        }
        
        return nil
    }
    
    // MARK: - Private methods
    
    private func configureViewForServers(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard
            let columnId = tableColumn?.identifier,
            let serverInfo = servers[row] as? ServerInfoProtocol
            else {
                return nil
        }
        
        var text = ""
        switch columnId {
        case "hostname":
            text = serverInfo.hostname
        case "map":
            text = serverInfo.map
        case "mod":
            text = serverInfo.mod
        case "gametype":
            text = serverInfo.gametype
        case "players":
            text = "\(serverInfo.currentPlayers) / \(serverInfo.maxPlayers)"
        case "ping":
            text = serverInfo.ping
        case "ip":
            text = "\(serverInfo.ip):\(serverInfo.port)"
        default:
            return nil
        }
        
        if let cell = tableView.make(withIdentifier: columnId, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }
    
    private func configureViewForRules(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard
            let columnId = tableColumn?.identifier,
            let key = Array(rules.keys)[row] as? String,
            let value = rules[key] as? String
        else {
            return nil
        }
        
        var text = ""
        switch columnId {
        case "setting":
            text = key
        case "value":
            text = value
        default:
            return nil
        }
        
        if let cell = tableView.make(withIdentifier: columnId, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }
    
    private func configureViewForPlayers(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard
            let columnId = tableColumn?.identifier,
            let player = players[row] as? Q3ServerPlayer
            else {
                return nil
        }
        
        var text = ""
        switch columnId {
        case "name":
            text = player.name
        case "ping":
            text = player.ping
        case "score":
            text = player.score
        default:
            return nil
        }
        
        if let cell = tableView.make(withIdentifier: columnId, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }
}

extension ViewController: NSTableViewDelegate {
    
//    func tableView(_ tableView: NSTableView, willDisplayCell cell: NSTableCellView, for tableColumn: NSTableColumn?, row: Int) {
//        
//        if tableView == serversTableView {
//            if
//                let server = servers[row] as? ServerInfoProtocol,
//                let ping = Int(server.ping)
//            {
//                if (tableView.identifier == "ping") {
//                    if ping <= 60 {
//                        cell.textField?.textColor = kMGTGoodPingColor
//                    } else if ping <= 100 {
//                        cell.textField?.textColor = kMGTAveragePingColor
//                    } else {
//                        cell.textField?.textColor = kMGTBadPingColor
//                    }
//                }
//            }
//        }
//    }
    
    func tableViewSelectionDidChange(_ aNotification: Notification) {
        
        guard let tableView = aNotification.object as? NSTableView else { return }
        if tableView == serversTableView {
            let selectedRow = serversTableView.selectedRow
            if selectedRow < servers.count {
                rules.removeAll()
                players.removeAll()
                rulesTableView.reloadData()
                playersTableView.reloadData()
                if let server = servers[selectedRow] as? ServerInfoProtocol {
                    coordinator.status(forServer: server)
                }
            }
        }
    }
}
