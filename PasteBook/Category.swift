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
struct Category{
    var isSaved:Saved
    var name:String
    
    static let unsaved = Category(name:"UNDEFINED")
    
    init(name:String){
        self.name = name
        self.isSaved = .notYet
    }
    
    init(name:String, id:UInt64){
        self.name = name
        self.isSaved = Saved.local(id:id)
    }
}
