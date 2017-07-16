//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  Q3ServerController.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

import Foundation
import CocoaAsyncSocket

class Q3ServerController: NSObject, ServerControllerProtocol {
    
    weak var delegate: ServerControllerDelegate?

    private let serverInfoQueue = DispatchQueue(label: "com.q3browser.server-info.queue")
    private let statusInfoQueue = DispatchQueue(label: "com.q3browser.status-info.queue")
    private var activeRequests = [Q3ServerInfoRequest]()
    
    func requestServerInfo(ip: String, port: String) {
        
        serverInfoQueue.async { [unowned self] in

            guard let port = UInt16(port) else {
                return
            }
            
            let request = Q3ServerInfoRequest(ip: ip, port: port)
            self.delegate?.didStartFetchingInfo(forServerController: self)
            request.execute(completion: { [unowned self] (data, address, error) in
                
                if let data = data, let address = address {
                    self.delegate?.serverController(self, didFinishFetchingServerInfoWith: data, for: address)
                } else {
                    self.delegate?.serverController(self, didFinishWithError: error)
                }
                if let index = self.activeRequests.index(of: request) {
                    self.activeRequests.remove(at: index)
                }
            })
            self.activeRequests.append(request)
        }
    }

    func statusForServer(ip: String, port: String) {
        
        statusInfoQueue.async {
            
            guard let port = UInt16(port) else {
                return
            }
        }
        
//        if (ip.characters.count ?? 0) && port > 0 {
//            let command = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x0a]
//            let getStatusData = Data(bytes: command, length: MemoryLayout<command>.size)
//            let infoOperation = AGServerOperation(serverIp: ip, andPort: port, andCommand: getStatusData)
//            (infoOperation)
//            infoOperation.completionBlock() =   
//            do {
//                (weakOperation)
//                if strongOperation {
//                    if delegate?.responds(to: Selector("serverController:didFinishFetchingServerStatusWithOperation:")) {
//                        delegate?.serverController(self, didFinishFetchingServerStatusWith: strongOperation)
//                    }
//                }
//            }
//            statusQueue?.addOperation(infoOperation)
//        }
    }
}
