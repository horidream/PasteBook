//
//  PBDBHandler.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/24/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//


class PBDBHandler: BaseDBHandler, FileManagerDelegate {
    
    // MARK: SINGLETON
    
    static let sharedInstance:PBDBHandler = {
        let fm = FileManager.default
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let path = NSString(string: documentsFolder).appendingPathComponent("moknow.db")
        let bundlePath = Bundle.main.path(forResource: "moknow", ofType: ".db")!
        do{
            if(!fm.fileExists(atPath: path)){
                print("copying db to folder")
                try fm.copyItem(atPath: bundlePath, toPath: path)
            }
        }catch{}
        return PBDBHandler(dbPath:path)
    }()
    // MARK: CRUD

    func addItem(_ title:String, content:String)->NSDictionary?{
        return self.queryChange("INSERT INTO items (title, content) VALUES (?, ?)", args: [title as AnyObject, content as AnyObject])
    }
    
    func createNewTag(_ name:String)->NSDictionary?{
        return self.queryChange("INSERT INTO tags (name) VALUES (?)", args: [name as AnyObject])
    }
    
    func addTag( _ tagID:Int, withItemID itemID:Int){
        let _ = self.queryChange("INSERT INTO taged_items (tag_id, item_id) VALUES (?, ?)", args: [tagID as AnyObject, itemID as AnyObject])
    }
    
    func updateItemWithId(_ id:Int, title:String, content:String){
        let _ = self.queryChange("UPDATE items SET title=?, content=? WHERE id=?", args: [title as AnyObject, content as AnyObject, id as AnyObject])
    }
    
    func removeTagWithId(_ id:Int){
        let _ = queryChange("DELETE FROM taged_items WHERE tag_id=?", args: [id as AnyObject])
        let _ = queryChange("DELETE FROM tags WHERE id=?", args: [id as AnyObject])
    }
    
    func removeItemWithId(_ id:Int){
        let _ = queryChange("DELETE FROM taged_items WHERE item_id=?", args: [id as AnyObject])
        let _ = queryChange("DELETE FROM items WHERE id=?", args: [id as AnyObject])
    }
    
    
    // MARK: find all
    
    func fetchAllTitle()->Array<(id:Int, title:String)>{
        let result = queryFetch("select id,title from items") { (rs) -> (id:Int, title:String) in
            (id:Int(rs.int(forColumn: "id")),title:rs.string(forColumn: "title"))
        }
        return result
    }
    
    func fetchAllTags()->Array<Tag>{
        let result = queryFetch("SELECT id, name from tags"){
            Tag(fetchResult: $0)
        }
        return result
    }
    
    // MARK: find likes
    func fetchTagNameLikeIDs(_ likeString:String)->Array<Int>{
        let result = queryFetch("SELECT items.id FROM items JOIN tags ON tags.display_name LIKE \"%\(likeString)%\" JOIN taged_items ON taged_items.tag_id = tags.id AND taged_items.item_id = items.id"){(rs)->Int in
            Int(rs.int(forColumn: "id"))
        }
        return result
    }
    
    func fetchContentLikeIDs(_ likeString:String)->Array<Int>{
        let result = queryFetch("select id,title,content from items where title like \"%\(likeString)%\" or content like \"%\(likeString)%\""){(rs)->Int in
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
        return queryFetch("select id,title from items where id in (\(matchIDString))"){ (rs) -> (id:Int, title:String) in
            (id:Int(rs.int(forColumn: "id")),title:rs.string(forColumn: "title"))
        }
        
        
    }
    
    // MARK: find by id
    func fetchTagsById(_ id:Int)->[Tag]{
        let result = queryFetch("SELECT id, name from tags WHERE id in (SELECT tag_id from taged_items WHERE item_id=\(id))"){ Tag(fetchResult:$0) }
        return result
    }
    
    
    func fetchDetail(_ id:Int)->(title:String, detail:String){
        
        let result = queryFetch("select title, content from items where id=\(id)") { (rs) -> (title:String, detail:String) in
            (rs.string(forColumn: "title"),rs.string(forColumn: "content"))
        }
        
        return result.first!
    }
    
    
}
