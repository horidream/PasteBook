//
//  PBUtil.swift
//  PasteBook
//
//  Created by Baoli Zhai on 5/16/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation

public struct PBUtil {
    
    //delay \(delay) seconds to call the closure
    static var token:Int = 0
    public static func delay(_ delay:Double, queue:DispatchQueue? = nil, closure:@escaping ()->()) {
        let q = queue ?? DispatchQueue.main as DispatchQueue
        q.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
