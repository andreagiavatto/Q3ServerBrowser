//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
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

    var ip: String { get set }
    var port: String { get set }
    var ping: String { get set }
    
    func requestServerInfo(ip: String, port: String)
    func statusForServer(ip: String, port: String)
}
