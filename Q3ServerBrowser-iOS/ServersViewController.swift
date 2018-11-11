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
    private var currentGame = Game(type: .quake3, launchArguments: "+connect")
    private var coordinator: Coordinator?
    fileprivate var servers = [Server]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        let masterServer = currentGame.masterServersList.first
        title = masterServer
        let masterServerComponents = masterServer?.components(separatedBy: ":")
        guard let host = masterServerComponents?.first, let port = masterServerComponents?.last else {
            return
        }
        reset()
        coordinator = currentGame.type.coordinator
        coordinator?.delegate = self
        coordinator?.getServersList(host: host, port: port)
    }

    private func reset() {
        servers.removeAll()
        tableView.reloadData()
    }
}

extension ServersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let server = servers[indexPath.row]
        cell.textLabel?.text = server.name + " - " + server.inGamePlayers
        cell.detailTextLabel?.text = server.hostname
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension ServersViewController: CoordinatorDelegate {

    func didStartFetchingServersList(for coordinator: Coordinator) {

    }

    func didFinishFetchingServersList(for coordinator: Coordinator) {
        coordinator.fetchServersInfo()
    }

    func didFinishFetchingServersInfo(for coordinator: Coordinator) {

    }

    func coordinator(_ coordinator: Coordinator, didFinishFetchingInfoFor server: Server) {
        DispatchQueue.main.async {
            self.servers.append(server)
            self.tableView.reloadData()
        }
    }

    func coordinator(_ coordinator: Coordinator, didFinishFetchingStatusFor server: Server) {

    }

    func coordinator(_ coordinator: Coordinator, didFailWith error: SQLError) {

    }
}
