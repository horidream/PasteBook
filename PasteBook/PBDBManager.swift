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
        return PBDBManager(dbPath:bundlePath)
    }()
    
    
    
    // MARK - fetch
    func fetchAllArticleTitles()->Array<(id:UInt64, title:String)>{
        let result = queryFetch("select article_id,article_title from article") { (rs) -> (id:UInt64, title:String) in
            (id:rs.unsignedLongLongInt(forColumn: "article_id"),title:rs.string(forColumn: "article_title")!)
        }
        return result
    }
    
    func fetchArticleTitles(withKeywords keywords:String)->Array<(id:UInt64, title:String)>{
        
        let matches = keywords.split(",")
        let condition = matches.map{"whole_content like \"%\($0)%\""}.joined(separator: " and ")
        let query = "select article_id,article_title, article_title || \"\n\" || article_content || \"\n\" ||  category_name as whole_content from article inner join category where \(condition) group by article.article_id"

        let result = queryFetch(query) { (rs) -> (id:UInt64, title:String) in
            (id:rs.unsignedLongLongInt(forColumn: "article_id"),title:rs.string(forColumn: "article_title")!)
        }
        return result
    }

    
    func fetchArticle(id:UInt64)->Article{
        let query = "select article.article_id, article_title, article_content, category_name, article.category_id, created_time, updated_time, favorite, group_concat(tag.tag_name) as tag_names, group_concat(tag.tag_id) as tag_ids from article  inner join tagged_article, tag, category where article.article_id = \(id) and article.category_id = category.category_id and tagged_article.article_id = article.article_id and tagged_article.tag_id = tag.tag_id group by article.article_id"
        let articles = queryFetch(query, mapTo: {(rs)->Article in
            var article =  Article(fetchResult: rs)
            let tag_ids = rs.string(forColumn: "tag_ids").split(",").map({UInt64($0)}) as! [UInt64]
            let tag_names = rs.string(forColumn: "tag_ids").split(",")
            let tag_colors = rs.string(forColumn: "tag_colors").split(",").map({UInt64($0)}) as! [UInt64]
            article.tags = Tag.createTags(ids: tag_ids, names: tag_names, colors: tag_colors)
            return article
        })
        return articles.first!
    }
    

    func fetchArticle(categoryName name:String)->[Article]{
        let query = "select article_id as id, article_title, article_content, category.category_id, category.category_name, updated_time, created_time from article inner join category where article.category_id=category.category_id and category.category_name = \"\(name)\""
        
        let articles = queryFetch(query, mapTo: {(rs)->Article in
            var article =  Article(fetchResult: rs)
            let tag_ids = rs.string(forColumn: "tag_ids").split(",").map({UInt64($0)}) as! [UInt64]
            let tag_names = rs.string(forColumn: "tag_ids").split(",") 
            let tag_colors = rs.string(forColumn: "tag_colors").split(",").map({UInt64($0)}) as! [UInt64]
            article.tags = Tag.createTags(ids: tag_ids, names: tag_names, colors: tag_colors)
            return article
        })
        return articles
    }
    

    
}
