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
    var categoryId:UInt64?
    
    
    var color:UIColor{
        return UIColor(category.color)
    }
    var category:Category{
        if let categoryId = self.categoryId{
            return Category(localId: categoryId)
        }else{
            return Category.undefined
        }
    }
    var tags:[Tag]{
        return []
    }
    
    private var _record:CKRecord?
    
    var title:String{
        get{
            return self.name
        }
        set{
            self.name = title
        }
    }

    init(title:String, content:String){
        self.content = content

        let currentDate = Date()
        self.createdTime = currentDate
        self.updatedTime = currentDate
//        self.categoryId
        super.init(name:title)
    }
    
    
    
    // MARK: -
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
        self.localId = articleResult.unsignedLongLongInt(forColumn: ColumnKey.ARTICLE_ID)
        self.cloudId = articleResult.unsignedLongLongInt(forColumn: ColumnKey.CLOUD_ID)
        
        
    }
    
    
    
}
