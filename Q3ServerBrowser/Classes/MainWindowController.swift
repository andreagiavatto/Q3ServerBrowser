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
    
    weak var logsWindowController: LogsWindowController?
    
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
            logsWindowController?.showWindow(self)
        }
        
        let folderPathString = pathToFolder.path
        connect(to: server, forGame: currentGame, atPath: folderPathString)
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
    
    private func connect(to server: Server, forGame game: Game, atPath path: String) {
        
        let appBundle = Bundle(path: path)
        let executablePath = appBundle?.executablePath
        
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.launchPath = executablePath
        process.arguments = [game.launchArguments, "\(server.ip):\(server.port)"]
        process.standardInput = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.terminationHandler = { terminatedProcess in
            DispatchQueue.main.async {
                self.logsWindowController?.append("\n----")
            }
        }
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if data.count > 0 {
                self.processLogData(data)
                handle.waitForDataInBackgroundAndNotify()
            }
        }
        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if data.count > 0 {
                self.processLogData(data)
                handle.waitForDataInBackgroundAndNotify()
            }
        }
        
        do {
            try process.launch()
        } catch(let error) {
            displayBinaryLaunchError(error)
        }
    }
    
    private func processLogData(_ data: Data) {
        
        guard let outputString = String(data: data, encoding: .utf8) else {
            return
        }

        DispatchQueue.main.async(execute: {
            self.logsWindowController?.append("\n" + outputString)
        })
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
