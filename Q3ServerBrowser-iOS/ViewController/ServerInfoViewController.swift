//
//  ServerInfoViewController.swift
//  Q3ServerBrowser-iOS
//
//  Created by HLR on 18/11/2018.
//

import UIKit
import SQL_iOS

class ServerInfoViewController: UIViewController {
    @IBOutlet private var hostnameLabel: UILabel!
    @IBOutlet private var pingLabel: UILabel!
    @IBOutlet private var mapNameLabel: UILabel!
    @IBOutlet private var gametypeLabel: UILabel!
    @IBOutlet private var playersLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    var server: Server!
    var currentGame: Game!
    private let refreshControl = UIRefreshControl()
    private var coordinator: Coordinator?
    private var isRefreshing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = server?.name
        coordinator = currentGame?.type.coordinator
        coordinator?.delegate = self
        setupTableView()
        refreshStatus()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        setupHeader()
        refreshControl.addTarget(self, action: #selector(refreshStatus), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc private func refreshStatus() {
        guard !isRefreshing else {
            return
        }
        isRefreshing = true
        coordinator?.refreshStatus(for: [server])
        coordinator?.status(forServer: server)
    }
    
    private func setupHeader() {
        hostnameLabel.text = "Hostname: \(server.hostname)"
        pingLabel.text = "Ping: \(server.ping)ms"
        mapNameLabel.text = "Map: \(server.map)"
        gametypeLabel.text = server.gametype
        playersLabel.text = "Players: \(server.currentPlayers)/\(server.maxPlayers)"
    }
}

extension ServerInfoViewController: CoordinatorDelegate {
    func didStartFetchingServersList(for coordinator: Coordinator) {}
    
    func didFinishFetchingServersList(for coordinator: Coordinator) {}
    
    func didFinishFetchingServersInfo(for coordinator: Coordinator) {}
    
    func coordinator(_ coordinator: Coordinator, didFinishFetchingInfoFor server: Server) {}
    
    func coordinator(_ coordinator: Coordinator, didFinishFetchingStatusFor server: Server) {
        self.server = server
        DispatchQueue.main.async {
            self.isRefreshing = false
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func coordinator(_ coordinator: Coordinator, didFailWith error: SQLError) {
        print(error)
    }
}

extension ServerInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard server.isATeamMode && server.hasPlayers else {
            return nil
        }
        let header = UIView()
        let nameLabel = UILabel()
        let scoreLabel = UILabel()
        nameLabel.textColor = .white
        nameLabel.font = .boldSystemFont(ofSize: 17)
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .right
        scoreLabel.font = .boldSystemFont(ofSize: 17)
        if section == 0 {
            header.backgroundColor = .systemRed
            nameLabel.text = server?.teamRed?.type.rawValue.uppercased()
            scoreLabel.text = server?.teamRed?.score
        } else if section == 1 {
            header.backgroundColor = .systemBlue
            nameLabel.text = server?.teamBlue?.type.rawValue.uppercased()
            scoreLabel.text = server?.teamBlue?.score
        } else {
            header.backgroundColor = .systemGray
            nameLabel.text = server?.teamSpectator?.type.rawValue.uppercased()
            scoreLabel.text = server?.teamSpectator?.score
        }
        header.addSubview(nameLabel)
        header.addSubview(scoreLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
            nameLabel.trailingAnchor.constraint(equalTo: scoreLabel.leadingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            scoreLabel.widthAnchor.constraint(equalToConstant: 80.0)
        ])
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard server?.isATeamMode ?? false else {
            return 0.0
        }
        return 40.0
    }
}

extension ServerInfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return server.isATeamMode ? 3 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if server.isATeamMode {
            if section == 0 { // red
                return server.teamRed?.players.count ?? 0
            } else if section == 1 { // blue
                return server.teamBlue?.players.count ?? 0
            } else {
                return server.teamSpectator?.players.count ?? 0
            }
        }
        return server.players?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerInfoCellReuseIdentifier", for: indexPath)
        let player: Player?
        if server.isATeamMode {
            if indexPath.section == 0 {
                player = server.teamRed?.players[indexPath.row]
            } else if indexPath.section == 1 {
                player = server.teamBlue?.players[indexPath.row]
            } else {
                player = server.teamSpectator?.players[indexPath.row]
            }
        } else {
            player = server.players?[indexPath.row]
        }
        cell.selectionStyle = .none
        cell.textLabel?.text = player?.name
        cell.detailTextLabel?.text = player?.score
        cell.detailTextLabel?.font = .systemFont(ofSize: 15)
        return cell
    }
}
