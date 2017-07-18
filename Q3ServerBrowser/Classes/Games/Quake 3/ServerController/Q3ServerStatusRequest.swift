//
//  Q3ServerStatusRequest.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 17/07/2017.
//
//

import Foundation
import CocoaAsyncSocket

class Q3ServerStatusRequest: NSObject {
    
    typealias ServerStatusCompletionHandler = (_ data: Data?, _ address: Data?, _ error: Error?) -> Void
    
    private var socket: GCDAsyncUdpSocket?
    private let ip: String
    private let port: UInt16
    private let statusRequestMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x0a]
    fileprivate let statusResponseMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x0a, 0x5c] // YYYYstatusResponse\n\
    fileprivate var completionHandler: ServerStatusCompletionHandler?
    fileprivate var data = Data()
    
    required init(ip: String, port: UInt16) {
        self.ip = ip
        self.port = port
        super.init()
    }
    
    func execute(completion: ServerStatusCompletionHandler?) {
        
        self.completionHandler = completion
        let data = Data(bytes: self.statusRequestMarker)
        do {
            self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            self.socket?.send(data, toHost: ip, port: port, withTimeout: 10, tag: 42)
            try self.socket?.beginReceiving()
        } catch(let error) {
            completionHandler?(nil, nil, error)
        }
    }
}

extension Q3ServerStatusRequest: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {

        self.data.append(data)
        
        let prefix = String(bytes: statusResponseMarker, encoding: .ascii)
        let asciiRep = String(data: self.data, encoding: .ascii)
        
        if
            let asciiRep = asciiRep,
            let prefix = prefix,
            asciiRep.hasPrefix(prefix)
        {
            
            let start = self.data.index(self.data.startIndex, offsetBy: statusResponseMarker.count)
            let end = self.data.endIndex
            let usefulData = self.data.subdata(in: start..<end)
            completionHandler?(usefulData, address, nil)
        }
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        completionHandler?(nil, nil, error)
    }
}
