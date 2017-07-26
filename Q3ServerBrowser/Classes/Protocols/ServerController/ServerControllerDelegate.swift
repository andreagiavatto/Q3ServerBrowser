//
//  ServerControllerDelegate.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

import Foundation

protocol ServerControllerDelegate: NSObjectProtocol {
    
    func didStartFetchingInfo(forServerController controller: ServerControllerProtocol)

    func serverController(_ controller: ServerControllerProtocol, didFinishWithError error: Error?)
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerInfoWith data: Data, for ip: String, port: UInt16, ping: TimeInterval)
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerStatusWith data: Data, for address: Data)
}

extension ServerControllerDelegate {
    
    func didStartFetchingInfo(forServerController controller: ServerControllerProtocol) {}
}
