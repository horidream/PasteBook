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
    
    func query<T>(sql:String, withArgs args:[AnyObject]? = nil, mapTo mapBlock:(FMResultSet)->T)->Array<T>{
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

}
