//
//  WindowController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 08/06/2018.
//

import AppKit
import SQL

class WindowController: NSWindowController {
    
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var refreshServersItem: NSToolbarItem!
    @IBOutlet weak var quake3FolderPath: NSPathControl!
    @IBOutlet weak var filterSearchField: NSSearchField!
    @IBOutlet weak var showEmptyButton: NSButton!
    @IBOutlet weak var showFullButton: NSButton!
    
    private var filterString = ""
    private var currentGame = Game(type: .quake3, masterServerAddress: "master.ioquake3.org", serverPort: "27950")
    
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
        
        guard let pathToFolder = quake3FolderPath.url else {
            displayNoBinarySelectedForGameAlert()
            return
        }
        
        let folderURLString = pathToFolder.path
        let executableURLString = folderURLString.appending("/ioquake3-1.36.app/Contents/MacOS/ioquake3.ub")
        
        let process = Process()
        let pipe = Pipe()
        
        process.launchPath = executableURLString
        process.arguments = ["+connect", "\(server.ip):\(server.port)"]
        process.standardOutput = pipe
        
        do {
            try process.launch()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)
        } catch(let error) {
            displayBinaryLaunchError(error)
        }
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
    
    private func displayBinaryLaunchError(_ error: Error) {
        
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("AlertAppNotLaunchedMessage", comment: "")
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

extension WindowController: TopSplitViewControllerDelegate {
    
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
