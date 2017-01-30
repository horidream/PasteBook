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
    var isSaved:Saved
    var name:String
    var color:UInt64
    
    init(name:String){
        self.isSaved = .notYet
        self.name = name
        self.color = 0
    }
    
    init(id:UInt64, name:String, color:UInt64){
        self.isSaved = .local(id: id)
        self.name = name
        self.color = color
    }
    
    static func createTags(ids:[UInt64], names:[String], colors:[UInt64])->[Tag]
    {
        var arr = [Tag]()
        guard ids.count == names.count, ids.count == colors.count else{
            return arr
        }
        for (idx, id) in ids.enumerated(){
            arr.append(Tag(id:id, name:names[idx], color:colors[idx]))
        }
        return arr
    }
    
    
    init(fetchResult:FMResultSet){
        self.isSaved = .local(id:fetchResult.unsignedLongLongInt(forColumn: "id"))
        self.name = fetchResult.string(forColumn: "tag_name")!
        self.color = fetchResult.unsignedLongLongInt(forColumn: "tag_color")
    }
}
