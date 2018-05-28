//
//  ViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 19/09/10.
//  Copyright 2010 Andrea Giavatto. All rights reserved.
//

import Cocoa
import SQL

class ViewController: NSObject {
    
    @IBOutlet weak var serversTableView: NSTableView!
    @IBOutlet weak var rulesTableView: NSTableView!
    @IBOutlet weak var playersTableView: NSTableView!
    @IBOutlet weak var refreshServersItem: NSToolbarItem!
    @IBOutlet weak var connectItem: NSToolbarItem!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var numOfServersFound: NSTextField!
    @IBOutlet weak var quake3FolderPath: NSPathControl!
    @IBOutlet weak var filterSearchField: NSSearchField!
    @IBOutlet weak var showEmptyButton: NSButton!
    @IBOutlet weak var showFullButton: NSButton!

    private var game = Game(title: "Quake 3 Arena", masterServerAddress: "master.ioquake3.org", serverPort: "27950")
    fileprivate let coordinator = Q3Coordinator()
    fileprivate var filteredServers = [Server]()
    fileprivate var filterString = ""
    fileprivate var selectedServer: Server?

    func windowShouldClose(_ sender: Any) -> Bool {
        NSApp.terminate(nil)
        return true
    }

    override func awakeFromNib() {
        // -- Init data sources
        coordinator.delegate = self
        serversTableView.allowsMultipleSelection = false
        reset()
        
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
    
    // MARK: - Actions
    
    @IBAction func refreshServersList(_ sender: Any) {
        reset()
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
            reset()
        }
    }
    
    @IBAction func connectToServer(_ sender: Any) {
        let row = serversTableView.selectedRow
        
        guard row >= 0 && row < filteredServers.count else {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = NSLocalizedString("AlertNoServersMessage", comment: "")
            alert.informativeText = NSLocalizedString("AlertNoServersMessageInformative", comment: "")
            alert.alertStyle = .warning
            alert.runModal()
            return
        }
        let serverInfo = filteredServers[row]
        let pathToFolder = quake3FolderPath.url
        
        if let folderURLString = pathToFolder?.path {
            let executableURLString = folderURLString.appending("/ioquake3-1.36.app/Contents/MacOS/ioquake3.ub")
            let process = Process()
            let pipe = Pipe()

            process.launchPath = executableURLString
            process.arguments = ["+connect", "\(serverInfo.ip):\(serverInfo.port)"]
            do {
                try process.launch()
                process.standardOutput = pipe
                process.launch()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)
            } catch(let error) {

                let alert = NSAlert()
                alert.addButton(withTitle: "OK")
                alert.messageText = NSLocalizedString("AlertAppNotFoundMessage", comment: "")
                alert.informativeText = NSLocalizedString("AlertAppNotFoundMessageInformative", comment: "")
                alert.alertStyle = .warning
                alert.runModal()
            }
        }
    }
    
    @IBAction func filterServers(_ sender: NSSearchField) {
        filterString = sender.stringValue.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        applyFilters(filterString: filterString, showEmpty: showEmptyButton.state == .on, showFull: showFullButton.state == .on)
    }
    
    @IBAction func showEmptyButtonValueChanged(_ sender: NSButton) {
        applyFilters(filterString: filterString, showEmpty: showEmptyButton.state == .on, showFull: showFullButton.state == .on)
    }
    
    @IBAction func showFullButtonValueChanged(_ sender: NSButton) {
        applyFilters(filterString: filterString, showEmpty: showEmptyButton.state == .on, showFull: showFullButton.state == .on)
    }

    // MARK: - Private methods
    private func reset() {
        clearDataSource()
        reloadDataSource()
        filterSearchField.stringValue = ""
        loadingIndicator.stopAnimation(self)
        numOfServersFound.stringValue = NSLocalizedString("EmptyServersList", comment: "")
    }
    
    private func clearDataSource() {
        filterString = ""
        selectedServer = nil
        filteredServers.removeAll()
    }
    
    private func reloadList() {
        reloadDataSource()
        numOfServersFound.stringValue = "\(self.filteredServers.count) servers found."
    }

    private func reloadDataSource() {
        serversTableView.reloadData()
        rulesTableView.reloadData()
        playersTableView.reloadData()
    }
    
    private func applyFilters(filterString: String, showEmpty: Bool, showFull: Bool) {
        if filterString.characters.count == 0 {
            filteredServers = Array(coordinator.serversList)
        } else {
            filteredServers = coordinator.serversList.filter({ (serverInfo) -> Bool in
                let standardMatcher = serverInfo.name.lowercased().range(of: filterString) != nil ||
                    serverInfo.map.lowercased().range(of: filterString) != nil ||
                    serverInfo.mod.lowercased().range(of: filterString) != nil ||
                    serverInfo.gametype.lowercased().range(of: filterString) != nil ||
                    serverInfo.ip.lowercased().range(of: filterString) != nil
                var playerMatcher = false
                if let players = serverInfo.players {
                    playerMatcher = players.contains(where: { (player) -> Bool in
                        return player.name.lowercased().range(of: filterString) != nil
                    })
                }
                return standardMatcher || playerMatcher
            })
        }
        
        if !showEmpty {
            filteredServers = filteredServers.filter({ (serverInfo) -> Bool in
                if let current = Int(serverInfo.currentPlayers) {
                    return current > 0
                }
                
                return false
            })
        }
        
        if !showFull {
            filteredServers = filteredServers.filter({ (serverInfo) -> Bool in
                return serverInfo.currentPlayers != serverInfo.maxPlayers
            })
        }
        
        numOfServersFound.stringValue = "\(self.filteredServers.count) servers found."
        reloadDataSource()
    }
    
    fileprivate func index(of server: Server) -> Int? {
        for (index, s) in filteredServers.enumerated() {
            if s.ip == server.ip && s.port == server.port {
                return index
            }
        }
        return nil
    }
}

extension ViewController: CoordinatorDelegate {
    
    func didFinishRequestingServers(for coordinator: CoordinatorProtocol) {
        self.coordinator.requestServersInfo()
    }
    
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingInfo forServerInfo: Server) {
        DispatchQueue.main.async {
            self.filteredServers.append(forServerInfo)
            self.reloadList()
            self.loadingIndicator.stopAnimation(self)
        }
    }
    
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingStatus forServerInfo: Server) {
        DispatchQueue.main.async {
            self.rulesTableView.reloadData()
            self.playersTableView.reloadData()
        }
    }
    
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishWithError error: Error?) {
        
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        if aTableView == serversTableView {
            return filteredServers.count
        }
        
        guard let server = selectedServer else {
            return 0
        }
        
        if aTableView == rulesTableView {
            return server.rules.keys.count
        }
        if aTableView == playersTableView, let players = server.players {
            return players.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableView == serversTableView {
            return configureViewForServers(serversTableView, viewFor: tableColumn, row: row)
        }
        
        if tableView == rulesTableView {
            return configureViewForRules(rulesTableView, viewFor: tableColumn, row: row)
        }
        
        if tableView == playersTableView {
            return configureViewForPlayers(playersTableView, viewFor: tableColumn, row: row)
        }
        
        return nil
    }
    
    // MARK: - Private methods
    
    private func configureViewForServers(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard
            let columnId = tableColumn?.identifier,
            let server = filteredServers[row] as? Server
            else {
                return nil
        }
        
        var text = ""
        var textColor = NSColor.black
        
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
                    textColor = kMGTGoodPingColor
                } else if ping <= 100 {
                    textColor = kMGTAveragePingColor
                } else {
                    textColor = kMGTBadPingColor
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
    
    private func configureViewForRules(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard
            let server = selectedServer,
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
    
    private func configureViewForPlayers(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard
            let server = selectedServer,
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

extension ViewController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ aNotification: Notification) {
        
        guard
            let tableView = aNotification.object as? NSTableView
        else {
            return
        }
        
        if tableView == serversTableView {
            let selectedRow = serversTableView.selectedRow
            selectedServer = filteredServers[selectedRow]
            if let server = selectedServer {
                coordinator.status(forServer: server)
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        if let sortedServers = (self.filteredServers as NSArray).sortedArray(using: tableView.sortDescriptors) as? [Server] {
            filteredServers = sortedServers
            reloadDataSource()
        }
    }
}
