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
struct Category: SQLManageable{
    var isSaved:Saved
    var name:String
    var color:UInt = 0
    static let unsaved = Category(name:"UNDEFINED")
    
    init(name:String){
        self.name = name
        self.isSaved = .notYet
    }
    
    init(name:String, id:UInt64){
        self.name = name
        self.isSaved = Saved.local(id:id)
    }

    init(result: FMResultSet) {
        self.name = "__"
        self.isSaved = .notYet
    }
    
    
    func saveToLocal() {
        
    }
    
    
    
    
    var record: CKRecord{
        let record = CKRecord(recordType: "category")
        record.setValue(self.name, forKey: "category_name")
        record.setValue(self.color, forKey: "category_color")
        return record
    }
}
