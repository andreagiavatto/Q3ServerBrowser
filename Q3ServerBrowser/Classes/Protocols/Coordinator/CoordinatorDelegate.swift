//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  CoordinatorDelegate.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

import Foundation

protocol CoordinatorDelegate: NSObjectProtocol {
    
    func didFinishWithError(error: Error?)
    func didFinishFetchingInfo(forServer serverInfo: ServerInfoProtocol)
    func didFinishFetchingStatus(forServer serverStatus: [AnyHashable: Any])
    func didFinishFetchingPlayers(forServer serverPlayers: [Any])
}
