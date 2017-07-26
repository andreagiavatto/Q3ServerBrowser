//
//  Q3ServerInfoRequest.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 16/07/2017.
//
//

import Foundation
import CocoaAsyncSocket

class Q3ServerInfoRequest: NSObject {
    
    typealias ServerInfoCompletionHandler = (_ data: Data?, _ address: Data?, _ ping: TimeInterval, _ error: Error?) -> Void
    
    private var socket: GCDAsyncUdpSocket?
    private let ip: String
    private let port: UInt16
    private let infoRequestMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x69, 0x6e, 0x66, 0x6f, 0x0a]
    fileprivate let infoResponseMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x69, 0x6e, 0x66, 0x6f, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x0a, 0x5c] // YYYYinfoResponse\n\
    fileprivate var completionHandler: ServerInfoCompletionHandler?
    fileprivate var data = Data()
    fileprivate var startTime: TimeInterval?
    
    required init(ip: String, port: UInt16) {
        self.ip = ip
        self.port = port
        super.init()
    }
    
    func execute(completion: ServerInfoCompletionHandler?) {
        
        self.completionHandler = completion
        let data = Data(bytes: self.infoRequestMarker)
        do {
            self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            self.socket?.send(data, toHost: ip, port: port, withTimeout: 10, tag: 42)
            try self.socket?.beginReceiving()
        } catch(let error) {
            completionHandler?(nil, nil, 0, error)
        }
    }
}

extension Q3ServerInfoRequest: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        let endTime = CFAbsoluteTimeGetCurrent()
        self.data.append(data)
        
        let prefix = String(bytes: infoResponseMarker, encoding: .ascii)
        let asciiRep = String(data: self.data, encoding: .ascii)
        
        if
            let asciiRep = asciiRep,
            let prefix = prefix,
            asciiRep.hasPrefix(prefix),
            let startTime = startTime
        {
            let start = self.data.index(self.data.startIndex, offsetBy: infoResponseMarker.count)
            let end = self.data.endIndex
            let usefulData = self.data.subdata(in: start..<end)
            completionHandler?(usefulData, address, endTime - startTime, nil)
        }
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        completionHandler?(nil, nil, 0, error)
    }
}
