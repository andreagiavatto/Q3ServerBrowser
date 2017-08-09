//
//  Q3ServerInfoOperation.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 22/07/2017.
//
//

import Foundation
import CocoaAsyncSocket

let socketDelegateQueue = DispatchQueue(label: "com.socket.delegate.queue", attributes: [.concurrent])

class Q3ServerInfoOperation: Operation {
    
    let ip: String
    let port: UInt16
    fileprivate let infoResponseMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x69, 0x6e, 0x66, 0x6f, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x0a, 0x5c] // YYYYinfoResponse\n\
    fileprivate(set) var data = Data()
    fileprivate(set) var executionTime: TimeInterval = 0.0
    fileprivate(set) var error: Error?
    fileprivate var startTime: TimeInterval?
    private var socket: GCDAsyncUdpSocket?
    private let infoRequestMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x69, 0x6e, 0x66, 0x6f, 0x0a]
    
    required init(ip: String, port: UInt16) {
        self.ip = ip
        self.port = port
        super.init()
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: socketDelegateQueue)
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override func start() {

        guard isCancelled == false else {
            finish()
            return
        }
        
        DispatchQueue.global().async {
            self._executing = true
            
            let data = Data(bytes: self.infoRequestMarker)
            do {
                self.socket?.send(data, toHost: self.ip, port: self.port, withTimeout: 10, tag: 42)
                try self.socket?.receiveOnce()
            } catch(let error) {
                print(error)
                self.finish()
            }
        }
        
    }
    
    func finish() {
        _executing = false
        _finished = true
    }
}

extension Q3ServerInfoOperation: GCDAsyncUdpSocketDelegate {
    
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
            self.data = self.data.subdata(in: start..<end)
            self.executionTime = endTime - startTime
        }
        
        finish()
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        self.error = error
        print(error)
        finish()
    }
}
