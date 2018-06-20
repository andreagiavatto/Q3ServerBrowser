//
//  String+Q3Name.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 27/07/2017.
//
//

import Foundation

public extension String {
    
    func stripQ3Colors() -> String {
        guard self.count > 0 else {
            return ""
        }
        
        var decodedString = ""
        
        do {
            let regex = try NSRegularExpression(pattern: "\\^+[0-9]", options: .caseInsensitive)
            decodedString = regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.count), withTemplate: "")
            let regex2 = try NSRegularExpression(pattern: "\\^+[0-9A-Z]{6}", options: .caseInsensitive)
            decodedString = regex2.stringByReplacingMatches(in: decodedString, options: [], range: NSMakeRange(0, self.count), withTemplate: "")
        } catch (let error) {
            print(error)
        }
        return decodedString
    }
}
