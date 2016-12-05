//
//  PBDBManager.swift
//  PasteBook
//
//  Created by Baoli Zhai on 02/12/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation


class PBDBManager:BaseDBHandler{
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
    
    
    // MARK -
    
//    func insertArticle(_ article:Article){
//        return queryChange("INSERT INTO items (title, content) VALUES (?, ?)", args:[article.title, article.content])
//    }
}
