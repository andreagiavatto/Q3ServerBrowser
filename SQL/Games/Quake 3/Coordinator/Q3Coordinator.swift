//
//  Q3Coordinator.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/7/14.
//
//

import Foundation

class Q3Coordinator: NSObject, Coordinator {
    
    public weak var delegate: CoordinatorDelegate?

    fileprivate let serverController = Q3ServerController()
    private var serversList = [Server]()
    private var toRequestInfo = [Server]()
    private let masterServerController = Q3MasterServerController()
    private let serverOperationsQueue = DispatchQueue(label: "com.q3browser.server-operations.queue")
    
    public override init() {
        super.init()
        masterServerController.delegate = self
        serverController.delegate = self
    }
    
    public func getServersList(host: String, port: String) {
        serversList.removeAll()
        toRequestInfo.removeAll()
        serverController.clearPendingRequests()
        masterServerController.startFetchingServersList(host: host, port: port)
    }
    
    public func fetchServersInfo() {
        guard !toRequestInfo.isEmpty else {
            return
        }
        serverController.requestServersInfo(toRequestInfo)
        toRequestInfo.removeAll()
    }

    public func info(forServer server: Server) {
        serverController.infoForServer(ip: server.ip, port: server.port)
    }
    
    public func status(forServer server: Server) {
        serverController.statusForServer(ip: server.ip, port: server.port)
    }
    
    func server(ip: String, port: String) -> Server? {
        return serversList.first(where: {$0.ip == ip && $0.port == port})
    }
    
    @discardableResult
    func removeTimeoutServer(ip: String, port: String) -> Server? {
        if let index = serversList.index(where: {$0.ip == ip && $0.port == port}) {
            let server = serversList[index]
            serversList.remove(at: index)
            return server
        }
        return nil
    }
}

extension Q3Coordinator: Q3MasterServerControllerDelegate {
    
    func masterController(_ controller: Q3MasterServerController, didFinishFetchingServersWith data: Data) {
        let servers = Q3Parser.parseServers(data)
        for ip in servers {
            let address: [String] = ip.components(separatedBy: ":")
            serversList.append(Q3Server(ip: address[0], port: address[1]))
        }
        
        toRequestInfo.append(contentsOf: serversList)
        
        delegate?.didFinishFetchingServersList(for: self)
    }
    
    func masterController(_ controller: Q3MasterServerController, didFinishWithError error: Error?) {

    }
}

extension Q3Coordinator: Q3ServerControllerDelegate {
    
    func serverController(_ controller: Q3ServerController, didFinishFetchingServerInfoWith operation: Q3Operation) {

        if
            let serverInfo = Q3Parser.parseServer(operation.data),
            let server = server(ip: operation.ip, port: "\(operation.port)")
        {
            server.update(with: serverInfo, ping: String(format: "%.0f", round(operation.executionTime * 1000)))
            delegate?.coordinator(self, didFinishFetchingInfoFor: server)
        } else {
            print("\(operation) parse info failed")
        }
    }
    
    func serverController(_ controller: Q3ServerController, didFinishFetchingServerStatusWith operation: Q3Operation) {
  
        if
            let serverStatus = Q3Parser.parseServerStatus(operation.data),
            var server = server(ip: operation.ip, port: "\(operation.port)")
        {
            server.rules = serverStatus.rules
            server.players = serverStatus.players
            delegate?.coordinator(self, didFinishFetchingStatusFor: server)
        } else {
            print("\(operation) parse status failed")
        }
    }
    
    func serverController(_ controller: Q3ServerController, didTimeoutFetchingServerInfoWith operation: Q3Operation) {
        
        _ = serverOperationsQueue.sync {
            removeTimeoutServer(ip: operation.ip, port: String(operation.port))
        }
    }
    
    func serverController(_ controller: Q3ServerController, didFinishWithError error: Error?) {

    }
    
    func serverController(_ controller: Q3ServerController, didFinishFetchingServersInfo: [Server]) {
        delegate?.didFinishFetchingServersInfo(for: self)
    }
}
