//
//  Tags.swift
//  Knoma
//
//  Created by Baoli Zhai on 29/01/2017.
//  Copyright © 2017 Baoli Zhai. All rights reserved.
//

import Foundation
import CloudKit
import FMDB

class Tag:BaseEntity{
    var color:UInt64
    
    init(_ name:String){
        self.color = 0
        super.init(name: name)
    }
    
    
    init(_ fetchResult:FMResultSet){
        self.color = fetchResult.unsignedLongLongInt(forColumn: "tag_color")
        super.init(name: fetchResult.string(forColumn: "tag_name")!)
        self.localId = fetchResult.unsignedLongLongInt(forColumn: "id")
    }
}
