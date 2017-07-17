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
    private var activeInfoRequests = [Q3ServerInfoRequest]()
    private var activeStatusRequests = [Q3ServerStatusRequest]()
    
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
                if let index = self.activeInfoRequests.index(of: request) {
                    self.activeInfoRequests.remove(at: index)
                }
            })
            self.activeInfoRequests.append(request)
        }
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
}
