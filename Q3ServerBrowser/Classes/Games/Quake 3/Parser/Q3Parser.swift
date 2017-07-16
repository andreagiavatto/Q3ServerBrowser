//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
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

    func parseServerInfo(_ serverInfoData: Data, for server: ServerControllerProtocol) -> ServerInfoProtocol? {
        
        if serverInfoData.count > 0 {

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

                if let serverInfo = Q3ServerInfo(dictionary: infoDict) {
                    var serverInfo = serverInfo
                    return serverInfo
                }
            }
        }
        
        return nil
    }

    func parseServerStatus(_ serverStatusData: Data) {
//        if serverStatusData.count {
//            if delegate?.responds(to: #selector(self.willStartParsingServerStatusDataForParser)) {
//                delegate?.willStartParsingServerStatusData(for: self)
//            }
//            let usefulData = serverStatusData.subdata(with: NSRange(location: 20, length: serverStatusData.count - 20))
//            var statusResponse = String(usefulData, encoding: String.Encoding.ascii)
//            statusResponse = statusResponse.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//            let statusComponents: [Any] = statusResponse.components(separatedBy: "\n")
//            let serverStatus: String = statusComponents[0]
//            if statusComponents.count > 1 {
//                    // -- We got players
//                let playersStatus: [Any] = statusComponents[NSRange(location: 1, length: statusComponents.count - 1).location..<NSRange(location: 1, length: statusComponents.count - 1).location + NSRange(location: 1, length: statusComponents.count - 1).length]
//                parsePlayersStatus(playersStatus)
//            }
//            var status: [Any] = serverStatus.components(separatedBy: "\\")
//            status = status.filter { NSPredicate(format: "SELF != ''").evaluate(with: $0) }
//            var keys = [Any]()
//            var values = [Any]()
//            (status as NSArray).enumerateObjects(usingBlock: {(_ obj: Any, _ idx: Int, _ stop: Bool) -> Void in
//                if idx % 2 {
//                    values.append(obj)
//                }
//                else {
//                    keys.append(obj)
//                }
//            })
//            if keys.count == values.count {
//                let infoD = [AnyHashable: Any](objects: values, forKeys: keys)
//                delegate?.didFinishParsingServerStatusData(for: self, withServerStatus: infoD)
//            }
//        }
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

    private func parsePlayersStatus(_ playersStatus: [Any]) {
//        if playersStatus.count {
//            var players = [Any]()
//            delegate?.willStartParsingServerPlayers(for: self)
//            for p: String in playersStatus {
//                let playerComponents: [Any] = p.components(separatedBy: CharacterSet.whitespaces)
//                if playerComponents.count == 3 {
//                    let player = AGQ3ServerPlayer(name: playerComponents[2], withPing: playerComponents[1], withScore: playerComponents[0])
//                    if player {
//                        players.append(player)
//                    }
//                }
//            }
//            delegate?.didFinishParsingServerPlayers(for: self, withPlayers: players)
//        }
    }
}
