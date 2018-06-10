//
//  TopSplitViewController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 08/06/2018.
//

import Cocoa
import SQL

protocol TopSplitViewControllerDelegate: class {
    
    func didStartFetchingServers(for controller: TopSplitViewController)
    func didFinishFetchingServers(for controller: TopSplitViewController)
}

class TopSplitViewController: NSSplitViewController {
    
    weak var delegate: TopSplitViewControllerDelegate?
    
    private var currentGame: Game?
    fileprivate var coordinator: Coordinator?
    private var servers = [Server]()
    private var filteredServers = [Server]()
    private(set) var selectedServer: Server?
    
    var serversViewController: ServersViewController? {
        return splitViewItems.first?.viewController as? ServersViewController
    }
    
    var spinner: NSProgressIndicator? {
        return serverStatusSplitViewController?.serverRulesViewController?.spinner
    }
    
    var serversLabel: NSTextField? {
        return serverStatusSplitViewController?.playersViewController?.serversLabel
    }
    
    var serverStatusSplitViewController: ServerStatusSplitViewController? {
        return splitViewItems.last?.viewController as? ServerStatusSplitViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serversViewController?.delegate = self
    }
    
    func fetchListOfServers(for game: Game) {
        reset()
        currentGame = game
        coordinator = game.type.coordinator
        coordinator?.delegate = self
        coordinator?.getServersList(host: game.masterServerAddress, port: game.serverPort)
        delegate?.didStartFetchingServers(for: self)
    }
    
    func applyFilters(filterString: String, showEmptyServers: Bool, showFullServers: Bool) {
        
        if filterString.characters.count == 0 {
            filteredServers = Array(servers)
        } else {
            filteredServers = servers.filter({ (serverInfo) -> Bool in
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
        
        if !showEmptyServers {
            filteredServers = filteredServers.filter({ (serverInfo) -> Bool in
                if let current = Int(serverInfo.currentPlayers) {
                    return current > 0
                }
                
                return false
            })
        }
        
        if !showFullServers {
            filteredServers = filteredServers.filter({ (serverInfo) -> Bool in
                return serverInfo.currentPlayers != serverInfo.maxPlayers
            })
        }
        
        serversViewController?.updateServers(filteredServers)
    }
    
    // MARK: - Private methods
    
    private func reset() {
        servers.removeAll()
        filteredServers.removeAll()
        serversViewController?.clearServers()
        serverStatusSplitViewController?.updateStatus(for: nil)
    }
}

extension TopSplitViewController: CoordinatorDelegate {
    
    func didFinishFetchingServersList(for coordinator: Coordinator) {
        coordinator.fetchServersInfo()
    }
    
    func didFinishFetchingServersInfo(for coordinator: Coordinator) {
        DispatchQueue.main.async {
            self.delegate?.didFinishFetchingServers(for: self)
        }
    }
    
    func coordinator(_ coordinator: Coordinator, didFinishFetchingInfoFor server: Server) {
        DispatchQueue.main.async {
            self.servers.append(server)
            self.filteredServers.append(server)
            self.serversViewController?.addServer(server)
        }
    }
    
    func coordinator(_ coordinator: Coordinator, didFinishFetchingStatusFor server: Server) {
        DispatchQueue.main.async {
            self.serverStatusSplitViewController?.updateStatus(for: server)
        }
    }
    
    func coordinator(_ coordinator: Coordinator, didFailWith error: SQLError) {
        
    }
}

extension TopSplitViewController: ServersViewControllerDelegate {
    
    func serversViewController(_ controller: ServersViewController, didSelect server: Server) {
        selectedServer = server
        coordinator?.status(forServer: server)
    }
}
