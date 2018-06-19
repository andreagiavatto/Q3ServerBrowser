//
//  WindowController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 08/06/2018.
//

import AppKit
import SQL

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var refreshServersItem: NSToolbarItem!
    @IBOutlet weak var gameFolderPath: NSPathControl!
    @IBOutlet weak var filterSearchField: NSSearchField!
    @IBOutlet weak var showEmptyButton: NSButton!
    @IBOutlet weak var showFullButton: NSButton!
    
    var logsWindowController: LogsWindowController?
    
    private var filterString = ""
    private var currentGame = Game(type: .quake3, masterServerAddress: "master.ioquake3.org", serverPort: "27950", launchArguments: "+connect")
    
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
        
        window?.title = "Q3ServerBrowser"
        splitViewController?.serversLabel?.stringValue = NSLocalizedString("EmptyServersList", comment: "")
        splitViewController?.delegate = self
    }
    
    // MARK: - IBActions
    
    @IBAction func refreshServersList(_ sender: Any) {
        
        splitViewController?.fetchListOfServers(for: currentGame)
    }
    
    @IBAction func changeMasterServer(_ sender: NSPopUpButton) {
        
        guard let newMasterServerAddress = sender.selectedItem?.title else {
            return
        }
        
        let newMasterServer = newMasterServerAddress.components(separatedBy: ":")
        
        guard let host = newMasterServer.first, let port = newMasterServer.last else {
            return
        }
        
        currentGame.masterServerAddress = host
        currentGame.serverPort = port
    }
    
    @IBAction func connectToServer(_ sender: Any) {
        
        guard let server = splitViewController?.selectedServer else {
            displayNoSelectedServerAlert()
            return
        }
        
        guard let pathToFolder = gameFolderPath.url else {
            displayNoBinarySelectedForGameAlert()
            return
        }
        
        if logsWindowController == nil {
            logsWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle.main).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "LogsWindowControllerID")) as? LogsWindowController
        }
        
        let folderPathString = pathToFolder.path
        logsWindowController?.window?.makeKeyAndOrderFront(self)
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
    
    // MARK: - Private methods
    
    private func displayNoSelectedServerAlert() {
        
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("AlertNoServersMessage", comment: "")
        alert.informativeText = NSLocalizedString("AlertNoServersMessageInformative", comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func displayNoBinarySelectedForGameAlert() {
        
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("AlertAppNotFoundMessage", comment: "")
        alert.informativeText = NSLocalizedString("AlertAppNotFoundMessageInformative", comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

extension MainWindowController: TopSplitViewControllerDelegate {
    
    func didStartFetchingServers(for controller: TopSplitViewController) {
        
        window?.title = "\(currentGame.masterServerAddress):\(currentGame.serverPort)"
        splitViewController?.serversLabel?.stringValue = "Fetching servers..."
        splitViewController?.spinner?.startAnimation(self)
        toolbar.items.map({ $0.isEnabled = false })
    }
    
    func didFinishFetchingServers(for controller: TopSplitViewController) {
        
        toolbar.items.map({ $0.isEnabled = true })
        splitViewController?.serversLabel?.stringValue = "\(splitViewController?.serversViewController?.numOfServers ?? 0) servers found."
        splitViewController?.spinner?.stopAnimation(self)
    }
}
