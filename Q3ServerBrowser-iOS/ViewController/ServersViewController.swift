//
//  ServersViewController.swift
//  Q3ServerBrowser-iOS
//
//  Created by HLR on 11/11/2018.
//

import UIKit
import SQL_iOS

class ServersViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let serversRefreshControl = UIRefreshControl()
    private let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private var currentGame = Game(type: .quake3, launchArguments: "+connect")
    private var currentMasterServer: MasterServer?
    private var coordinator: Coordinator?
    fileprivate var servers = [Server]()
    fileprivate var cachedColors = [NSAttributedString]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        currentMasterServer = currentGame.masterServers.first
        coordinator = currentGame.type.coordinator
        coordinator?.delegate = self
        setupUI()
        refreshServersForCurrentMaster()
    }

    private func setupUI() {
        title = currentMasterServer?.hostname
        activityIndicatorView.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        tableView.register(UINib(nibName: "ServersTableViewCell", bundle: nil), forCellReuseIdentifier: ServersTableViewCell.reuseIdentifier)
        serversRefreshControl.addTarget(self, action: #selector(refreshServersForCurrentMaster), for: .valueChanged)
        tableView.addSubview(serversRefreshControl)
    }

    private func reset() {
        servers.removeAll()
        cachedColors.removeAll()
        tableView.reloadData()
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
        return servers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServersTableViewCell.reuseIdentifier, for: indexPath) as? ServersTableViewCell else {
            return UITableViewCell()
        }
        let server = servers[indexPath.row]
        cell.name = server.name
        cell.gametype = server.gametype
        cell.hostname = server.hostname
        cell.ping = cachedColors[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
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
        self.servers.append(server)
        self.cachedColors.append(colorisedPing(server.ping))
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func coordinator(_ coordinator: Coordinator, didFinishFetchingStatusFor server: Server) {

    }

    func coordinator(_ coordinator: Coordinator, didFailWith error: SQLError) {
        print(error)
    }
}
