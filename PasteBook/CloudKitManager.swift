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
        let article = Article(title: "hello", content: "Baoli")
        privateDB.save(article.record) { (record, error) in
        }
    }
    
    
}
