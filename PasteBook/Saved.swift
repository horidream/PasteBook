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
    init(record:CKRecord)
    func saveToCloud(_ completionHandler:@escaping (CKRecord?, Error?) -> Void)
    var record:CKRecord { get }
}

protocol SQLManageable {
    init(result:FMResultSet)
    func saveToLocal()
}

func == (lhs: Saved, rhs: Saved) -> Bool {
    switch (lhs, rhs) {
    case (.cloud(let a),   .cloud(let b))   where a == b: return true
    case (.local(let a), .local(let b)) where a == b: return true
    case (.notYet, .notYet): return true
    default: return false
    }
}




