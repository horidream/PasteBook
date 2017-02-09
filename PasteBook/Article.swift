//
//  Article.swift
//  Knoma
//
//  Created by Baoli Zhai on 28/01/2017.
//  Copyright © 2017 Baoli Zhai. All rights reserved.
//
import CloudKit
import FMDB

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
    
//    init(record:CKRecord){
//        self.isSaved = .cloud(id: NSKeyedArchiver.archivedData(withRootObject: record.recordID))
//        self.title = record.value(forKey: "article_title") as! String
//        self.content = record.value(forKey: "article_content") as! String
//        self.createdTime = record.value(forKey: "created_time") as! Date
//        self.updatedTime = record.value(forKey: "updated_time") as! Date
//        self.isFavorite = record.value(forKey: "favorite") as! Bool
//    }
    
    // MARK - save to icloud
    func saveToCloud(){
        let db = CKContainer.default().privateCloudDatabase
        db.save(record) { (record:CKRecord?, error:Error?) in
            if let record = record{
                self.isSaved = .cloud(id: NSKeyedArchiver.archivedData(withRootObject: record.recordID))
            }
        }
    }
    var record :CKRecord {
        get{
            let record = CKRecord(recordType: "article")
            record.setValue(title, forKey: "article_title")
            record.setValue(content, forKey: "article_content")
            record.setValue(isFavorite, forKey:"isFavorite")
            
//            _ = CKReference(record: <#T##CKRecord#>, action: <#T##CKReferenceAction#>)
            return record
        }
        
    }
    
    var description: String{
        return "Article: {title: \(title), content: \(content), isSaved:\(isSaved)}"
    }
}
