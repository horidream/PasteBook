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
    
}

struct EntitySet<T,U> where T:LocalManageable, U:CloudManageable{
    let local:T?
    let cloud:U?
}
typealias ArticleSet = EntitySet<LocalArticle, CloudArticle>
//typealias CategorySet = EntitySet<
class LocalArticle:Article, LocalManageable{
    var localId:UInt64?
    var category:LocalCategory!
    convenience init?(localId:UInt64){
        if let rst = PBDBManager.default.execute("select * from article where article_id == \(localId)"){
            self.init(rst)
        }else{
            return nil
        }
    }
    
    convenience init(_ articleResult:FMResultSet){
        let content = articleResult.string(forColumn: ColumnKey.ARTICLE_CONTENT)!
        self.init(title:articleResult.string(forColumn: ColumnKey.ARTICLE_TITLE)!, content: content)
        
        self.isFavorite = articleResult.bool(forColumn: ColumnKey.FAVORITE)
        self.createdTime = articleResult.date(forColumn: ColumnKey.CREATED_TIME)!
        self.updatedTime = articleResult.date(forColumn: ColumnKey.UPDATED_TIME)!
        self.localId = articleResult.unsignedLongLongInt(forColumn: ColumnKey.ARTICLE_ID)
        let categoryId =  articleResult.unsignedLongLongInt(forColumn: ColumnKey.CATEGORY_ID)
        self.category = LocalCategory(localId:categoryId)
        
    }
    
    func saveToLocal(){
        self.category?.saveToLocal()
        if localId == nil{
            let query = "INSERT INTO article (article_title, article_content, category_id, updated_time, created_time) VALUES (?, ?, ?, ?, ?)"
            
            if localDB.queryChange(query, args:[self.title, self.content, category.localId!, self.updatedTime as NSDate, self.createdTime as NSDate]){
                let articleId = localDB.queryFetch("SELECT article_id from article where article_title=? and article_content=?", args:[self.title, self.content], mapTo: {
                    $0.unsignedLongLongInt(forColumn: "article_id")
                }).first!
                self.localId = articleId
                self.needsUpdate = false
            }
        }else if needsUpdate{
            let query = "UPDATE article set article_title=?, article_content=?, category_id=?, updated_time=? WHERE article_id=?"
            if localDB.queryChange(query, args:[self.title, self.content, category.localId!, self.updatedTime , self.localId!]){
                self.needsUpdate = false
                
            }
        }
        
    }
    
    func deleteFromLocal() {
        if let id = localId{
            _ = localDB.execute("DELETE FROM tagged_article where article_id=?", args: [id])
            _ = localDB.execute("DELETE FROM article where article_id=?", args: [id])
        }
    }
}


class CloudArticle:Article, CloudManageable{
    var cloudRecord: CKRecord?
    var category:CloudCategory!
    // MARK: -
    convenience init(_ record:CKRecord){
        let content = record[ColumnKey.ARTICLE_CONTENT] as! String
        self.init(title:record[ColumnKey.ARTICLE_TITLE] as! String, content:content)
        self.isFavorite = record[ColumnKey.FAVORITE] as? Bool ?? false
        self.createdTime = record[ColumnKey.CREATED_TIME] as! Date
        self.updatedTime = record[ColumnKey.UPDATED_TIME] as! Date
        self.cloudRecord = record
        self.needsUpdate = false
        
    }
    
    func saveToCloud() {
        let record:CKRecord
        if cloudRecord == nil{
            record = CKRecord(recordType: "article")
            needsUpdate = true
        }else{
            record = self.cloudRecord!
        }
        if needsUpdate{
            record["article_title"] = self.title as CKRecordValue
            record["article_content"] = self.content as CKRecordValue
            record["category"] = CKReference(record: category.cloudRecord!, action: .none)
            record[ColumnKey.UPDATED_TIME] = self.updatedTime as CKRecordValue
            record[ColumnKey.CREATED_TIME] = self.createdTime as CKRecordValue
            cloudDB.save(record, completionHandler: { (savedRecord, err) in
                if(err == nil){
                    self.cloudRecord = savedRecord
                    self.needsUpdate = false
                }else{
                    //TODO: handle saving error
                }
            })
        }
    }
    
    func deleteFromCloud() {
        
    }
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
    var isFavorite:Bool = false{
        didSet{
            checkNeedsUpdate(oldValue, with: isFavorite)
        }
    }
    var createdTime:Date
    var updatedTime:Date
    var tags:[Tag]{
        return []
    }
    
    // MARK: -
    static func == (lhs: Article, rhs: Article) -> Bool{
        return lhs.name == rhs.name && lhs.content == rhs.content
    }
    
    init(title:String, content:String){
        self.content = content

        let currentDate = Date()
        self.createdTime = currentDate
        self.updatedTime = currentDate
        super.init(name:title)
    }
    
    
    
    
    
    
    
    
}
