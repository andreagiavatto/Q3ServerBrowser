//
//  CoordinatorDelegate.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

import Foundation
import SQL

protocol CoordinatorDelegate: NSObjectProtocol {
    
    func didFinishRequestingServers(for coordinator: CoordinatorProtocol)
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishWithError error: Error?)
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingInfo forServerInfo: Server)
    func coordinator(_ coordinator: CoordinatorProtocol, didFinishFetchingStatus forServerInfo: Server)
}
