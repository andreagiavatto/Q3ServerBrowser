//
//  WindowController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 08/06/2018.
//

import AppKit
import SQL_Mac

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var refreshServersItem: NSToolbarItem!
    @IBOutlet weak var gameFolderPath: NSPathControl!
    @IBOutlet weak var filterSearchField: NSSearchField!
    @IBOutlet weak var showEmptyButton: NSButton!
    @IBOutlet weak var showFullButton: NSButton!
    @IBOutlet weak var masterServersPopUpButton: NSPopUpButton!
    
    var logsWindowController: LogsWindowController?
    
    private var filterString = ""
    private var currentGame: Game?
    private var currentMasterServer: MasterServer?
    
    private var shouldShowEmptyServers: Bool {
        return showEmptyButton.state == .on
    }
    private var shouldShowFullServers: Bool {
        return showFullButton.state == .on
    }
    private var splitViewController: TopSplitViewController? {
        return contentViewController as? TopSplitViewController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        splitViewController?.delegate = self
    }

    func selectGame(_ game: Game) {
        guard game.type != currentGame?.type else {
            return
        }
        currentGame = game
        splitViewController?.reset()
        window?.title = game.name
        splitViewController?.serversLabel?.stringValue = NSLocalizedString("EmptyServersList", comment: "")
        let masterServers = game.masterServers
        guard !masterServers.isEmpty else {
            return
        }
        masterServersPopUpButton.removeAllItems()
        masterServersPopUpButton.addItems(withTitles: masterServers.map { $0.description })
        masterServersPopUpButton.selectItem(at: 0)
        selectMasterServer(at: 0)
    }
    
    // MARK: - IBActions
    
    @IBAction func refreshServersList(_ sender: Any) {
        guard let currentMasterServer = currentMasterServer, let currentGame = currentGame else {
            return
        }
        if let servers = Settings.shared.getServers(for: currentGame, from: currentMasterServer), servers.count > 0 {
            splitViewController?.refreshServers(for: currentGame, with: servers, from: currentMasterServer)
        } else {
            splitViewController?.fetchListOfServers(for: currentGame, from: currentMasterServer)
        }
    }
    
    @IBAction func changeMasterServer(_ sender: NSPopUpButton) {
        selectMasterServer(at: sender.indexOfSelectedItem)
    }

    @IBAction func connectToServer(_ sender: Any) {
        guard let server = splitViewController?.selectedServer, let currentGame = currentGame else {
            displayAlert(message: NSLocalizedString("AlertNoServersMessage", comment: ""), informativeText: NSLocalizedString("AlertNoServersMessageInformative", comment: ""))
            return
        }
        guard let pathToFolder = gameFolderPath.url else {
            displayAlert(message: NSLocalizedString("AlertAppNotFoundMessage", comment: ""), informativeText: NSLocalizedString("AlertAppNotFoundMessageInformative", comment: ""))
            return
        }

        if logsWindowController == nil {
            logsWindowController = NSStoryboard(name: "Main", bundle: Bundle.main).instantiateController(withIdentifier: "LogsWindowControllerID") as? LogsWindowController
        }

        let folderPathString = pathToFolder.path
        logsWindowController?.showWindow(self)
        logsWindowController?.connect(to: server, forGame: currentGame, atPath: folderPathString)
    }

    @IBAction func filterServers(_ sender: NSSearchField) {
        filterString = sender.stringValue.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        splitViewController?.applyFilters(filterString: filterString, showEmptyServers: shouldShowEmptyServers, showFullServers: shouldShowFullServers)
    }

    @IBAction func showEmptyButtonValueChanged(_ sender: NSButton) {
        splitViewController?.applyFilters(filterString: filterString, showEmptyServers: shouldShowEmptyServers, showFullServers: shouldShowFullServers)
    }

    @IBAction func showFullButtonValueChanged(_ sender: NSButton) {
        splitViewController?.applyFilters(filterString: filterString, showEmptyServers: shouldShowEmptyServers, showFullServers: shouldShowFullServers)
    }

    func selectMasterServer(at index: Int) {
        guard let currentGame = currentGame, index >= 0 && index < currentGame.masterServers.count else {
            return
        }
        currentMasterServer = currentGame.masterServers[index]
    }
}

extension MainWindowController: TopSplitViewControllerDelegate {

    func didStartFetchingServers(for controller: TopSplitViewController) {
        splitViewController?.serversLabel?.stringValue = "Fetching servers..."
        splitViewController?.spinner?.startAnimation(self)
    }
    
    func didFinishFetchingServers(for controller: TopSplitViewController) {
        splitViewController?.spinner?.stopAnimation(self)
        (NSApplication.shared.delegate as? AppDelegate)?.updateMenuItemsStatuses()
    }
}
