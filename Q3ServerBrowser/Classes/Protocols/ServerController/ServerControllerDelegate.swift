//
//  ServerControllerDelegate.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

import Foundation

protocol ServerControllerDelegate: NSObjectProtocol {
    
    func serverController(_ controller: ServerControllerProtocol, didFinishWithError error: Error?)
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerInfoWith operation: Q3Operation)
    func serverController(_ controller: ServerControllerProtocol, didFinishFetchingServerStatusWith operation: Q3Operation)
}
