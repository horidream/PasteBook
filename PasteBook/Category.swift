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
    static let unsaved = Category("UNDEFINED")
    var color:UInt64
    
    init(_ name:String){
        self.color = 0
        super.init(name: name)
    }
    

    init(_ result: FMResultSet) {
        self.color = result.unsignedLongLongInt(forColumn: ColumnKey.CATEGORY_COLOR)
        super.init(name:result.string(forColumn: ColumnKey.CATEGORY_NAME))
    }
}
