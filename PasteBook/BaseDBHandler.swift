//
//  DBHandler.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/24/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation
import FMDB

class BaseDBHandler: NSObject{
    
    private var database:FMDatabase
    private var lastInsertRowId:NSNumber?
    init(dbPath:String){
        self.database = FMDatabase(path: dbPath)
        database.makeFunctionNamed("regexp", maximumArguments: 2, with: {
            context, argc, argv in
            
            
            autoreleasepool {
                let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                let con = OpaquePointer(context)
                // http://stackoverflow.com/a/26884081/1271826
                let arr = Array(UnsafeBufferPointer(start: argv, count: Int(argc)))
                let p = arr[0]
                let v = arr[1]
                if let pattern = p?.assumingMemoryBound(to: String.self), let value = v?.assumingMemoryBound(to: String.self){
                    if(Regex(pattern.pointee).test(value.pointee)){
                        sqlite3_result_text(con, (value.pointee as NSString).utf8String, -1, SQLITE_TRANSIENT)
                    }else{
                        sqlite3_result_null(con)
                    }
                } else {
                    sqlite3_result_null(con)
                }
            }
        })
    }
    
    func queryFetch<T>(_ sql:String, args:[AnyObject]? = nil, mapTo mapBlock:(FMResultSet)->T)->Array<T>{
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
    
    
    
    
    func queryChange(_ sql:String, args:[AnyObject]? = nil)->NSDictionary?{
        guard self.database.open() == true else{
            return nil
        }
        defer{
            self.database.close()
        }
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
