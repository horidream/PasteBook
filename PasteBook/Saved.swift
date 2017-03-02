//
//  PBDBModels.swift
//  PasteBook
//
//  Created by Baoli Zhai on 27/11/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//


// MARK: - saved enum

import CloudKit
import FMDB


enum Saved{
    case cloud(id:Data)
    case local(id:UInt64)
    case notYet
    
    var id:Any?{
        switch self{
        case .notYet:
            return nil
        case .cloud(id: let id):
            return id
        case .local(id: let id):
            return id
        }
    }
}


protocol CloudManageable {
    var cloudRecord:CKRecord?{get set}
    var needsUpdateToCloud:Bool{get set}
    func saveToCloud()
}


protocol LocalManageable{
    var localId:UInt64?{get set}
    var needsUpdateToLocal:Bool{get set}
    func saveToLocal()
}

extension LocalManageable{
    func saveToLocal(){}
}

extension CloudManageable{
    func saveToCloud(){}
    var cloudIDStringRepresentation:String{
        return self.cloudRecord?.recordID.toString() ?? ""
    }
}

class BaseEntity: LocalManageable, CloudManageable{
    var localId:UInt64?
    var cloudRecord: CKRecord?
    var needsUpdateToCloud: Bool
    var needsUpdateToLocal:Bool
    
    
    var name:String
    init(name:String){
        self.needsUpdateToLocal = true
        self.needsUpdateToCloud = true
        self.name = name
    }
}



func == (lhs: Saved, rhs: Saved) -> Bool {
    switch (lhs, rhs) {
    case (.cloud(let a),   .cloud(let b))   where a == b: return true
    case (.local(let a), .local(let b)) where a == b: return true
    case (.notYet, .notYet): return true
    default: return false
    }
}





