//
//  GCDAsyncUDPSocketWrapper.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 28/12/2018.
//

import Foundation
import CocoaAsyncSocket

protocol GCDAsyncUDPSocketWrapperProtocol {
    func setDelegate(_ delegate: GCDAsyncUdpSocketDelegate?)
    func setDelegateQueue(_ delegateQueue: DispatchQueue?)
    func close()
    func send(_ data: Data, toHost host: String, port: UInt16, withTimeout timeout: TimeInterval, tag: Int)
    func beginReceiving() throws
}

extension GCDAsyncUdpSocket: GCDAsyncUDPSocketWrapperProtocol {}
