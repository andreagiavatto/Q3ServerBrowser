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

    let statusInfoQueue = DispatchQueue(label: "com.q3browser.server-info.queue")
    let serverInfoQueue = DispatchQueue(label: "com.q3browser.status-info.queue")
    private var socket: GCDAsyncUdpSocket?
    fileprivate var data = Data()
    
    let kAGServerBrowserNotificationReachableKey: String = "Reachable"

    func requestServerInfo(ip: String, port: UInt16) {
        
        reset()
        let command: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x69, 0x6e, 0x66, 0x6f, 0x0a]
        let data = Data(bytes: command)
        do {
            self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            self.delegate?.didStartFetchingInfo(forServerController: self)
            self.socket?.send(data, toHost: ip, port: UInt16(port), withTimeout: 10, tag: 42)
            try self.socket?.beginReceiving()
        } catch(let error) {
            self.delegate?.serverController(self, didFinishWithError: error)
        }
    }

    func statusForServer(ip: String, port: UInt16) {
        
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
        
        if data.count < packetLength { // assuming last packet
            delegate?.serverController(self, didFinishFetchingServerInfoWith: data)
        }
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("server closed socket \(error)")
    }
}
