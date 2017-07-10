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
    fileprivate var servers = [Any]()
    fileprivate var players = [Any]()
    fileprivate var status = [AnyHashable: Any]()
    fileprivate var selectedServerIndex: Int = 0

    @IBAction func refreshServersList(_ sender: Any) {
        clearDataSource()
        reloadDataSource()
        coordinator.refreshServersList()
        loadingIndicator.startAnimation(self)
    }

    func windowShouldClose(_ sender: Any) -> Bool {
        NSApp.terminate(nil)
        return true
    }

    override func awakeFromNib() {
        // -- Init data sources
        servers = [Any]()
        players = [Any]()
        status = [AnyHashable: Any]()
        // -- Init label
        numOfServersFound.stringValue = NSLocalizedString("EmptyServersList", comment: "")
    }

    // MARK: - Private methods
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
    
    func didFinishFetchingInfo(forServer serverInfo: ServerInfoProtocol) {
        DispatchQueue.main.async {
            [unowned self] in
            print(serverInfo)
            self.servers.append(serverInfo)
            self.loadingIndicator.stopAnimation(self)
            self.numOfServersFound.stringValue = "\(self.servers.count) servers found."
            self.serversTableView.reloadData()
        }
    }
    
    func didFinishFetchingStatus(forServer serverStatus: [AnyHashable: Any]) {
        DispatchQueue.main.async {
            [unowned self] in
            if !serverStatus.isEmpty {
                self.status = serverStatus
                self.statusTableView.reloadData()
            }
        }
    }
    
    func didFinishFetchingPlayers(forServer serverPlayers: [Any]) {
        DispatchQueue.main.async {
            [unowned self] in
            if !serverPlayers.isEmpty {
                self.players = serverPlayers
                self.playersTableView.reloadData()
            }
        }
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
//        if aTableView == serversTableView {
//            return servers.count
//        }
//        if aTableView == statusTableView {
//            return status.keys.count
//        }
//        if aTableView == playersTableView {
//            return players.count
//        }
        return 0
    }
    
    func tableView(_ aTableView: NSTableView, objectValueFor aTableColumn: NSTableColumn?, row rowIndex: Int) -> Any? {
//        if aTableView == serversTableView {
//            let server: ServerInfoProtocol? = (servers[rowIndex] as? ServerInfoProtocol)
//            if (aTableColumn.identifier == "players") {
//                return "\(server?.currentPlayers) / \(server?.maxPlayers)"!
//            }
//            else {
//                let getter: Selector = NSSelectorFromString(aTableColumn.identifier)
//                if server?.responds(to: getter) {
//                    return server?.perform(getter)!
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
        return ""
    }
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
