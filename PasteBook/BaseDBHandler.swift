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
        let fm = FileManager.default
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let path = NSString(string: documentsFolder).appendingPathComponent("moknow.db")
        let bundlePath = Bundle.main.path(forResource: "moknow", ofType: ".db")!
        do{
            if(!fm.fileExists(atPath: path)){
                try fm.copyItem(atPath: bundlePath, toPath: path)
            }
        }catch{}

        self.database = FMDatabase(path: path)

    }
    
    func defineRegexp(){
        self.database.makeFunctionNamed("REGEXP", maximumArguments: 2, with: {
            context, argc, argv in
            autoreleasepool {
                let con = OpaquePointer(context)
                let p = sqlite3_value_text(OpaquePointer(argv?[0]))
                let v = sqlite3_value_text(OpaquePointer(argv?[1]))
                if let pattern = p, let value = v{
                    if(Regex(String(cString: pattern)).test(String(cString: value))){
                        sqlite3_result_int(con, 1)
                    }else{
                        sqlite3_result_null(con)
                    }
                } else {
                    sqlite3_result_null(con)
                }
            }
        })
        
    }
    
    func execute(_ sql:String, args:[Any]! = nil)->FMResultSet?{
        guard self.database.open() == true else{
            return nil
        }
        if let result = database.executeQuery(sql, withArgumentsIn: args){
            if result.next(){
                return result
            }
        }
        return nil
    }
    
    func queryFetch<T>(_ sql:String, args:[Any]! = nil, mapTo mapBlock:(FMResultSet)->T)->Array<T>{
        var result:Array<T> = []
        guard self.database.open() == true else{
            return result
        }
//        defineRegexp()
        if let rs = database.executeQuery(sql, withArgumentsIn: args) {
            while rs.next() {
                
                result.append(mapBlock(rs))
            }
            
        }
        return result
        
    }
    
    
    
    func queryChange(_ sql:String, args:[Any]! = nil)->Bool{
        guard self.database.open() == true else{
            return false
        }
        if let result = database.executeQuery(sql, withArgumentsIn: args)
        {
            return result.next()
        }
        return false
    }
}
