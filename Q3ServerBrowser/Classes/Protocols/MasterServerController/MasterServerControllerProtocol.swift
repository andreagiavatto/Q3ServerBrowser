//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
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

    init(game: Game)
    func startFetchingServersList()
}
