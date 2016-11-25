//
//  DBHandler.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/24/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation
import FMDB

class DBHandler: NSObject{
    
    var database:FMDatabase
    init(dbPath:String){
        self.database = FMDatabase(path: dbPath)
    }
    var lastInsertRowId:NSNumber?
    func queryFetch<T>(_ sql:String, _ args:[AnyObject]? = nil, mapTo mapBlock:(FMResultSet)->T)->Array<T>{
        var result:Array<T> = []
        guard self.database.open() == true else{
            return result
        }

        if let rs = database.executeQuery(sql, withArgumentsIn: args) {
            while rs.next() {
                
                result.append(mapBlock(rs))
            }
            
        }
        self.database.close()
        return result
        
    }
    
    
    func queryChange(_ sql:String, _ args:[AnyObject]? = nil)->NSDictionary?{
        guard self.database.open() == true else{
            return nil
        }
        defer{
            self.database.close()
        }
        print("will change with query : \(sql) and args: \(args)")
        let result = database.executeQuery(sql, withArgumentsIn: args)
        // must have
        result?.next()
        let arr = sql.split("\\s+")
        if arr[0].lowercased() != "insert"{
            return nil
        }
        lastInsertRowId = NSNumber(value: self.database.lastInsertRowId() as Int64)
        let idx = arr.map{$0.lowercased()}.index(of: "into")
        if let insertedId = lastInsertRowId , idx != nil{
            let tableName = arr[idx! + 1]
            let resultSet = database.executeQuery("SELECT * FROM \(tableName) WHERE ROWID=?", withArgumentsIn:[insertedId])
            resultSet?.next()
            return resultSet?.resultDictionary() as NSDictionary?
        }else{
            return nil
        }
        
    }

}
