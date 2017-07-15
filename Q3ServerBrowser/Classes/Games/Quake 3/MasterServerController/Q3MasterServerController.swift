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
    fileprivate var data = Data()
    private let getServersRequestMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x65, 0x72, 0x76, 0x65, 0x72, 0x73, 0x20, 0x36, 0x38, 0x20, 0x65, 0x6d, 0x70, 0x74, 0x79, 0x20, 0x66, 0x75, 0x6c, 0x6c]
    fileprivate let getServersResponseMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x65, 0x72, 0x76, 0x65, 0x72, 0x73, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x5c] // YYYYgetserversResponse\
    fileprivate let eotMarker: [UInt8] = [0x5c, 0x45, 0x4f, 0x54, 0x0, 0x0, 0x0] // \EOT000

    required init(game: Game) {
        self.game = game
    }
    
    func startFetchingServersList() {
        
        masterServerQueue.async { [unowned self] in
            self.reset()
            guard let port = UInt16(self.game.serverPort) else {
                return
            }
            let host = self.game.masterServerAddress
            let data = Data(bytes: self.getServersRequestMarker)
            self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            do {
                self.delegate?.didStartFetchingServers(forMasterController: self)
                self.socket?.send(data, toHost: host, port: port, withTimeout: 10, tag: 42)
                try self.socket?.beginReceiving()
            } catch(let error) {
                self.delegate?.masterController(self, didFinishWithError: error)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func reset() {
        data.removeAll()
        socket = nil
    }
}

extension Q3MasterServerController: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {

        self.data.append(data)
        
        let prefix = String(bytes: getServersResponseMarker, encoding: .ascii)
        let suffix = String(bytes: eotMarker, encoding: .ascii)
        let asciiRep = String(data: self.data, encoding: .ascii)
        
        if
            let asciiRep = asciiRep,
            let suffix = suffix,
            let prefix = prefix,
            asciiRep.hasPrefix(prefix),
            asciiRep.hasSuffix(suffix)
        {
            
            let start = self.data.index(self.data.startIndex, offsetBy: getServersResponseMarker.count)
            let end = self.data.index(self.data.endIndex, offsetBy: -(eotMarker.count))
            let usefulData = self.data.subdata(in: start..<end)
            delegate?.masterController(self, didFinishFetchingServersWith: usefulData)
        }
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {

    }
}

