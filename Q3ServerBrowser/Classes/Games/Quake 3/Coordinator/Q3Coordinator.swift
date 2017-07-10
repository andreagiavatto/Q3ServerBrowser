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

    let game = Game(title: "Quake 3 Arena", masterServerAddress: "master3.idsoftware.com", serverPort: 27950)
    let masterServerController: Q3MasterServerController
    let serverController = Q3ServerController()
    let q3parser = Q3Parser()
    
    override init() {
        masterServerController = Q3MasterServerController(game: game)
        super.init()
        masterServerController.delegate = self
        serverController.delegate = self
        q3parser.delegate = self
        
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
    
    func didStartFetchingServers(forMasterController controller: MasterServerControllerProtocol) {
        
    }
    
    func masterController(_ controller: MasterServerControllerProtocol, didFinishFetchingServersWith data: Data) {
        q3parser.parseServers(with: data)
    }
    
    func masterController(_ controller: MasterServerControllerProtocol, didFinishWithError error: Error?) {
        
    }
}

extension Q3Coordinator: ServerControllerDelegate {
    
    func didStartFetchingInfo(forServerController controller: ServerControllerProtocol) {
        
    }
    
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerInfoWith data: Data) {
        q3parser.parseServerInfo(with: data)
    }
    
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerStatusWith data: Data) {
//        q3parser.parseServerStatus(with: data, andOperation: operation)
    }
    
    func serverController(_ controller: ServerControllerProtocol, didFinishWithError error: Error?) {
        
    }
}

extension Q3Coordinator: ParserDelegate {
    
    func didFinishParsingServersData(forParser parser: ParserProtocol, withServers servers: [String]) {
        for ip: String in servers {
            let address: [String] = ip.components(separatedBy: ":")

            if address.count == 2 {
                print(address)
                serverController.requestServerInfo(ip: address[0], port: UInt16(address[1])!)
            }
        }
    }
    
    func didFinishParsingServerInfoData(forParser parser: ParserProtocol, withServerInfo serverInfo: ServerInfoProtocol) {
        delegate?.didFinishFetchingInfo(forServer: serverInfo)
    }
    
    func didFinishParsingServerStatusData(forParser parser: ParserProtocol, withServerStatus serverStatus: [AnyHashable: Any]) {
        if !serverStatus.isEmpty {
            delegate?.didFinishFetchingStatus(forServer: serverStatus)
        }
    }
    
    func didFinishParsingServerPlayers(forParser parser: ParserProtocol, withPlayers players: [Any]) {
        if !players.isEmpty {
            delegate?.didFinishFetchingPlayers(forServer: players)
        }
    }
}
