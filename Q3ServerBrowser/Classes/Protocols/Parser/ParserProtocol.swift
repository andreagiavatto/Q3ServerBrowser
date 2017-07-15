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

    func parseServers(_ serversData: Data)
    func parseServerInfo(_ serverInfoData: Data, for server: ServerControllerProtocol)
    func parseServerStatus(_ serverStatusData: Data)
}
