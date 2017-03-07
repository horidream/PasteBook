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
    static var articles:[Article] = []
    var privateDB:CKDatabase
    var queue:OperationQueue
    init() {
        let container = CKContainer.default()
        privateDB = container.privateCloudDatabase
        queue = OperationQueue()
        container.accountStatus { (status:CKAccountStatus, error: Error?) in
            switch status{
            case .available:
                print(#file, #line, #function, "available", separator:">")
            case .noAccount:
                print("no account")
            default:()
            }
        }
        
    }
    
    func registerSubscription(){
        let article_subscription = CKSubscription(recordType: "article", predicate: NSPredicate(value:true), options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "Subscription notification for article"
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.shouldBadge = false
        article_subscription.notificationInfo = notificationInfo
        privateDB.fetchAllSubscriptions { (subscriptions: [CKSubscription]?, error:Error?) in
//            print("subscriptions: \(subscriptions)\n contains \(article_subscription): \(subscriptions?.contains(article_subscription))")
            self.privateDB.save(article_subscription, completionHandler: { (sub:CKSubscription?, error:Error?) in
//                print("did saved with error \(error)")
//                print("\(sub)")
            })
        }
        
    }
    

    
    func fetchAllArticles(completionHanlder:@escaping ()->Void){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "article", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        let fetchBlock:(CKRecord)->Void = {
            record in
            CloudKitManager.articles.append(Article(record))
        }

        
        func nextQueryOperation(cursor:CKQueryCursor?, error:Error?)->CKQueryOperation?
        {
            if cursor != nil && error == nil{
                let qo = CKQueryOperation(cursor: cursor!)
                qo.recordFetchedBlock = fetchBlock
                qo.queryCompletionBlock = {
                    cursor, error in
                    if let qo = nextQueryOperation(cursor: cursor, error: error){
                        self.privateDB.add(qo)
                    }else{
                        completionHanlder()
                    }
                }

                return qo
            }
            return nil
        }
        queryOperation.recordFetchedBlock = fetchBlock
        queryOperation.queryCompletionBlock = {
            cursor, error in
            if let qo = nextQueryOperation(cursor: cursor, error: error){
                self.privateDB.add(qo)
            }else{
                completionHanlder()
            }
        }
        privateDB.add(queryOperation)
        
    }
    
}
