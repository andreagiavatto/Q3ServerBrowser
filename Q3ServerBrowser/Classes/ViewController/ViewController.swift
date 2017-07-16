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
    @IBOutlet weak var statusTableView: NSTableView!
    @IBOutlet weak var playersTableView: NSTableView!
    @IBOutlet weak var refreshServersItem: NSToolbarItem!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var numOfServersFound: NSTextField!

    private let coordinator = Q3Coordinator()
    private var game = Game(title: "Quake 3 Arena", masterServerAddress: "master.ioquake3.org", serverPort: "27950")
    fileprivate var servers = [Any]()
    fileprivate var players = [Any]()
    fileprivate var status = [AnyHashable: Any]()
    fileprivate var selectedServerIndex: Int = 0

    func windowShouldClose(_ sender: Any) -> Bool {
        NSApp.terminate(nil)
        return true
    }

    override func awakeFromNib() {
        // -- Init data sources
        coordinator.delegate = self
        servers = [Any]()
        players = [Any]()
        status = [AnyHashable: Any]()
        // -- Init label
        numOfServersFound.stringValue = NSLocalizedString("EmptyServersList", comment: "")
    }
    
    // MARK: - Actions
    
    @IBAction func refreshServersList(_ sender: Any) {
        clearDataSource()
        reloadDataSource()
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
            clearDataSource()
            reloadDataSource()
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
        players = [Any]()
        status = [AnyHashable: Any]()
    }

    private func reloadDataSource() {
        serversTableView.reloadData()
        statusTableView.reloadData()
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
    
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingStatusInfo statusInfo: [String : String]) {
//        DispatchQueue.main.async {
//            [unowned self] in
//            if !serverStatus.isEmpty {
//                self.status = serverStatus
//                self.statusTableView.reloadData()
//            }
//        }
    }
    
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingPlayersInfo players: [String]) {
//        DispatchQueue.main.async {
//            [unowned self] in
//            if !serverPlayers.isEmpty {
//                self.players = serverPlayers
//                self.playersTableView.reloadData()
//            }
//        }
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        if aTableView == serversTableView {
            return servers.count
        }
        if aTableView == statusTableView {
            return status.keys.count
        }
        if aTableView == playersTableView {
            return players.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableView == serversTableView {
            return configureViewFor(serversTableView: serversTableView, viewFor: tableColumn, row: row)
        }
        
        return nil
    }
    
    // MARK: - Private methods
    
    private func configureViewFor(serversTableView tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
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
    
//    func tableView(_ aTableView: NSTableView, objectValueFor aTableColumn: NSTableColumn?, row rowIndex: Int) -> Any? {
//        if aTableView == serversTableView {
//            guard let server = (servers[rowIndex] as? ServerInfoProtocol) else { return "" }
//            if (aTableColumn?.identifier == "players") {
//                return "\(server.currentPlayers) / \(server.maxPlayers)"
//            }
//            else {
//                let getter: Selector = NSSelectorFromString(aTableColumn!.identifier)
//                if server.responds(to: getter) {
//                    return server.perform(getter)!
//                }
//            }
//        }
//        if aTableView == statusTableView {
//            let keys: [Any] = status.keys
//            let setting: String? = (keys[rowIndex] as? String)
//            if (aTableColumn.identifier == "Setting") {
//                return setting!
//            }
//            else {
//                return status[setting]
//            }
//        }
//        if aTableView == playersTableView {
//            let player: ServerPlayerProtocol? = (players[rowIndex] as? ServerPlayerProtocol)
//            let getter: Selector = NSSelectorFromString(aTableColumn.identifier)
//            if player?.responds(to: getter) {
//                return player?.perform(getter)!
//            }
//        }
//        return ""
//    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ aTableView: NSTableView, willDisplayCell aCell: Any, for aTableColumn: NSTableColumn?, row rowIndex: Int) {
//        if aTableView == serversTableView {
//            let server: ServerInfoProtocol? = (servers[rowIndex] as? ServerInfoProtocol)
//            let ping = Int(CInt(server?.ping))
//            if (aTableColumn.identifier == "ping") {
//                if ping?.compare(60) == .orderedAscending {
//                    aCell.textColor = kMGTGoodPingColor
//                }
//                else {
//                    if ping?.compare(100) == .orderedAscending {
//                        aCell.textColor = kMGTAveragePingColor
//                    }
//                    else {
//                        aCell.textColor = kMGTBadPingColor
//                    }
//                }
//            }
//        }
    }
    
    func tableViewSelectionDidChange(_ aNotification: Notification) {
//        let tableView: NSTableView? = (aNotification.object as? NSTableView)
//        if tableView == serversTableView {
//            let selectedRow: Int = serversTableView.selectedRow()
//            if selectedRow < servers.count {
//                status = [AnyHashable: Any]()
//                players = [Any]()
//                statusTableView.reloadData()
//                playersTableView.reloadData()
//                let server: ServerInfoProtocol? = (servers[selectedRow] as? ServerInfoProtocol)
//                coordinator?.status(forServer: server)
//            }
//        }
    }
}
