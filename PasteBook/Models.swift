//
//  PBDBModels.swift
//  PasteBook
//
//  Created by Baoli Zhai on 27/11/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation
import FMDB


// MARK: - saved enum
enum Saved{
    case cloud(id:UInt64)
    case local(id:UInt64)
    case notYet
}

func == (lhs: Saved, rhs: Saved) -> Bool {
    switch (lhs, rhs) {
    case (.cloud(let a),   .cloud(let b))   where a == b: return true
    case (.local(let a), .local(let b)) where a == b: return true
    case (.notYet, .notYet): return true
    default: return false
    }
}

// MARK: - db entity
struct Category{
    var isSaved:Saved
    var name:String
    
    static let `default` = Category(name:"__default__")
    
    init(name:String){
        self.name = name
        self.isSaved = .notYet
    }
}

struct Tag{
    var isSaved:Saved
    var name:String
    var createdTime:Date?
    var updatedTime:Date?
    
    init(name:String){
        self.isSaved = .notYet
        self.name = name
        let currentDate = Date()
        self.createdTime = currentDate
        self.updatedTime = currentDate
    }
    
    init(fetchResult:FMResultSet){
        self.isSaved = .local(id:fetchResult.unsignedLongLongInt(forColumn: "id"))
        self.name = fetchResult.string(forColumn: "name")!
    }
}

struct Article{
    var title:String
    var content:String
    
    var createdTime:Date
    var updatedTime:Date
    var isSaved:Saved
    
    var isFavorite:Bool
    var category:Category
    var tags:[Tag]
    
    init(title:String, content:String){
        self.isSaved = .notYet
        self.title = title
        self.content = content
        self.category = Category.default
        
        let currentDate = Date()
        self.createdTime = currentDate
        self.updatedTime = currentDate
        self.isFavorite = false
        self.tags = []
    }
}
