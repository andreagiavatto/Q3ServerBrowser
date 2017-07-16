//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
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
    fileprivate var responseTimes = [String: TimeInterval]()
    private let masterServerController = Q3MasterServerController()
    
    override init() {
        super.init()
        masterServerController.delegate = self
        serverController.delegate = self
    }
    
    func refreshServersList(host: String, port: String) {
        responseTimes.removeAll()
        masterServerController.startFetchingServersList(host: host, port: port)
    }

    func status(forServer server: ServerInfoProtocol) {
        serverController.statusForServer(ip: server.ip, port: server.port)
    }
}

extension Q3Coordinator: MasterServerControllerDelegate {
    
    func masterController(_ controller: MasterServerControllerProtocol, didFinishFetchingServersWith data: Data) {
        let servers = q3parser.parseServers(data)
        for ip in servers {
            let address: [String] = ip.components(separatedBy: ":")
            
            if address.count == 2 {
                responseTimes[ip] = CFAbsoluteTimeGetCurrent()
                serverController.requestServerInfo(ip: address[0], port: address[1])
            }
        }
        
        delegate?.didFinishRequestingServers(for: self)
    }
    
    func masterController(_ controller: MasterServerControllerProtocol, didFinishWithError error: Error?) {
        delegate?.coordinator(self, didFinishWithError: error)
    }
}

extension Q3Coordinator: ServerControllerDelegate {
    
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerInfoWith data: Data, for address: Data) {
        print(responseTimes)
        let add = address as NSData
        var storage = sockaddr_storage()
        add.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)
        
        if
            var serverInfo = q3parser.parseServerInfo(data, for: controller),
            let result = getEndpointFromSocketAddress(socketAddressPointer: &storage),
            let startTime = responseTimes["\(result.host):\(result.port)"]
        {
            serverInfo.ip = result.host
            serverInfo.port = "\(result.port)"
            serverInfo.ping = String(format: "%.0f", round((CFAbsoluteTimeGetCurrent()-startTime)*1000))
            delegate?.coordinator(self, didFinishFetchingServerInfo: serverInfo)
        }
    }
    
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerStatusWith data: Data, for address: Data) {
//        q3parser.parseServerStatus(with: data, andOperation: operation)
    }
    
    func serverController(_ controller: ServerControllerProtocol, didFinishWithError error: Error?) {
        
    }
}
