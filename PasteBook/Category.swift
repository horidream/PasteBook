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
    static let undefined = Category("UNDEFINED")
    var color:UInt64
    var count:UInt{
        return 0
    }
    init(_ name:String){
        self.color = 0
        super.init(name: name)
    }
    
    convenience init(localId:UInt64){
        if let rst = PBDBManager.default.execute("select * from category where category_id=\(localId)"){
            self.init(rst)
        }else{
            self.init("")
        }
    }
    
    init(_ result: FMResultSet) {
        self.color = result.unsignedLongLongInt(forColumn: ColumnKey.CATEGORY_COLOR)
        super.init(name:result.string(forColumn: ColumnKey.CATEGORY_NAME))
    }
}
