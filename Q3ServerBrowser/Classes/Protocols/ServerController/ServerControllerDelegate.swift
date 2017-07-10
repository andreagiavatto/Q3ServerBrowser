//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
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
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerInfoWith data: Data)
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerStatusWith data: Data)
}
