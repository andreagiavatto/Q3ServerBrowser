//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  ParserDelegate.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 1/2/14.
//
//

import Foundation

protocol ParserDelegate: NSObjectProtocol {
    
    func didFinishParsingServersData(forParser parser: ParserProtocol, withServers servers: [String])
    func didFinishParsingServerInfoData(forParser parser: ParserProtocol, withServerInfo serverInfo: ServerInfoProtocol)
    func didFinishParsingServerStatusData(forParser parser: ParserProtocol, withServerStatus serverStatus: [AnyHashable: Any])
    func didFinishParsingServerPlayers(forParser parser: ParserProtocol, withPlayers players: [Any])

    func willStartParsingServersData(forParser parser: ParserProtocol)
    func willStartParsingServerInfoData(forParser parser: ParserProtocol)
    func willStartParsingServerStatusData(forParser parser: ParserProtocol)
    func willStartParsingServerPlayers(forParser parser: ParserProtocol)
}

extension ParserDelegate {
    
    func willStartParsingServersData(forParser parser: ParserProtocol) {}
    func willStartParsingServerInfoData(forParser parser: ParserProtocol) {}
    func willStartParsingServerStatusData(forParser parser: ParserProtocol) {}
    func willStartParsingServerPlayers(forParser parser: ParserProtocol) {}
}
