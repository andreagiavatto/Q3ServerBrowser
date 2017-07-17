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
    
    func didFinishRequestingServers(for coordinator: CoordinatorProtocol)
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishWithError error: Error?)
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingServerInfo serverInfo: ServerInfoProtocol)
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingStatusInfo statusInfo: ([String: String], [Q3ServerPlayer])?, for ip: String)
}
