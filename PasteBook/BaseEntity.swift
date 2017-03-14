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
    var needsUpdateToCloud:Bool{get set}
    func saveToCloud()
    func deleteFromCloud()
}


protocol LocalManageable{
    var localId:UInt64?{get set}
    var needsUpdateToLocal:Bool{get set}
    func saveToLocal()
    func deleteFromLocal()
}

extension LocalManageable{
    func saveToLocal(){}
    func deleteFromLocal(){}
}

extension CloudManageable{
    func saveToCloud(){}
    func deleteFromCloud(){}
    var cloudIDStringRepresentation:String{
        return self.cloudRecord?.recordID.toString() ?? ""
    }
}

class BaseEntity: LocalManageable, CloudManageable{
    internal var localId:UInt64?
    var cloudRecord: CKRecord?
    internal let localDB:PBDBManager = PBDBManager.default
    internal let cloudDB:CKDatabase = CloudKitManager.instance.privateDB
    internal var needsUpdateToCloud: Bool
    internal var needsUpdateToLocal:Bool
    
    
    var name:String{
        didSet{
            checkNeedsUpdate(oldValue, with: name)
        }
    }
    
    internal func checkNeedsUpdate<T:Equatable>(_ oldValue:T?, with neoValue:T?){
        if(oldValue != neoValue){
            needsUpdateToLocal = true
            if(cloudRecord != nil){
                needsUpdateToCloud = true
            }
        }
    }
    
    init(name:String){
        self.needsUpdateToLocal = true
        self.needsUpdateToCloud = true
        self.name = name
    }
}







