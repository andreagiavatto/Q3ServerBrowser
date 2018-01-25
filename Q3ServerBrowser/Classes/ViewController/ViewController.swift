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
    @IBOutlet weak var connectItem: NSToolbarItem!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var numOfServersFound: NSTextField!
    @IBOutlet weak var quake3FolderPath: NSPathControl!
    @IBOutlet weak var filterSearchField: NSSearchField!
    @IBOutlet weak var showEmptyButton: NSButton!
    @IBOutlet weak var showFullButton: NSButton!

    private var game = Game(title: "Quake 3 Arena", masterServerAddress: "master.ioquake3.org", serverPort: "27950")
    fileprivate let coordinator = Q3Coordinator()
    fileprivate var servers = [ServerInfoProtocol]()
    fileprivate var filteredServers = [ServerInfoProtocol]()
    fileprivate var filterString = ""
    fileprivate var selectedServerIndex: Int?

    func windowShouldClose(_ sender: Any) -> Bool {
        NSApp.terminate(nil)
        return true
    }

    override func awakeFromNib() {
        // -- Init data sources
        coordinator.delegate = self
        serversTableView.allowsMultipleSelection = false
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
    private func clearUI() {
        clearDataSource()
        reloadDataSource()
        filterSearchField.stringValue = ""
        loadingIndicator.stopAnimation(self)
        numOfServersFound.stringValue = NSLocalizedString("EmptyServersList", comment: "")
    }
    
    private func clearDataSource() {
        filterString = ""
        servers.removeAll()
        filteredServers.removeAll()
    }
    
    private func reloadList() {
        servers = coordinator.serversList
        filteredServers = coordinator.serversList
        reloadDataSource()
        numOfServersFound.stringValue = "\(self.filteredServers.count) servers found."
    }

    private func reloadDataSource() {
        reloadServersDataKeepingSelection()
        rulesTableView.reloadData()
        playersTableView.reloadData()
    }
    
    private func applyFilters(filterString: String, showEmpty: Bool, showFull: Bool) {
        if filterString.characters.count == 0 {
            filteredServers = Array(servers)
        } else {
            filteredServers = servers.filter({ (serverInfo) -> Bool in
                let standardMatcher = serverInfo.hostname.lowercased().range(of: filterString) != nil ||
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
    
    fileprivate func reloadServersDataKeepingSelection() {
        serversTableView.reloadData()
        if let selectedIndex = selectedServerIndex {
            serversTableView.selectRowIndexes([selectedIndex], byExtendingSelection: false)
        }
    }
    
    fileprivate func index(of server: ServerInfoProtocol) -> Int? {
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
        DispatchQueue.main.async {
            self.reloadList()
            self.coordinator.requestServersInfo()
        }
    }
    
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingInfo forServerInfo: ServerInfoProtocol) {
        DispatchQueue.main.async {
            if let index = self.index(of: forServerInfo) {
                let columnIndexes = self.serversTableView.columnIndexes(in: self.serversTableView.bounds)
                self.serversTableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: columnIndexes)
            }
            if let last = self.filteredServers.last, forServerInfo.ip == last.ip, forServerInfo.port == last.port {
                self.loadingIndicator.stopAnimation(self)
            }
        }
    }
    
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingStatus forServerInfo: ServerInfoProtocol) {
        DispatchQueue.main.async {
            if let index = self.index(of: forServerInfo) {
                let columnIndexes = self.serversTableView.columnIndexes(in: self.serversTableView.bounds)
                self.serversTableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: columnIndexes)
            }
            self.rulesTableView.reloadData()
            self.playersTableView.reloadData()
        }
    }
    
    func coordinator(_ coordinator: CoordinatorProtocol, didTimeoutFetchingInfo forServerInfo: ServerInfoProtocol) {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimation(self)
            self.reloadList()
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
        
        guard serversTableView.selectedRow >= 0, serversTableView.selectedRow < filteredServers.count else {
            return 0
        }
        
        let server = filteredServers[serversTableView.selectedRow]
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
            let serverInfo = filteredServers[row] as? ServerInfoProtocol
            else {
                return nil
        }
        
        var text = ""
        var textColor = NSColor.black
        
        switch columnId.rawValue {
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
            if let ping = Int(serverInfo.ping) {
                if ping <= 60 {
                    textColor = kMGTGoodPingColor
                } else if ping <= 100 {
                    textColor = kMGTAveragePingColor
                } else {
                    textColor = kMGTBadPingColor
                }
            }
        case "ip":
            text = "\(serverInfo.ip):\(serverInfo.port)"
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
        
        let server = filteredServers[serversTableView.selectedRow]
        
        guard
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
        
        let server = filteredServers[serversTableView.selectedRow]
        
        guard
            let columnId = tableColumn?.identifier,
            let players = server.players,
            let player = players[row] as? Q3ServerPlayer
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
            if selectedServerIndex == nil || (selectedServerIndex != nil && selectedServerIndex! != selectedRow && selectedRow < filteredServers.count) {
                selectedServerIndex = selectedRow
                if let server = filteredServers[selectedRow] as? ServerInfoProtocol {
                    coordinator.status(forServer: server)
                }
            }
        }
    }
}
