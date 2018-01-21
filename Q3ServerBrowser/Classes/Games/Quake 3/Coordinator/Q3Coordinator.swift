//
//  Q3Coordinator.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/7/14.
//
//

import Foundation

class Q3Coordinator: NSObject, CoordinatorProtocol {
    
    weak var delegate: CoordinatorDelegate?

    fileprivate let q3parser = Q3Parser()
    fileprivate let serverController = Q3ServerController()
    private(set) var serversList = [ServerInfoProtocol]()
    private var toRequestInfo = [ServerInfoProtocol]()
    private let masterServerController = Q3MasterServerController()
    
    override init() {
        super.init()
        masterServerController.delegate = self
        serverController.delegate = self
    }
    
    func refreshServersList(host: String, port: String) {
        serversList.removeAll()
        toRequestInfo.removeAll()
        serverController.clearPendingRequests()
        masterServerController.startFetchingServersList(host: host, port: port)
    }

    func info(forServer server: ServerInfoProtocol) {
        serverController.requestServerInfo(ip: server.ip, port: server.port)
    }
    
    func status(forServer server: ServerInfoProtocol) {
        serverController.statusForServer(ip: server.ip, port: server.port)
    }
    
    func server(ip: String, port: String) -> ServerInfoProtocol? {
        return serversList.first(where: {$0.ip == ip && $0.port == port})
    }
    
    func requestServersInfo() {
        for server in toRequestInfo {
            serverController.requestServerInfo(ip: server.ip, port: server.port)
        }
    }
}

extension Q3Coordinator: MasterServerControllerDelegate {
    
    func masterController(_ controller: MasterServerControllerProtocol, didFinishFetchingServersWith data: Data) {
        let servers = q3parser.parseServers(data)
        for ip in servers {
            let address: [String] = ip.components(separatedBy: ":")
            serversList.append(Q3ServerInfo(ip: address[0], port: address[1]))
        }
        
        toRequestInfo.append(contentsOf: serversList)
        
        delegate?.didFinishRequestingServers(for: self)
    }
    
    func masterController(_ controller: MasterServerControllerProtocol, didFinishWithError error: Error?) {
        delegate?.coordinator(self, didFinishWithError: error)
    }
}

extension Q3Coordinator: ServerControllerDelegate {
    
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerInfoWith operation: Q3Operation) {

        if
            let serverInfo = q3parser.parseServerInfo(operation.data, for: controller),
            var server = server(ip: operation.ip, port: "\(operation.port)")
        {
            server.update(dictionary: serverInfo)
            server.ping = String(format: "%.0f", round(operation.executionTime * 1000))
            delegate?.coordinator(self, didFinishFetchingInfo: server)
        } else {
            print("\(operation.ip):\(operation.port) parse info failed")
        }
    }
    
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerStatusWith operation: Q3Operation) {
  
        if
            let serverStatus = q3parser.parseServerStatus(operation.data),
            var server = server(ip: operation.ip, port: "\(operation.port)")
        {
            server.rules = serverStatus.rules
            server.players = serverStatus.players
            delegate?.coordinator(self, didFinishFetchingStatus: server)
        } else {
            print("\(operation.ip):\(operation.port) parse status failed")
        }
    }
    
    func serverController(_ controller: ServerControllerProtocol, didFinishWithError error: Error?) {

    }
}
