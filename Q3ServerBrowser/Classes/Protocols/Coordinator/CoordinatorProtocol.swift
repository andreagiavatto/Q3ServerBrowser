//
//  CoordinatorProtocol.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

import Foundation

protocol CoordinatorProtocol {
    
    weak var delegate: CoordinatorDelegate? { get set }

    func refreshServersList(host: String, port: String)
    func status(forServer server: ServerInfoProtocol)
}
