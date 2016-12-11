//
//  PBDBManager.swift
//  PasteBook
//
//  Created by Baoli Zhai on 02/12/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import Foundation
import FMDB

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
    
    
    
    // MARK - fetch
    func fetchAllArticleTitles()->Array<(id:Int, title:String)>{
        let result = queryFetch("select article_id,article_title from article") { (rs) -> (id:Int, title:String) in
            (id:Int(rs.int(forColumn: "article_id")),title:rs.string(forColumn: "article_title")!)
        }
        return result
    }
    
    func fetchArticle(id:UInt64)->Article{
        let articles = queryFetch("select * from article where article_id=\(id)", mapTo: {(rs)->Article in
            var article =  Article(fetchResult: rs)
            article.tags = []
            return article
        })
        return articles.first!
    }
    

    func fetchArticle(categoryName name:String)->[Article]{
        let query = "select article_id as id, article_title, article_content, category.category_id, category.category_name, updated_time, created_time from article inner join category where article.category_id=category.category_id and category.category_name = \"\(name)\""
        
        let articles = queryFetch(query, mapTo: {(rs)->Article in
            var article =  Article(fetchResult: rs)
            article.tags = []
            return article
        })
        return articles
    }
    
//    func fetchTags(articleId id:UInt64)->[Tag]{
//        var tags = queryFetch("select * from tags inner join", mapTo: <#T##(FMResultSet) -> T#>)
//    }
    
    
}
