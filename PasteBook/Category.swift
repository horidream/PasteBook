//
//  Category.swift
//  Knoma
//
//  Created by Baoli Zhai on 29/01/2017.
//  Copyright © 2017 Baoli Zhai. All rights reserved.
//

import Foundation
import FMDB
import CloudKit

// MARK: - db entity
class Category:BaseEntity{
    static let undefined:Category = {
        let c = Category("UNDEFINED")
        c.saveToLocal()
        return c
    }()
    
    var color:UInt
    var count:UInt{
        if let localId = self.localId{
            let result = PBDBManager.default.execute("select count(article.category_id) as article_count from article where category_id = \(localId)")
            return UInt(result?.unsignedLongLongInt(forColumn: "article_count") ?? 0)
        }else{
            return 0
        }
    }
    init(_ name:String){
        self.color = 0xFF9900
        super.init(name: name)
    }
    override var localId: UInt64?{
        didSet{
            if(localId != nil){
                Category.localCategories[localId!] = self
            }
        }
    }
    
    // MARK: - class level
    
    static var localCategories:[UInt64:Category] = [:]
    class func getCategory(localId:UInt64)->Category{
        return localCategories[localId] ?? Category.init(localId: localId)
    }
    
    // MARK: -
    convenience init(localId:UInt64){
        if let rst = PBDBManager.default.execute("select * from category where category_id=\(localId)"){
            self.init(rst)
        }else{
            self.init("")
        }
    }
    
    init(_ result: FMResultSet) {
        self.color = UInt(result.unsignedLongLongInt(forColumn: ColumnKey.CATEGORY_COLOR))
        super.init(name:result.string(forColumn: ColumnKey.CATEGORY_NAME))
        self.localId = result.unsignedLongLongInt(forColumn: ColumnKey.CATEGORY_ID)
        self.needsUpdateToLocal = false
    }
    
    
    func saveToLocal(){
        if localId == nil {
            _ = PBDBManager.default.queryChange("INSERT OR IGNORE INTO category (category_name, category_color) VALUES (?, ?)", args:[self.name, self.color])
            let categoryId = PBDBManager.default.queryFetch("SELECT category_id from category where category_name=?", args:[self.name], mapTo: {
                $0.unsignedLongLongInt(forColumn: "category_id")
            }).first!
            self.localId = categoryId
        }else if needsUpdateToLocal{
            let query = "UPDATE category set category_name=?, cagegory_color=? WHERE category_id=?"
            _ = PBDBManager.default.queryChange(query, args:[self.name, self.color, self.localId!])
        }
        self.needsUpdateToLocal = false

    }
    
    // MARK: - 
    func saveToCloud() {
        let record:CKRecord
        if cloudRecord == nil{
            record = CKRecord(recordType: "category")
            needsUpdateToCloud = true
        }else{
            record = self.cloudRecord!
        }
        if needsUpdateToCloud{
            record["category_name"] = self.name as CKRecordValue
            record["category_color"] = self.color as CKRecordValue
            let db = CloudKitManager.instance.privateDB
            db.save(record, completionHandler: { (savedRecord, err) in
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
