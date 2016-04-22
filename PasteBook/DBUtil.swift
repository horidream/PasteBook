//
//  DBUtil.swift
//  PasteBook
//
//  Created by Baoli Zhai on 8/31/15.
//  Copyright © 2015 Baoli Zhai. All rights reserved.
//

import UIKit

extension String {
    
    // java, javascript, PHP use 'split' name, why not in Swift? :)
    func split(regex: String) -> Array<String> {
        do{
            let regEx = try NSRegularExpression(pattern: regex, options: NSRegularExpressionOptions())
            let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
            let modifiedString = regEx.stringByReplacingMatchesInString (self, options: NSMatchingOptions(), range: NSMakeRange(0, characters.count), withTemplate:stop)
            return modifiedString.componentsSeparatedByString(stop)
        } catch {
            return []
        }
    }
}

class DBUtil:NSObject,NSFileManagerDelegate{
    static let sharedInstance:DBUtil = DBUtil()
    let databasePath:String = {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = NSString(string: documentsFolder).stringByAppendingPathComponent("moknow.db")
        return path
    }()
    
    let fm = NSFileManager.defaultManager()
    var database:FMDatabase!
    override init() {
        super.init()
        if let path = NSBundle.mainBundle().pathForResource("moknow", ofType: "db") {
            do{
                fm.delegate = self
                if(fm.fileExistsAtPath(path) && !fm.fileExistsAtPath(self.databasePath)){
                    print("copy database")
                    try fm.copyItemAtPath(path, toPath: self.databasePath)
                }
            }catch let e as NSError {
                
                print("catching error : \(e)")
            }
        }
        self.database = FMDatabase(path: self.databasePath)
    }
    
    func fileManager(fileManager: NSFileManager, shouldProceedAfterError error: NSError, copyingItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        print("Error, code is \(error.code)")
        return (error.code == 17)
        
    }
    
    func fetchAllTitle()->Array<(id:Int, title:String)>{
        let result = query("select id,title from items") { (rs) -> (id:Int, title:String) in
            (id:Int(rs.intForColumn("id")),title:rs.stringForColumn("title"))
        }
        return result
    }
    
    func fetchTagNameLikeIDs(likeString:String)->Array<Int>{
        let result = query("SELECT items.id FROM items JOIN tags ON tags.display_name LIKE \"%\(likeString)%\" JOIN taged_items ON taged_items.tag_id = tags.id AND taged_items.item_id = items.id"){(rs)->Int in
            Int(rs.intForColumn("id"))
        }
        return result
    }
    
    func fetchContentLikeIDs(likeString:String)->Array<Int>{
        let result = query("select id,title,content from items where title like \"%\(likeString)%\" or content like \"%\(likeString)%\""){(rs)->Int in
            Int(rs.intForColumn("id"))
        }
        return result
    }
    
    func fetchTitlesLike(likeStrings:String)->Array<(id:Int, title:String)>{
        var matchIds:Set<Int> = Set()
        let arr = likeStrings.split("\\s+")
        for (idx,likeString) in arr.enumerate(){
            let anyMatches = Set(fetchTagNameLikeIDs(likeString)).union(Set(fetchContentLikeIDs(likeString)))
            if(idx == 0){
                matchIds = anyMatches
            }else{
                matchIds.intersectInPlace(anyMatches)
            }
        }
        
        let matchIDString = matchIds.map { String($0) }.joinWithSeparator(",")
        return query("select id,title from items where id in (\(matchIDString))"){ (rs) -> (id:Int, title:String) in
            (id:Int(rs.intForColumn("id")),title:rs.stringForColumn("title"))
        }

//        let matchIds = likeString.characters.count>0 ? query("SELECT items.id FROM items JOIN tags ON tags.display_name LIKE \"%\(likeString)%\" JOIN taged_items ON taged_items.tag_id = tags.id AND taged_items.item_id = items.id"){(rs) -> String in
//            rs.stringForColumn("id")
//        }.joinWithSeparator(",") : ""
//        
//        let sql = "select id,title,content from items where title like \"%\(likeString)%\" or content like \"%\(likeString)%\""+((matchIds == "") ? ("") : (" or id in (\(matchIds))"))
//        
//        
//        let result = query(sql) { (rs) -> (id:Int, title:String) in
//            (id:Int(rs.intForColumn("id")),title:rs.stringForColumn("title"))
//        }
//        return result
    }
    
    func fetchTagsById(id:Int)->[String]{
        let result = query("SELECT name from tags WHERE id in (SELECT tag_id from taged_items WHERE item_id=\(id))"){
            $0.stringForColumn("name")!
        }
        return result
    }
    
    
    func fetchDetail(id:Int)->(title:String, detail:String){

        let result = query("select title, content from items where id=\(id)") { (rs) -> (title:String, detail:String) in
            (rs.stringForColumn("title"),rs.stringForColumn("content"))
        }

        return result.first!
    }
    
    
    
    func query<T>(sql:String, args:[AnyObject]? = nil, mapBlock:(FMResultSet)->T)->Array<T>{
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