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

class Tag{
    var name:String
    var color:UInt64
    
    init(name:String){
        self.name = name
        self.color = 0
    }
    
    
    init(_ fetchResult:FMResultSet){
        self.localId = fetchResult.unsignedLongLongInt(forColumn: "id")
        self.name = fetchResult.string(forColumn: "tag_name")!
        self.color = fetchResult.unsignedLongLongInt(forColumn: "tag_color")
    }
}
