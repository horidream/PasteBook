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

class Article: BaseEntity, Equatable{
    var title:String{
        get{
            return self.name
        }
        set{
            self.name = title
        }
    }
    var content:String{
        didSet{
            checkNeedsUpdate(oldValue, with: content)
        }
    }
    var createdTime:Date{
        didSet{
            checkNeedsUpdate(oldValue, with: createdTime)
        }
    }

    var updatedTime:Date{
        didSet{
            checkNeedsUpdate(oldValue, with: updatedTime)
        }
    }

    var isFavorite:Bool = false{
        didSet{
            checkNeedsUpdate(oldValue, with: isFavorite)
        }
    }

    var categoryId:UInt64?{
        didSet{
            checkNeedsUpdate(oldValue, with: categoryId)
        }
    }

    
    
    var color:UIColor{
        return UIColor(category.color)
    }
    var category:Category{
        get{
            if let categoryId = self.categoryId{
                return Category(localId: categoryId)
            }else{
                return Category.undefined
            }
        }
        set{
            if let id = newValue.localId{
                self.localId = id
            }
        }
    }
    var tags:[Tag]{
        return []
    }
    
    // MARK: -
    static func == (lhs: Article, rhs: Article) -> Bool{
        return lhs.name == rhs.name && lhs.content == rhs.content && lhs.isFavorite == rhs.isFavorite && lhs.categoryId == rhs.categoryId
        
    }
    
    init(title:String, content:String){
        self.content = content

        let currentDate = Date()
        self.createdTime = currentDate
        self.updatedTime = currentDate
        super.init(name:title)
    }
    
    
    
    
    // MARK: - local
    convenience init(localId:UInt64){
        if let rst = PBDBManager.default.execute("select * from article where article_id == \(localId)"){
            self.init(rst)
        }else{
            self.init(title:"", content:"")
        }
    }
    
    init(_ articleResult:FMResultSet){
        self.content = articleResult.string(forColumn: ColumnKey.ARTICLE_CONTENT)!
        self.isFavorite = articleResult.bool(forColumn: ColumnKey.FAVORITE)
        self.createdTime = articleResult.date(forColumn: ColumnKey.CREATED_TIME)!
        self.updatedTime = articleResult.date(forColumn: ColumnKey.UPDATED_TIME)!
        self.categoryId =  articleResult.unsignedLongLongInt(forColumn: ColumnKey.CATEGORY_ID)
        
       
        
        super.init(name:articleResult.string(forColumn: ColumnKey.ARTICLE_TITLE)!)
        let recStr:String = articleResult.string(forColumn: ColumnKey.CLOUD_ID) ?? ""
        self.cloudRecord = CKRecord(recordType: "article", recordID: CKRecordID.parseString(str: recStr)!)
        self.localId = articleResult.unsignedLongLongInt(forColumn: ColumnKey.ARTICLE_ID)
        self.needsUpdateToLocal = false
        
    }
    
    func saveToLocal(){
        self.category.saveToLocal()
        if localId == nil{
            let query = "INSERT INTO article (article_title, article_content, category_id, updated_time, created_time, cloud_record_id) VALUES (?, ?, ?, ?, ?, ?)"
            
            if localDB.queryChange(query, args:[self.title, self.content, category.localId!, self.updatedTime as NSDate, self.createdTime as NSDate, self.cloudIDStringRepresentation]){
                let articleId = localDB.queryFetch("SELECT article_id from article where article_title=? and article_content=?", args:[self.title, self.content], mapTo: {
                    $0.unsignedLongLongInt(forColumn: "article_id")
                }).first!
                self.localId = articleId
                self.needsUpdateToLocal = false
            }
        }else if needsUpdateToLocal{
            let query = "UPDATE article set article_title=?, article_content=?, category_id=?, updated_time=?, cloud_record_id=? WHERE article_id=?"
            if localDB.queryChange(query, args:[self.title, self.content, category.localId!, self.updatedTime, self.cloudIDStringRepresentation , self.localId!]){
                self.needsUpdateToLocal = false
                
            }
        }
        
    }
    
    func deleteFromLocal() {
        if let id = localId{
            _ = localDB.execute("DELETE FROM tagged_article where article_id=?", args: [id])
            _ = localDB.execute("DELETE FROM article where article_id=?", args: [id])
        }
    }
    
    // MARK: - 
    init(_ record:CKRecord){
        self.content = record[ColumnKey.ARTICLE_CONTENT] as! String
        self.isFavorite = record[ColumnKey.FAVORITE] as? Bool ?? false
        self.createdTime = record[ColumnKey.CREATED_TIME] as! Date
        self.updatedTime = record[ColumnKey.UPDATED_TIME] as! Date
        self.categoryId =  record[ColumnKey.CATEGORY_ID] as? UInt64
        
        super.init(name:record[ColumnKey.ARTICLE_TITLE] as! String)
        self.cloudRecord = record
        self.needsUpdateToCloud = false
        
    }
    func saveToCloud() {
        self.category.saveToCloud()
        let record:CKRecord
        if cloudRecord == nil{
            record = CKRecord(recordType: "article")
            needsUpdateToCloud = true
        }else{
            record = self.cloudRecord!
        }
        if needsUpdateToCloud{
            record["article_title"] = self.title as CKRecordValue
            record["article_content"] = self.content as CKRecordValue
            record["category"] = CKReference(record: category.cloudRecord!, action: .none)
            record[ColumnKey.UPDATED_TIME] = self.updatedTime as CKRecordValue
            record[ColumnKey.CREATED_TIME] = self.createdTime as CKRecordValue
            cloudDB.save(record, completionHandler: { (savedRecord, err) in
                if(err == nil){
                    self.cloudRecord = savedRecord
                    self.needsUpdateToCloud = false
                    self.saveToLocal()
                }else{
                    //TODO: handle saving error
                }
            })
        }
    }
    
}
