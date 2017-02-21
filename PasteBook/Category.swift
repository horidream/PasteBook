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
class Category{
    static let unsaved = Category(name:"UNDEFINED")
    var name:String
    var color:UInt
    
    init(name:String){
        self.name = name
        self.color = 0
    }
    

    required init(_ result: FMResultSet) {
        self.name = result.string(forColumn: ColumnKey.CATEGORY_NAME)
        self.color = result.unsignedLongLongInt(forColumn: ColumnKey.CATEGORY_COLOR)
    }
}
