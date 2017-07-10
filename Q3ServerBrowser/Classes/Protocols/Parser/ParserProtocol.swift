//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  ParserProtocol.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 12/14/13.
//
//

import Foundation

protocol ParserProtocol {
    
    weak var delegate: ParserDelegate? { get set }

    func parseServers(with serversData: Data)
    func parseServerInfo(with serverInfoData: Data)
    func parseServerStatus(with serverStatusData: Data)
}
