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
    
    func icon(fontSize:CGFloat, fontColor:UIColor) -> UIImage{
        let font = UIFont(name: "ionicons", size: fontSize)
        let style = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .left
        let attr = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: fontColor,
            NSParagraphStyleAttributeName: style
        ]
        
        let size = self.size(attributes: attr)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rect = CGRect(origin: .zero, size: size)
        self.draw(in: rect, withAttributes: attr)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

}


// MARK: - global functions
func delay(_ delay:Double, queue:DispatchQueue? = nil, closure:@escaping ()->()) {
    let q = queue ?? DispatchQueue.main as DispatchQueue
    q.asyncAfter(
        deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(delay/1000)), execute: closure)
}


public extension UIColor {
    convenience init(_ hexColor:UInt, alpha:CGFloat = 1.0) {
        let r = CGFloat(hexColor >> 16 & 0xFF)/255.0
        let g = CGFloat(hexColor >> 8 & 0xFF)/255.0
        let b = CGFloat(hexColor >> 0 & 0xFF)/255.0
        self.init(red:r,green:g,blue:b,alpha:alpha)
    }
}

