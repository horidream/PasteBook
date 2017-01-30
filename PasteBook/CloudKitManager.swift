//
//  CloudKitManager.swift
//  Knoma
//
//  Created by Baoli Zhai on 17/01/2017.
//  Copyright © 2017 Baoli Zhai. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager{
    static let instance:CloudKitManager = CloudKitManager()
    
        var privateDB:CKDatabase
    var queue:OperationQueue
    init() {
        let container = CKContainer.default()
        privateDB = container.privateCloudDatabase
        queue = OperationQueue()
        container.accountStatus { (status:CKAccountStatus, error: Error?) in
            switch status{
            case .available:
                print("available")
            case .noAccount:
                print("no account")
            default:()
            }
        }
        
    }
    
    func fetchAllArticleTitles(category:Category? = nil){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "article", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { records, error in
            print("-- new cloudkit records --  \n\(records) \n  \(error)")
        }
    }
    
}
