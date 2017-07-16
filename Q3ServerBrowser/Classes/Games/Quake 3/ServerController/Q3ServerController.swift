//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  Q3ServerController.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

import Foundation
import CocoaAsyncSocket

class Q3ServerController: NSObject, ServerControllerProtocol {
    
    weak var delegate: ServerControllerDelegate?

    let serverInfoQueue = DispatchQueue(label: "com.q3browser.server-info.queue")
    let statusInfoQueue = DispatchQueue(label: "com.q3browser.status-info.queue")
    private var socket: GCDAsyncUdpSocket?
    fileprivate var data = Data()
    private let infoRequestMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x69, 0x6e, 0x66, 0x6f, 0x0a]
    fileprivate let infoResponseMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x69, 0x6e, 0x66, 0x6f, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x0a, 0x5c] // YYYYinfoResponse\n\
    
    func requestServerInfo(ip: String, port: String) {
        
        serverInfoQueue.async { [unowned self] in
            self.reset()
            guard let port = UInt16(port) else {
                return
            }
            let data = Data(bytes: self.infoRequestMarker)
            do {
                self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
                self.delegate?.didStartFetchingInfo(forServerController: self)
                self.socket?.send(data, toHost: ip, port: port, withTimeout: 10, tag: 42)
                try self.socket?.beginReceiving()
            } catch(let error) {
                self.delegate?.serverController(self, didFinishWithError: error)
            }
        }
    }

    func statusForServer(ip: String, port: String) {
        
//        if (ip.characters.count ?? 0) && port > 0 {
//            let command = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x0a]
//            let getStatusData = Data(bytes: command, length: MemoryLayout<command>.size)
//            let infoOperation = AGServerOperation(serverIp: ip, andPort: port, andCommand: getStatusData)
//            (infoOperation)
//            infoOperation.completionBlock() =   
//            do {
//                (weakOperation)
//                if strongOperation {
//                    if delegate?.responds(to: Selector("serverController:didFinishFetchingServerStatusWithOperation:")) {
//                        delegate?.serverController(self, didFinishFetchingServerStatusWith: strongOperation)
//                    }
//                }
//            }
//            statusQueue?.addOperation(infoOperation)
//        }
    }
    
    // MARK: - Private methods
    
    private func reset() {
        data.removeAll()
        socket = nil
    }
}

extension Q3ServerController: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        self.data.append(data)
        
        let prefix = String(bytes: infoResponseMarker, encoding: .ascii)
        let asciiRep = String(data: self.data, encoding: .ascii)
        
        if
            let asciiRep = asciiRep,
            let prefix = prefix,
            asciiRep.hasPrefix(prefix)
        {
            
            let start = self.data.index(self.data.startIndex, offsetBy: infoResponseMarker.count)
            let end = self.data.endIndex
            let usefulData = self.data.subdata(in: start..<end)
            delegate?.serverController(self, didFinishFetchingServerInfoWith: usefulData, for: address)
        }
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        delegate?.serverController(self, didFinishWithError: error)
    }
}
