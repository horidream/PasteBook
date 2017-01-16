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
    
    let pubDB = CKContainer.default().publicCloudDatabase
    let priDB = CKContainer.default().privateCloudDatabase
    
    init() {
        let article = Article(title: "hello", content: "Baoli")
        priDB.save(article.record) { (record, error) in
            print(record, error)
        }
    }
    
}
