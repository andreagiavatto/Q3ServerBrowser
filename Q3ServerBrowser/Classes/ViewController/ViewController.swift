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

    private var game = Game(title: "Quake 3 Arena", masterServerAddress: "master.ioquake3.org", serverPort: "27950")
    fileprivate let coordinator = Q3Coordinator()
    fileprivate var servers = [ServerInfoProtocol]()
    fileprivate var filteredServers = [ServerInfoProtocol]()
    fileprivate var filterString = ""
    fileprivate var players = [Q3ServerPlayer]()
    fileprivate var rules = [String: String]()
    fileprivate var selectedServerIndex: Int?

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
                print(error)
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
        filterString = sender.stringValue.lowercased()

        if filterString.characters.count == 0 {
            filteredServers = Array(servers)
        } else {
            filteredServers = servers.filter({ (serverInfo) -> Bool in
                return serverInfo.hostname.lowercased().range(of: filterString) != nil ||
                        serverInfo.map.lowercased().range(of: filterString) != nil ||
                        serverInfo.mod.lowercased().range(of: filterString) != nil ||
                        serverInfo.gametype.lowercased().range(of: filterString) != nil ||
                        serverInfo.ip.lowercased().range(of: filterString) != nil
            })
        }
        self.numOfServersFound.stringValue = "\(self.filteredServers.count) servers found."
        reloadDataSource()
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
            self.filteredServers.append(serverInfo)
            self.numOfServersFound.stringValue = "\(self.filteredServers.count) servers found."
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
            return filteredServers.count
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
        
        guard
            let columnId = tableColumn?.identifier,
            let key = Array(rules.keys)[row] as? String,
            let value = rules[key] as? String
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
            let columnId = tableColumn?.identifier,
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
                rules.removeAll()
                players.removeAll()
                rulesTableView.reloadData()
                playersTableView.reloadData()
                if let server = filteredServers[selectedRow] as? ServerInfoProtocol {
                    coordinator.status(forServer: server)
                }
            }
        }
    }
}
