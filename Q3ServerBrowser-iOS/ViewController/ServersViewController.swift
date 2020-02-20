//
//  ServersViewController.swift
//  Q3ServerBrowser-iOS
//
//  Created by HLR on 11/11/2018.
//

import UIKit
import SQL_iOS

class ServersViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    private let serversRefreshControl = UIRefreshControl()
    private let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private var currentGame = Game(type: .quake3)
    private var currentMasterServer: MasterServer?
    private var coordinator: Coordinator?
    private let searchController = UISearchController(searchResultsController: nil)
    fileprivate var servers = [Server]()
    fileprivate var filteredServers = [Server]()
    fileprivate var cachedColors = [NSAttributedString]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        currentMasterServer = currentGame.masterServers.first
        coordinator = currentGame.type.coordinator
        coordinator?.delegate = self
        setupUI()
        setupSearchController()
        refreshServersForCurrentMaster()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "showServerInfoSegueIdentifier",
            let serverInfoViewController = segue.destination as? ServerInfoViewController,
            let cell = sender as? ServersTableViewCell,
            let indexPath = tableView.indexPath(for: cell)
        else {
            return
        }
        let selectedServer = filteredServers[indexPath.row]
        serverInfoViewController.server = selectedServer
        serverInfoViewController.currentGame = currentGame
    }

    private func setupUI() {
        title = currentMasterServer?.hostname
        activityIndicatorView.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        serversRefreshControl.addTarget(self, action: #selector(refreshServersForCurrentMaster), for: .valueChanged)
        tableView.addSubview(serversRefreshControl)
    }

    private func reset() {
        servers.removeAll()
        filteredServers.removeAll()
        cachedColors.removeAll()
        tableView.reloadData()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find a server"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func isMatch(server: Server, forFilter filter: String?) -> Bool {
        guard let filter = filter, !filter.isEmpty else {
            return true
        }
        return server.name.localizedCaseInsensitiveContains(filter)
    }
    
    private func filterServersForSearchText(_ searchText: String?) {
        filteredServers.removeAll()
        cachedColors.removeAll()
        guard let searchText = searchText, !searchText.isEmpty else {
            filteredServers.append(contentsOf: servers)
            cachedColors.append(contentsOf: servers.map { colorisedPing($0.ping) })
            return
        }
        filteredServers.append(contentsOf: servers.filter { isMatch(server: $0, forFilter: searchText) })
        cachedColors.append(contentsOf: filteredServers.map { colorisedPing($0.ping) })
    }

    @objc private func refreshServersForCurrentMaster() {
        guard !activityIndicatorView.isAnimating else {
            return
        }
        guard let host = currentMasterServer?.hostname, let port = currentMasterServer?.port else {
            return
        }
        reset()
        coordinator?.getServersList(host: host, port: port)
    }

    fileprivate func colorisedPing(_ ping: String?) -> NSAttributedString {
        guard let ping = ping, let number = Int(ping) else {
            return NSAttributedString(string: "0ms")
        }

        let color: UIColor
        if number <= 60 {
            color = UIColor(named: "goodPing") ?? .black
        } else if number <= 120 {
            color = UIColor(named: "averagePing") ?? .black
        } else {
            color = UIColor(named: "badPing") ?? .black
        }

        return NSAttributedString(string: ping+"ms", attributes: [.foregroundColor: color])
    }
}

extension ServersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredServers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServersTableViewCell.reuseIdentifier, for: indexPath) as? ServersTableViewCell else {
            return UITableViewCell()
        }
        let server = filteredServers[indexPath.row]
        cell.name = server.name
        cell.gametype = server.gametype
        cell.hostname = server.hostname
        cell.ping = cachedColors[indexPath.row]
        return cell
    }
}

extension ServersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterServersForSearchText(searchController.searchBar.text)
        tableView.reloadData()
    }
}

extension ServersViewController: CoordinatorDelegate {

    func didStartFetchingServersList(for coordinator: Coordinator) {
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
    }

    func didFinishFetchingServersList(for coordinator: Coordinator) {
        coordinator.fetchServersInfo()
    }

    func didFinishFetchingServersInfo(for coordinator: Coordinator) {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
        }
    }

    func coordinator(_ coordinator: Coordinator, didFinishFetchingInfoFor server: Server) {
        DispatchQueue.main.async {
            self.servers.append(server)
            if self.isMatch(server: server, forFilter: self.searchController.searchBar.text) {
                self.filteredServers.append(server)
                self.cachedColors.append(self.colorisedPing(server.ping))
            }
            self.tableView.reloadData()
        }
    }

    func coordinator(_ coordinator: Coordinator, didFinishFetchingStatusFor server: Server) {

    }

    func coordinator(_ coordinator: Coordinator, didFailWith error: SQLError) {
        print(error)
    }
}
