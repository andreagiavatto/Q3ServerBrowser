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

    let masterServerController = Q3MasterServerController(game: Game(title: "Quake 3 Arena", masterServerAddress: "master.ioquake3.org", serverPort: "27950"))
    let serverController = Q3ServerController()
    let q3parser = Q3Parser()
    
    override init() {
        super.init()
        masterServerController.delegate = self
        serverController.delegate = self
    }
    
    func refreshServersList() {
        masterServerController.startFetchingServersList()
    }

    func status(forServer server: ServerInfoProtocol) {
//        let addressComponents: [Any] = server.ip.components(separatedBy: ":")
//        if addressComponents.count == 2 {
//            serverController.statusForServer(withIp: addressComponents[0], andPort: addressComponents[1])
//        }
    }
}

extension Q3Coordinator: MasterServerControllerDelegate {
    
    func masterController(_ controller: MasterServerControllerProtocol, didFinishFetchingServersWith data: Data) {
        let servers = q3parser.parseServers(data)
        for ip: String in servers {
            let address: [String] = ip.components(separatedBy: ":")
            
            if address.count == 2 {
                serverController.requestServerInfo(ip: address[0], port: address[1])
            }
        }
    }
    
    func masterController(_ controller: MasterServerControllerProtocol, didFinishWithError error: Error?) {
        delegate?.didFinishWithError(error: error)
    }
}

extension Q3Coordinator: ServerControllerDelegate {
    
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerInfoWith data: Data, for address: Data) {
        
        
        let add = address as NSData
        var storage = sockaddr_storage()
        add.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)
        
        if var serverInfo = q3parser.parseServerInfo(data, for: controller), let result = getEndpointFromSocketAddress(socketAddressPointer: &storage) {
            serverInfo.ip = result.host
            serverInfo.port = "\(result.port)"
            delegate?.didFinishFetchingInfo(forServer: serverInfo)
        }
    }
    
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerStatusWith data: Data, for address: Data) {
//        q3parser.parseServerStatus(with: data, andOperation: operation)
    }
    
    func serverController(_ controller: ServerControllerProtocol, didFinishWithError error: Error?) {
        
    }
}
