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
    
    let publicDB = CKContainer.default().publicCloudDatabase
    let privateDB = CKContainer.default().privateCloudDatabase
    
    init() {
        
    }
    
    func fetchAllArticleTitles(category:Category? = nil){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "article", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { records, error in
            print("-- new cloudkit records --  \n\(records) \n  \(error)")
        }
    }
    
}
