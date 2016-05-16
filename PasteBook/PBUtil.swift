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
    static var token:dispatch_once_t = 0
    public static func delay(delay:Double, queue:dispatch_queue_t? = nil, closure:()->()) {
        let q = queue ?? dispatch_get_main_queue() as dispatch_queue_t
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            q, closure)
    }
    
}