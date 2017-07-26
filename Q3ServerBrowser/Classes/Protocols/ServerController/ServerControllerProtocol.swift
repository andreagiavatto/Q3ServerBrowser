//
//  ServerControllerProtocol.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

import Foundation

protocol ServerControllerProtocol {
    
    weak var delegate: ServerControllerDelegate? { get set }
    
    func requestServerInfo(ip: String, port: String)
    func statusForServer(ip: String, port: String)
}
