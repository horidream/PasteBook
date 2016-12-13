//
//  Regex.swift
//  PasteBook
//
//  Created by Baoli Zhai on 14/12/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation

class Regex {
    let internalExpression: NSRegularExpression?
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        self.internalExpression = try? NSRegularExpression(pattern: pattern, options:[])
    }
    
    func test(_ input: String) -> Bool {
        if let matches = self.internalExpression?.matches(in: input, options: [], range:NSMakeRange(0, input.utf16.count)){
            return matches.count > 0
            
        }
        return false
    }
}
