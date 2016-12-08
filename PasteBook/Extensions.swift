//
//  PBUtil.swift
//  PasteBook
//
//  Created by Baoli Zhai on 5/16/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation

// MARK: - extensions


extension String {
    
    // java, javascript, PHP use 'split' name, why not in Swift? :)
    func split(_ regex: String) -> Array<String> {
        do{
            let regEx = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options())
            let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
            let modifiedString = regEx.stringByReplacingMatches (in: self, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, characters.count), withTemplate:stop)
            return modifiedString.components(separatedBy: stop)
        } catch {
            return []
        }
    }
}


// MARK: - global functions
func delay(_ delay:Double, queue:DispatchQueue? = nil, closure:@escaping ()->()) {
    let q = queue ?? DispatchQueue.main as DispatchQueue
    q.asyncAfter(
        deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(delay/1000)), execute: closure)
}

