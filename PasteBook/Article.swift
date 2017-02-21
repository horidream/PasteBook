//
//  Article.swift
//  Knoma
//
//  Created by Baoli Zhai on 28/01/2017.
//  Copyright © 2017 Baoli Zhai. All rights reserved.
//
import CloudKit
import FMDB

struct ColumnKey{
    static let ARTICLE_ID:String = "article_id"
    static let ARTICLE_TITLE:String = "article_title"
    static let ARTICLE_CONTENT:String = "article_content"
    static let FAVORITE:String = "favorite"
    
    
    
    static let CATEGORY_ID:String = "category_id"
    static let CATEGORY_NAME:String = "category_name"
    static let CATEGORY_COLOR:String = "category_color"
    
    
    static let CREATED_TIME:String = "created_time"
    static let UPDATED_TIME:String = "updated_time"
    static let CLOUD_ID:String = "cloud_record_id"
    
}


class Article: BaseEntity{
    var content:String
    var createdTime:Date
    var updatedTime:Date
    var isFavorite:Bool = false
    
    var category:Category
    var tags:[Tag]
    
    private var _record:CKRecord?
    
    
    init(title:String, content:String){
        self.name = title
        self.content = content
        
        let currentDate = Date()
        self.createdTime = currentDate
        self.updatedTime = currentDate
        
        self.category = Category.unsaved
        self.tags = []
    }
    
    // MARK: -
    required init(_ articleResult:FMResultSet, categoryResult:FMResultSet, tagResults:[FMResultSet]){
        self.name = result.string(forColumn: ColumnKey.ARTICLE_TITLE)!
        self.content = result.string(forColumn: ColumnKey.ARTICLE_CONTENT)!
        self.localId = result.unsignedLongLongInt(forColumn: ColumnKey.ARTICLE_ID)
        self.cloudId = result.unsignedLongLongInt(forColumn: ColumnKey.CLOUD_ID)
        self.isFavorite = result.bool(forColumn: ColumnKey.FAVORITE)
        self.createdTime = result.date(forColumn: ColumnKey.CREATED_TIME)!
        self.updatedTime = result.date(forColumn: ColumnKey.UPDATED_TIME)!
        
        self.category = Category(name: result.string(forColumn: ColumnKey.CATEGORY_NAME)!)
        self.category.isSaved = .local(id: result.unsignedLongLongInt(forColumn: ColumnKey.CATEGORY_ID))
        
    }
    
    
    
    // MARK: -
    required init(record:CKRecord){
        self.isSaved = .cloud(id: NSKeyedArchiver.archivedData(withRootObject: record.recordID))
        self.title = record.value(forKey: ColumnKey.ARTICLE_TITLE) as! String
        self.content = record.value(forKey: ColumnKey.ARTICLE_CONTENT) as! String
        self.createdTime = record.value(forKey: ColumnKey.CREATED_TIME) as! Date
        self.updatedTime = record.value(forKey: ColumnKey.UPDATED_TIME) as! Date
        self.isFavorite = record.value(forKey: ColumnKey.FAVORITE) as! Bool
        self.category = Category(record:record)
    }
    
    
    var record :CKRecord {
        get{
            let record = CKRecord(recordType: "article")
            record.setValue(title, forKey: "article_title")
            record.setValue(content, forKey: "article_content")
            record.setValue(isFavorite, forKey:"isFavorite")
            let categoryRef = CKReference(record: self.category.record, action: .none)
            record.setValue(categoryRef, forKey:"category")
            return record
        }
        set{
            _record = newValue
        }
        
    }
    
    
    func saveToCloud(completionHandler: @escaping (CKRecord?, Error?) -> Void){
        CKContainer.default().privateCloudDatabase.save(self.record, completionHandler: completionHandler)
    }
    
    var description: String{
        return "Article: {title: \(title), content: \(content), isSaved:\(isSaved)}"
    }
}
