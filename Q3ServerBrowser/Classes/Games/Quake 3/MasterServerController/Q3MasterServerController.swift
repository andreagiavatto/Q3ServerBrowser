//
//  Q3MasterController.h
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/7/14.
//


import Foundation
import CocoaAsyncSocket

class Q3MasterServerController: NSObject, MasterServerControllerProtocol {
    
    weak var delegate: MasterServerControllerDelegate?

    let masterServerQueue = OperationQueue()
    
    func startFetchingServersList(host: String, port: String) {
        
        guard let port = UInt16(port) else {
            return
        }
        
        let getServersRequestMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x65, 0x72, 0x76, 0x65, 0x72, 0x73, 0x20, 0x36, 0x38, 0x20, 0x65, 0x6d, 0x70, 0x74, 0x79, 0x20, 0x66, 0x75, 0x6c, 0x6c]
        let getServersResponseMarker: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x65, 0x72, 0x76, 0x65, 0x72, 0x73, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x5c] // YYYYgetserversResponse\
        let eotMarker: [UInt8] = [0x5c, 0x45, 0x4f, 0x54, 0x0, 0x0, 0x0] // \EOT000
        
        let masterServersOperation = Q3Operation(ip: host, port: port, requestMarker: getServersRequestMarker, responseMarker: getServersResponseMarker, eotMarker: eotMarker)
        masterServersOperation.completionBlock = { [unowned self, weak masterServersOperation] in
            
            guard let masterServersOperation = masterServersOperation else {
                return
            }
            
            if masterServersOperation.isCancelled {
                return
            }
            
            if let error = masterServersOperation.error {
                self.delegate?.masterController(self, didFinishWithError: error)
            } else {
                self.delegate?.masterController(self, didFinishFetchingServersWith: masterServersOperation.data)
            }
        }
        
        masterServerQueue.addOperation(masterServersOperation)
        
        delegate?.didStartFetchingServers(forMasterController: self)
    }
}
