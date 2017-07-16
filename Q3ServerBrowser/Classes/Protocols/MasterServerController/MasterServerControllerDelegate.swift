//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  MasterControllerDelegate.h
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/7/14.
//
//

import Foundation

protocol MasterServerControllerDelegate: NSObjectProtocol {
    
    func didStartFetchingServers(forMasterController controller: MasterServerControllerProtocol)
    func masterController(_ controller: MasterServerControllerProtocol, didFinishWithError error: Error?)
    func masterController(_ controller: MasterServerControllerProtocol, didFinishFetchingServersWith data: Data)
}

extension MasterServerControllerDelegate {
    
    func didStartFetchingServers(forMasterController controller: MasterServerControllerProtocol) {}
}
