//
//  DBHandler.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/24/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation

class DBHandler: NSObject{
    
    var database:FMDatabase
    init(dbPath:String){
        self.database = FMDatabase(path: dbPath)
    }
    var lastInsertRowId:NSNumber?
    func queryFetch<T>(sql:String, _ args:[AnyObject]? = nil, mapTo mapBlock:(FMResultSet)->T)->Array<T>{
        var result:Array<T> = []
        guard self.database.open() == true else{
            return result
        }

        if let rs = database.executeQuery(sql, withArgumentsInArray: args) {
            while rs.next() {
                
                result.append(mapBlock(rs))
            }
            
        }
        self.database.close()
        return result
        
    }
    
    
    func queryChange(sql:String, _ args:[AnyObject]? = nil)->NSDictionary?{
        guard self.database.open() == true else{
            return nil
        }
        defer{
            self.database.close()
        }
        print("will change with query : \(sql) and args: \(args)")
        let result = database.executeQuery(sql, withArgumentsInArray: args)
        // must have
        result.next()
        let arr = sql.split("\\s+")
        if arr[0].lowercaseString != "insert"{
            return nil
        }
        lastInsertRowId = NSNumber(longLong:self.database.lastInsertRowId())
        let idx = arr.map{$0.lowercaseString}.indexOf("into")
        if let insertedId = lastInsertRowId where idx != nil{
            let tableName = arr[idx! + 1]
            print(tableName, lastInsertRowId)
            let resultSet = database.executeQuery("SELECT * FROM \(tableName) WHERE ROWID=?", withArgumentsInArray:[insertedId])
            resultSet.next()
            return resultSet.resultDictionary()
        }else{
            return nil
        }
        
    }

}
