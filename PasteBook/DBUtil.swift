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
    func split(_ regex: String) -> Array<String> {
        do{
            let regEx = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options())
            let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
            let modifiedString = regEx.stringByReplacingMatches (in: self, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, characters.count), withTemplate:stop)
            return modifiedString.components(separatedBy: stop)
        } catch {
            return []
        }
    }
}

class DBUtil:NSObject,FileManagerDelegate{
    static let sharedInstance:DBUtil = DBUtil()
    let databasePath:String = {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let path = NSString(string: documentsFolder).appendingPathComponent("moknow.db")
        return path
    }()
    
    let fm = FileManager.default
    var database:FMDatabase!
    override init() {
        super.init()
        if let path = Bundle.main.path(forResource: "moknow", ofType: "db") {
            do{
                fm.delegate = self
                if(fm.fileExists(atPath: path) && !fm.fileExists(atPath: self.databasePath)){
                    print("copy database")
                    try fm.copyItem(atPath: path, toPath: self.databasePath)
                }
            }catch let e as NSError {
                
                print("catching error : \(e)")
            }
        }
        self.database = FMDatabase(path: self.databasePath)
    }
    
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, copyingItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        print("Error, code is \(error._code)")
        return (error._code == 17)
        
    }
    
    func fetchAllTitle()->Array<(id:Int, title:String)>{
        let result = query("select id,title from items") { (rs) -> (id:Int, title:String) in
            (id:Int(rs.int(forColumn: "id")),title:rs.string(forColumn: "title"))
        }
        return result
    }
    
    func fetchTagNameLikeIDs(_ likeString:String)->Array<Int>{
        let result = query("SELECT items.id FROM items JOIN tags ON tags.display_name LIKE \"%\(likeString)%\" JOIN taged_items ON taged_items.tag_id = tags.id AND taged_items.item_id = items.id"){(rs)->Int in
            Int(rs.int(forColumn: "id"))
        }
        return result
    }
    
    func fetchContentLikeIDs(_ likeString:String)->Array<Int>{
        let result = query("select id,title,content from items where title like \"%\(likeString)%\" or content like \"%\(likeString)%\""){(rs)->Int in
            Int(rs.int(forColumn: "id"))
        }
        return result
    }
    
    func fetchTitlesLike(_ likeStrings:String)->Array<(id:Int, title:String)>{
        var matchIds:Set<Int> = Set()
        let arr = likeStrings.split("\\s+")
        for (idx,likeString) in arr.enumerated(){
            let anyMatches = Set(fetchTagNameLikeIDs(likeString)).union(Set(fetchContentLikeIDs(likeString)))
            if(idx == 0){
                matchIds = anyMatches
            }else{
                matchIds.formIntersection(anyMatches)
            }
        }
        
        let matchIDString = matchIds.map { String($0) }.joined(separator: ",")
        return query("select id,title from items where id in (\(matchIDString))"){ (rs) -> (id:Int, title:String) in
            (id:Int(rs.int(forColumn: "id")),title:rs.string(forColumn: "title"))
        }


    }
    
    func fetchAllTags()->Array<(id:Int, name:String)>{
        let result = query("SELECT id, name from tags"){
            (id:Int($0.int(forColumn: "id")), name:$0.string(forColumn: "name")!)
        }
        return result
    }
    
    func fetchTagsById(_ id:Int)->[String]{
        let result = query("SELECT name from tags WHERE id in (SELECT tag_id from taged_items WHERE item_id=\(id))"){
            $0.string(forColumn: "name")!
        }
        return result
    }
    
    
    func fetchDetail(_ id:Int)->(title:String, detail:String){

        let result = query("select title, content from items where id=\(id)") { (rs) -> (title:String, detail:String) in
            (rs.string(forColumn: "title"),rs.string(forColumn: "content"))
        }

        return result.first!
    }
    
    
    
    func query<T>(_ sql:String, args:[AnyObject]? = nil, mapBlock:(FMResultSet)->T)->Array<T>{
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
}
