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

    private let serverInfoQueue = OperationQueue()
    private let statusInfoQueue = DispatchQueue(label: "com.q3browser.status-info.queue")
    private var activeStatusRequests = [Q3ServerStatusRequest]()
    
    func requestServerInfo(ip: String, port: String) {
        
        guard let port = UInt16(port) else {
            return
        }
        
        let infoOperation = Q3ServerInfoOperation(ip: ip, port: port)

        infoOperation.completionBlock = { [unowned self, infoOperation] in
            if let error = infoOperation.error {
                self.delegate?.serverController(self, didFinishWithError: error)
            } else if let ping = infoOperation.executionTime {
                let data = infoOperation.data
                self.delegate?.serverController(self, didFinishFetchingServerInfoWith: data, for: infoOperation.ip, port: infoOperation.port, ping: ping)
            }
        }
        
        self.delegate?.didStartFetchingInfo(forServerController: self)
        serverInfoQueue.addOperation(infoOperation)
    }

    func statusForServer(ip: String, port: String) {
        
        statusInfoQueue.async {
            
            guard let port = UInt16(port) else {
                return
            }
            
            let request = Q3ServerStatusRequest(ip: ip, port: port)
            self.delegate?.didStartFetchingInfo(forServerController: self)
            request.execute(completion: { [unowned self] (data, address, error) in
                
                if let data = data, let address = address {
                    self.delegate?.serverController(self, didFinishFetchingServerStatusWith: data, for: address)
                } else {
                    self.delegate?.serverController(self, didFinishWithError: error)
                }
                if let index = self.activeStatusRequests.index(of: request) {
                    self.activeStatusRequests.remove(at: index)
                }
            })
            self.activeStatusRequests.append(request)
        }
    }
    
    func clearPendingRequests() {
        serverInfoQueue.cancelAllOperations()
    }
}
