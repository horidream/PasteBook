//
//  PBDBModels.swift
//  PasteBook
//
//  Created by Baoli Zhai on 27/11/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation
import FMDB
import CloudKit

// MARK: - saved enum
enum Saved{
    case cloud(id:UInt64)
    case local(id:UInt64)
    case notYet
    
    var id:UInt64?{
        switch self{
        case .notYet:
            return nil
        case .cloud(id: let id):
            return id
        case .local(id: let id):
            return id
        }
    }
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
    
    static let unsaved = Category(name:"UNDEFINED")
    
    init(name:String){
        self.name = name
        self.isSaved = .notYet
    }
    
    init(name:String, id:UInt64){
        self.name = name
        self.isSaved = Saved.local(id:id)
    }
}

struct Tag{
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

class Article:CustomStringConvertible{
    var title:String
    var content:String
    
    var createdTime:Date
    var updatedTime:Date
    var isSaved:Saved
    
    var isFavorite:Bool
    var category:Category
    var tags:[Tag]?
    
    init(title:String, content:String){
        self.isSaved = .notYet
        self.title = title
        self.content = content
        self.category = Category.unsaved
        
        let currentDate = Date()
        self.createdTime = currentDate
        self.updatedTime = currentDate
        self.isFavorite = false
    }
    
    init(fetchResult:FMResultSet){
        self.isSaved = .local(id:fetchResult.unsignedLongLongInt(forColumn: "article_id"))
        self.title = fetchResult.string(forColumn: "article_title")!
        self.content = fetchResult.string(forColumn: "article_content")!
        self.category = Category(name: fetchResult.string(forColumn: "category_name")!)
        self.category.isSaved = .local(id: fetchResult.unsignedLongLongInt(forColumn: "category_id"))
        self.createdTime = fetchResult.date(forColumn: "created_time")!
        self.updatedTime = fetchResult.date(forColumn: "updated_time")!
        self.isFavorite = fetchResult.bool(forColumn: "favorite")
    }
    
    func saveToCloud(){
        let db = CKContainer.default().privateCloudDatabase
        db.save(record) { (record, error) in
            self.isSaved = .cloud(id: self.isSaved.id!)
        }
    }
    var record :CKRecord {
        get{
            let record = CKRecord(recordType: "article")
            record.setValue(title, forKey: "article_title")
            record.setValue(content, forKey: "article_content")
            
            return record
        }
        
    }
    
    var description: String{
        return "Article: {title: \(title), content: \(content), isSaved:\(isSaved)}"
    }
}
