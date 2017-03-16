//
//  Tags.swift
//  Knoma
//
//  Created by Baoli Zhai on 29/01/2017.
//  Copyright © 2017 Baoli Zhai. All rights reserved.
//

import Foundation
import CloudKit
import FMDB


class LocalTag:Tag, LocalManageable{
    var localId: UInt64?
    convenience init(_ fetchResult:FMResultSet){
        self.init(name: fetchResult.string(forColumn: "tag_name")!)
        self.localId = fetchResult.unsignedLongLongInt(forColumn: "id")
    }
    
    func saveToLocal() {
        
    }
    func deleteFromLocal() {
        
    }
}

class CloudTag:Tag, CloudManageable{
    var cloudRecord: CKRecord?

    func saveToCloud() {
        
    }
    func deleteFromCloud() {
        
    }
}

class Tag:BaseEntity{
}
