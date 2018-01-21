//
//  Q3Parser.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 12/14/13.
//
//

import Foundation

class Q3Parser: ParserProtocol {
    
    func parseServers(_ serversData: Data) -> [String] {

        if serversData.count > 0 {

            let len: Int = serversData.count
            var servers = [String]()
            for i in 0..<len {
                if i > 0 && i % 7 == 0 {
                    // -- 4 bytes for ip, 2 for port, 1 separator
                    let s = serversData.index(serversData.startIndex, offsetBy: i-7)
                    let e = serversData.index(s, offsetBy: 7)
                    let server = parseServerData(serversData.subdata(in: s..<e))
                    servers.append(server)
                }
            }
            
            return servers
        }
        
        return []
    }

    func parseServerInfo(_ serverInfoData: Data, for server: ServerControllerProtocol) -> [String: String]? {
        
        guard serverInfoData.count > 0 else {
            return nil
        }
        
        var infoResponse = String(data: serverInfoData, encoding: .ascii)
        infoResponse = infoResponse?.trimmingCharacters(in: .whitespacesAndNewlines)
        var info = infoResponse?.components(separatedBy: "\\")
        info = info?.filter { NSPredicate(format: "SELF != ''").evaluate(with: $0) }
        var keys = [String]()
        var values = [String]()
        
        if let info = info {
            for (index, element) in info.enumerated() {
                if index % 2 == 0 {
                    keys.append(element)
                } else {
                    values.append(element)
                }
            }
        }
        
        if keys.count == values.count {
            
            var infoDict = [String: String]()
            keys.enumerated().forEach { (i) -> () in
                infoDict[i.element] = values[i.offset]
            }
            
            return infoDict
        }
        
        return nil
    }

    func parseServerStatus(_ serverStatusData: Data) -> (rules: [String: String], players: [Q3ServerPlayer])? {
        
        guard serverStatusData.count > 0 else {
            return nil
        }
        
        var rules = [String: String]()
        var players = [Q3ServerPlayer]()
        
        var statusResponse = String(data: serverStatusData, encoding: .ascii)
        statusResponse = statusResponse?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let statusComponents = statusResponse?.components(separatedBy: "\n") {
            let serverStatus = statusComponents[0]
            if statusComponents.count > 1 {
                // -- We got players
                let playerStrings = statusComponents[1..<statusComponents.count]
                let playersStatus = Array(playerStrings)
                players = parsePlayersStatus(playersStatus)
            }
            var status = serverStatus.components(separatedBy: "\\")
            status = status.filter { NSPredicate(format: "SELF != ''").evaluate(with: $0) }
            var keys = [String]()
            var values = [String]()
            
            for (index, element) in status.enumerated() {
                if index % 2 == 0 {
                    keys.append(element)
                } else {
                    values.append(element)
                }
            }
            
            if keys.count == values.count {
                
                keys.enumerated().forEach { (i) -> () in
                    rules[i.element] = values[i.offset]
                }
            }
        }
        
        return (rules, players)
    }

    // MARK: - Private methods

    private func parseServerData(_ serverData: Data) -> String {

        let len: Int = serverData.count
        let bytes = [UInt8](serverData)
        var port: UInt32 = 0
        var server = String()
        for i in 0..<len - 1 {

            if i < 4 {
                if i < 3 {
                    server = server.appendingFormat("%d.", bytes[i])
                }
                else {
                    server = server.appendingFormat("%d", bytes[i])
                }
            }
            else {
                if i == 4 {
                    port += UInt32(bytes[i]) << 8
                }
                else {
                    port += UInt32(bytes[i])
                }
            }
        }
        return "\(server):\(port)"
    }

    private func parsePlayersStatus(_ players: [String]) -> [Q3ServerPlayer] {
        
        guard players.count > 0 else {
            return []
        }
        
        var q3Players = [Q3ServerPlayer]()
        
        for playerString in players {
            if let player = Q3ServerPlayer(line: playerString) {
                q3Players.append(player)
            }
        }

        return q3Players
    }
}
