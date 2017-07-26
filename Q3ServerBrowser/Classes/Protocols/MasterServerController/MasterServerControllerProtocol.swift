//
//  MasterServerControllerProtocol.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/14/14.
//
//

import Foundation

protocol MasterServerControllerProtocol {
    
    weak var delegate: MasterServerControllerDelegate? { get set }

    func startFetchingServersList(host: String, port: String)
}
