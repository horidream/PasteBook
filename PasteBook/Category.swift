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


class LocalCategory:Category, LocalManageable{
    
    static let undefined:LocalCategory = {
        let c = LocalCategory("UNDEFINED")
        c.saveToLocal()
        return c
    }()
    
    
    var localId: UInt64?
    var count:UInt{
        if let localId = self.localId{
            let result = PBDBManager.default.execute("select count(article.category_id) as article_count from article where category_id = \(localId)")
            return UInt(result?.unsignedLongLongInt(forColumn: "article_count") ?? 0)
        }else{
            return 0
        }
    }
    
    convenience init?(localId:UInt64){
        if let rst = PBDBManager.default.execute("select * from category where category_id=\(localId)"){
            self.init(rst)
        }
        return nil
    }
    
    convenience init(_ result: FMResultSet) {
        self.init(result.string(forColumn: ColumnKey.CATEGORY_NAME))
        self.color = UInt(result.unsignedLongLongInt(forColumn: ColumnKey.CATEGORY_COLOR))
        self.localId = result.unsignedLongLongInt(forColumn: ColumnKey.CATEGORY_ID)
        self.needsUpdate = false
    }

    func saveToLocal(){
        if localId == nil {
            _ = PBDBManager.default.queryChange("INSERT OR IGNORE INTO category (category_name, category_color) VALUES (?, ?)", args:[self.name, self.color])
            let categoryId = PBDBManager.default.queryFetch("SELECT category_id from category where category_name=?", args:[self.name], mapTo: {
                $0.unsignedLongLongInt(forColumn: "category_id")
            }).first!
            self.localId = categoryId
        }else if needsUpdate{
            let query = "UPDATE category set category_name=?, cagegory_color=? WHERE category_id=?"
            _ = PBDBManager.default.queryChange(query, args:[self.name, self.color, self.localId!])
        }
        self.needsUpdate = false
        
    }
}


class CloudCategory:Category, CloudManageable{
    var cloudRecord: CKRecord?
    func saveToCloud() {
        let record:CKRecord
        if cloudRecord == nil{
            record = CKRecord(recordType: "category")
            needsUpdate = true
        }else{
            record = self.cloudRecord!
        }
        if needsUpdate{
            record["category_name"] = self.name as CKRecordValue
            record["category_color"] = self.color as CKRecordValue
            let db = CloudKitManager.instance.privateDB
            db.save(record, completionHandler: { (savedRecord, err) in
                if(err == nil){
                    self.cloudRecord = savedRecord
                    self.needsUpdate = false
                }else{
                    //TODO: handle saving error
                }
            })
        }
        
    }

}
// MARK: - db entity
class Category:BaseEntity, Equatable{
    
    static func == (lhs: Category, rhs: Category) -> Bool{
        return lhs.name == rhs.name
    }
    
    var color:UInt
    
    init(_ name:String){
        self.color = 0xFF9900
        super.init(name: name)
    }
    
}
