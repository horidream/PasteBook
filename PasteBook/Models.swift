//
//  PBDBModels.swift
//  PasteBook
//
//  Created by Baoli Zhai on 27/11/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation
import FMDB

struct Category{
    var id:UInt64?
    var name:String
    
    static let `default` = Category(name:"__default__")
    
    init(name:String){
        self.id = nil
        self.name = name
    }
}

struct Tag{
    var id:UInt64?
    var name:String
    var createdTime:Date?
    var updatedTime:Date?
    
    init(name:String){
        self.id = nil
        self.name = name
        let currentDate = Date()
        self.createdTime = currentDate
        self.updatedTime = currentDate
    }
    
    init(fetchResult:FMResultSet){
        self.id = fetchResult.unsignedLongLongInt(forColumn: "id")
        self.name = fetchResult.string(forColumn: "name")!
    }
}

struct Article{
    var id:UInt64?
    var title:String
    var content:String
    var category:Category
    var createdTime:Date
    var updatedTime:Date
    var isFavorite:Bool
    
    
    init(title:String, content:String){
        self.id = nil
        self.title = title
        self.content = content
        self.category = Category.default
        let currentDate = Date()
        self.createdTime = currentDate
        self.updatedTime = currentDate
        self.isFavorite = false
    }
}
