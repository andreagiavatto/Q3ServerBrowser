//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  Q3MasterController.h
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/7/14.
//


import Foundation
import CocoaAsyncSocket

class Q3MasterServerController: NSObject, MasterServerControllerProtocol {
    
    weak var delegate: MasterServerControllerDelegate?

    let game: Game
    let masterServerQueue = DispatchQueue(label: "com.q3browser.master-server.queue")
    private var socket: GCDAsyncUdpSocket?
    fileprivate var packetLength: Int = 0
    fileprivate var data = Data()

    required init(game: Game) {
        self.game = game
    }
    
    func startFetchingServersList() {
        
        reset()
        let host = self.game.masterServerAddress
        let port = self.game.serverPort
        let command: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x65, 0x72, 0x76, 0x65, 0x72, 0x73, 0x20, 0x36, 0x38, 0x20, 0x65, 0x6d, 0x70, 0x74, 0x79, 0x20, 0x66, 0x75, 0x6c, 0x6c]
        let data = Data(bytes: command)
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            self.delegate?.didStartFetchingServers(forMasterController: self)
            self.socket?.send(data, toHost: host, port: port, withTimeout: 10, tag: 42)
            try self.socket?.beginReceiving()
        } catch(let error) {
            self.delegate?.masterController(self, didFinishWithError: error)
        }
    }
    
    // MARK: - Private methods
    
    private func reset() {
        packetLength = 0
        data.removeAll()
        socket = nil
    }
}

extension Q3MasterServerController: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        if packetLength == 0 {
            packetLength = data.count
        }

        self.data.append(data)
        
        if data.count < packetLength { // assuming last packet
            delegate?.masterController(self, didFinishFetchingServersWith: self.data)
        }
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("master closed socket \(error)")
    }
}

