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





protocol CloudManageable {
    var cloudRecord:CKRecord?{get set}
    func saveToCloud()
    func deleteFromCloud()
}


protocol LocalManageable{
    var localId:UInt64?{get set}
    func saveToLocal()
    func deleteFromLocal()
}

extension LocalManageable{
    var localDB:PBDBManager{
        return PBDBManager.default
    }
    func saveToLocal(){}
    func deleteFromLocal(){}
}

extension CloudManageable{
    var cloudDB:CKDatabase {
        return CloudKitManager.instance.privateDB
    }
    func saveToCloud(){}
    func deleteFromCloud(){}
    var cloudIDStringRepresentation:String{
        return self.cloudRecord?.recordID.toString() ?? ""
    }
}

class BaseEntity{
    internal var needsUpdate:Bool
    var name:String{
        didSet{
            checkNeedsUpdate(oldValue, with: name)
        }
    }
    
    internal func checkNeedsUpdate<T:Equatable>(_ oldValue:T?, with neoValue:T?){
        if(oldValue != neoValue){
            needsUpdate = true
        }
    }
    
    init(name:String){
        self.needsUpdate = true
        self.name = name
    }
}







