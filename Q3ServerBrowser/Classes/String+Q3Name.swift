//
//  String+Q3Name.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 27/07/2017.
//
//

import Foundation

extension String {
    
    func stripQ3Colors() -> String {
        guard self.characters.count > 0 else {
            return ""
        }
        
        var decodedString = ""
        
        do {
            let regex = try NSRegularExpression(pattern: "\\^+[a-z0-9]", options: .caseInsensitive)
            decodedString = regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.characters.count), withTemplate: "")
        } catch (let error) {
            print(error)
        }
        return decodedString
    }
}
