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
        let fn = "moknow.db"
        let path = NSString(string: documentsFolder).appendingPathComponent(fn)
        let bundlePath = Bundle.main.path(forResource: "moknow", ofType: ".db")!
        do{
            if(fm.fileExists(atPath: path)){
                try fm.removeItem(atPath: path)
                try fm.copyItem(atPath: bundlePath, toPath: path)
            }
        }catch let error{print(error)}
        return PBDBManager(dbPath:fn)
    }()
    
    // MARK: -
    
    func fetchAllCategories()->Array<Category>{
        let query = "select category_id, category_name, category_color, (select count(article.category_id) from article where category.category_id == article.category_id) as category_count from category"
        let result = queryFetch(query, mapTo: { Category($0)})
        return result
    }
    
    
    func fetchAllArticles(category:Category? = nil)->Array<Article>{
        var categoryCondition = ""
        if let category = category{
            categoryCondition = "and article.category_id=\(category.localId)"
        }
        let result = queryFetch("select article_id,article_title, article_content, created_time, updated_time, favorite, article.cloud_record_id, article.category_id, category_color from article inner join category where article.category_id=category.category_id \(categoryCondition)") { rs in
            return Article(rs)
        }
        return result
    }
    
    func fetchArticles(withKeywords keywords:String, category:Category? = nil)->Array<Article>{
        
        let matches = keywords.split("[,，。；;]")
        let condition = matches.map{"whole_content like \"%\($0.trimmed())%\""}.joined(separator: " and ")
        var categoryCondition = ""
        var wholeContentColumn = "article_title || \"\n\" || article_content"
        if let category = category{
            if let category_id = category.localId{
                categoryCondition = "and article.category_id=\(category_id)"
                wholeContentColumn += " || \"\n\" ||  category_name"
            }
        }
        let query = "select article_id,article_title, article_content, created_time, updated_time, favorite, article.cloud_record_id, article.category_id, category_color, \(wholeContentColumn) as whole_content from article inner join category where \(condition)  and category.category_id=article.category_id \(categoryCondition) group by article.article_id"

        let result = queryFetch(query) { rs in
            return Article(rs)
        }
        return result
    }

    
//    func fetchArticle(id:UInt64)->Article{
//        var query = "select article.article_id, article_title, article_content, category_name, article.category_id, created_time, updated_time, favorite, group_concat(tag.tag_name) as tag_names, group_concat(tag.tag_id) as tag_ids ,group_concat(tag.tag_color) as tag_colors from article  inner join tagged_article, tag, category where article.article_id = \(id) and article.category_id = category.category_id and tagged_article.article_id = article.article_id and tagged_article.tag_id = tag.tag_id group by article.article_id"
//        
//        let hasTag = queryFetch("SELECT article_id from tagged_article where article_id=?", args:[id], mapTo: {$0}).count >  0
//        if !hasTag{
//            query = "select article.article_id, article_title, article_content, category.category_name, article.category_id, created_time, updated_time, favorite from article inner join category where article.article_id = \(id) and article.category_id = category.category_id"
//        }
//        
//        
//        let articles = queryFetch(query, mapTo: {(rs)->Article in
//            let article =  Article(rs)
//            if hasTag{
//                let tag_ids = rs.string(forColumn: "tag_ids").split(",").map({UInt64($0)}) as! [UInt64]
//                let tag_names = rs.string(forColumn: "tag_names").split(",")
//                let tag_colors = rs.string(forColumn: "tag_colors").split(",").map({UInt64($0)}) as! [UInt64]
//                article.tags = Tag.createTags(ids: tag_ids, names: tag_names, colors: tag_colors)
//            }
//            return article
//        })
//        return articles.first!
//    }
    

    func fetchArticles(categoryName name:String)->[Article]{
        let query = "select article_id as id, article_title, article_content, category.category_id, category.category_name, updated_time, created_time from article inner join category where article.category_id=category.category_id and category.category_name = \"\(name)\""
        
        let articles = queryFetch(query, mapTo: {(rs)->Article in
            let article =  Article(rs)
            return article
        })
        return articles
    }
    
    
    // MARK: - 
    func addArticle(_ article:Article, to category:Category)->Article{
        
        let _article = article
        let _category = addCategory(category)
        if let category_id = _category.localId{
            let query = "INSERT INTO article (article_title, article_content, category_id) VALUES (?, ?, ?)"
            _ = queryChange(query, args:[_article.title, _article.content, category_id])
            let articleId = queryFetch("SELECT article_id from article where article_title=? and article_content=?", args:[_article.title, article.content], mapTo: {
                $0.unsignedLongLongInt(forColumn: "article_id")
            }).first!
            _article.localId = articleId
        }
        return _article
    }
//
    func addCategory(_ category:Category) -> Category{
        let _category = category
        if category.localId == nil {
            _ = queryChange("INSERT OR IGNORE INTO category (category_name) VALUES (?)", args:[_category.name])
            let categoryId = queryFetch("SELECT category_id from category where category_name=?", args:[_category.name], mapTo: {
                $0.unsignedLongLongInt(forColumn: "category_id")
            }).first!
            _category.localId = categoryId

        }
        return _category
    }
//
//    func addTag(_ tag:Tag) -> Tag{
//        let _tag = tag
//        if tag.localId == nil {
//            _ = queryChange("INSERT OR IGNORE INTO category (tag_name) VALUES (\(tag.name))")
//            let tagId = queryFetch("SELECT tag_id from category where tag_name = \(tag.name)", mapTo: {
//                $0.unsignedLongLongInt(forColumn: "tag_id")
//            }).first!
//            
//            _tag.localId = tagId
//        }
//        return _tag
//    }
//    
//    
//    // MARK: - DELETE
//    
    func deleteArticleById(id:UInt64){
        _ = queryChange("DELETE FROM tagged_article where article_id=?", args: [id])
        _ = queryChange("DELETE FROM article where article_id=?", args: [id])
    }
//    
//    
//    // MARK: - UPDATE
    func updateArticle(_ article:Article, with category:Category)->Article{
        let _article = article
        let _category = addCategory(category)
        
        
        if let category_id = _category.localId, let article_id = _article.localId{
            let query = "UPDATE article set article_title=?, article_content=?, category_id=? WHERE article_id=?"
            _ = queryChange(query, args:[_article.title, _article.content, category_id, article_id])
        }
        return _article
    }
    
    
}
