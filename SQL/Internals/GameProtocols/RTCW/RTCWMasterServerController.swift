//
//  Q3MasterController.h
//  ServerQueryLibrary
//
//  Created by Andrea Giavatto on 3/7/14.
//

import Foundation
import CocoaAsyncSocket

class RTCWMasterServerController: NSObject, MasterServerController {
    
    weak var delegate: MasterServerControllerDelegate?

    private let masterServerQueue: DispatchQueue
    private let socket: GCDAsyncUDPSocketWrapperProtocol
    fileprivate var data = Data()
    private let getServersRequestMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x65, 0x72, 0x76, 0x65, 0x72, 0x73, 0x20, 0x36, 0x30, 0x20, 0x65, 0x6d, 0x70, 0x74, 0x79, 0x20, 0x66, 0x75, 0x6c, 0x6c] // YYYYgetservers 60 empty full
    fileprivate let getServersResponseMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x65, 0x72, 0x76, 0x65, 0x72, 0x73, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x5c] // YYYYgetserversResponse\
    fileprivate let eotMarker: [UInt8] = [0x5c, 0x45, 0x4f, 0x54] // \EOT
    
    required init(queue: DispatchQueue, socket: GCDAsyncUDPSocketWrapperProtocol) {
        self.masterServerQueue = queue
        self.socket = socket
        super.init()
        self.socket.setDelegate(self)
        self.socket.setDelegateQueue(.main)
    }
    
    func startFetchingServersList(host: String, port: String) {
        masterServerQueue.async { [weak self] in
            guard let port = UInt16(port), let self = self else {
                return
            }
            self.reset()
            let data = Data(self.getServersRequestMarker)
            do {
                self.delegate?.didStartFetchingServers(forMasterController: self)
                self.socket.send(data, toHost: host, port: port, withTimeout: 10, tag: 42)
                try self.socket.beginReceiving()
            } catch(let error) {
                self.delegate?.masterController(self, didFinishWithError: error)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func reset() {
        data.removeAll()
        socket.close()
    }
}

extension RTCWMasterServerController: GCDAsyncUdpSocketDelegate {
    
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
            asciiRep.range(of: suffix, options: .backwards, range: nil, locale: nil) != nil
        {
            
            let start = self.data.index(self.data.startIndex, offsetBy: getServersResponseMarker.count)
            let end = self.data.index(self.data.endIndex, offsetBy: -(eotMarker.count))
            if start < end {
                let usefulData = self.data.subdata(in: start..<end)
                delegate?.masterController(self, didFinishFetchingServersWith: usefulData)
            } else {
                delegate?.masterController(self, didFinishFetchingServersWith: Data())
            }
        }
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        delegate?.masterController(self, didFinishWithError: error)
    }
}
