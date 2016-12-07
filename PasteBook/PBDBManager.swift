//
//  PBDBManager.swift
//  PasteBook
//
//  Created by Baoli Zhai on 02/12/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation
import FMDB

class PBDBManager{
    
    static let `default`:PBDBManager = {
        let fm = FileManager.default
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let path = NSString(string: documentsFolder).appendingPathComponent("moknow.db")
        let bundlePath = Bundle.main.path(forResource: "moknow", ofType: ".db")!
        do{
            if(!fm.fileExists(atPath: path)){
                try fm.copyItem(atPath: bundlePath, toPath: path)
            }
        }catch{}
        return PBDBManager(dbPath:path)
    }()
    
    private var database:FMDatabase
    private var lastInsertRowId:NSNumber?
    init(dbPath:String){
        self.database = FMDatabase(path: dbPath)
    }
    
    
    // MARK -
    
    private func lastRowOf(table:String)->FMResultSet{
        let lastRowId = self.database.lastInsertRowId()
        return database.executeQuery("SELECT * FROM \(table) WHERE ROWID=?", withArgumentsIn:[lastRowId])
    }
    
    func addArticle( _ article: Article)->FMResultSet?{
        guard self.database.open() == true else{
            return nil
        }
        defer{
            self.database.close()
        }
        
        do{
            try database.executeQuery("INSERT INTO items (title, content) VALUES (?, ?)", values: [article.title, article.content])
        }catch{
            return nil
        }
        return lastRowOf(table: "items")
    }
    
}
