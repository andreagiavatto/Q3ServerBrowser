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
    
    func parseServers(_ serversData: Data) -> [String]
    func parseServerInfo(_ serverInfoData: Data, for server: ServerControllerProtocol) -> ServerInfoProtocol?
    func parseServerStatus(_ serverStatusData: Data) -> (rules: [String: String], players: [Q3ServerPlayer])?
}
