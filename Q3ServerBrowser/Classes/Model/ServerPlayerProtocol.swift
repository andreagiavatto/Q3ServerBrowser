//  Converted with Swiftify v1.0.6395 - https://objectivec2swift.com/
//
//  ServerPlayerProtocol.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 3/23/14.
//
//

import Foundation

protocol ServerPlayerProtocol {
    
    var name: String { get }
    var ping: String { get }
    var score: String { get }

    init?(line: String)
}
