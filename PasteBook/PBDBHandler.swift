//
//  PBDBHandler.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/24/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

class PBDBHandler: DBHandler, NSFileManagerDelegate {
    
    // MARK: SINGLETON
    
    static let sharedInstance:PBDBHandler = {
        let fm = NSFileManager.defaultManager()
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
        let path = NSString(string: documentsFolder).stringByAppendingPathComponent("moknow.db")
        let bundlePath = NSBundle.mainBundle().pathForResource("moknow", ofType: ".db")!
        do{
            if(!fm.fileExistsAtPath(path)){
                try fm.copyItemAtPath(bundlePath, toPath: path)
            }
        }catch{}
        return PBDBHandler(dbPath:path)
    }()
    // MARK: CRUD

    func addItem(title:String, content:String){
        self.query("INSERT INTO items (title, content) VALUES (?, ?)", withArgs:[title, content]){[$0]}
    }
    
    func addTag( tagID:Int, withItemID itemID:Int){
        self.query("INSERT OR REPLACE INTO taged_items (tag_id, item_id) VALUES (?, ?)", withArgs: [tagID, itemID]){$0}
    }
    
    func updateItemWithId(id:Int, title:String, content:String){
        self.query("UPDATE items SET title=?, content=? WHERE id=?", withArgs:[title, content, id]){[$0]}
    }
    
    func removeItemWithId(id:Int){
        self.query("DELETE FROM items WHERE id=?", withArgs: [id]){$0}
    }
    // MARK: find all
    
    func fetchAllTitle()->Array<(id:Int, title:String)>{
        let result = query("select id,title from items") { (rs) -> (id:Int, title:String) in
            (id:Int(rs.intForColumn("id")),title:rs.stringForColumn("title"))
        }
        return result
    }
    
    func fetchAllTags()->Array<(id:Int, name:String)>{
        let result = query("SELECT id, name from tags"){
            (id:Int($0.intForColumn("id")), name:$0.stringForColumn("name")!)
        }
        return result
    }
    
    // MARK: find likes
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
        
        
    }
    
    // MARK: find by id
    func fetchTagsById(id:Int)->[Tag]{
        let result = query("SELECT id, name from tags WHERE id in (SELECT tag_id from taged_items WHERE item_id=\(id))"){
            (id: Int($0.intForColumn("id")), name:$0.stringForColumn("name")!)
        }
        return result
    }
    
    
    func fetchDetail(id:Int)->(title:String, detail:String){
        
        let result = query("select title, content from items where id=\(id)") { (rs) -> (title:String, detail:String) in
            (rs.stringForColumn("title"),rs.stringForColumn("content"))
        }
        
        return result.first!
    }
    
    
}
