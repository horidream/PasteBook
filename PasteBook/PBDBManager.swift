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
    
    
    
    // MARK: -
    
    func fetchAllCategories()->Array<(name:String, color:UInt64, count:UInt64)>{
        let query = "select category_name, category_color, (select count(article.category_id) from article where category.category_id == article.category_id) as category_count from category"
        let result = queryFetch(query) { rs in
            (name:rs.string(forColumn: "category_name")!, color: rs.unsignedLongLongInt(forColumn: "category_color") , count: rs.unsignedLongLongInt(forColumn: "category_count") )
        }
        return result
    }
    
    
    func fetchAllArticleTitles()->Array<(id:UInt64, title:String, color:UInt64)>{
        let result = queryFetch("select article_id, article_title, category_color from article inner join category where article.category_id=category.category_id") { rs in
            (id:rs.unsignedLongLongInt(forColumn: "article_id"),title:rs.string(forColumn: "article_title")!, color: rs.unsignedLongLongInt(forColumn: "category_color"))
        }
        return result
    }
    
    func fetchArticleTitles(withKeywords keywords:String)->Array<(id:UInt64, title:String, color:UInt64)>{
        
        let matches = keywords.split("  ")
        let condition = matches.map{"whole_content like \"%\($0.trimmed())%\""}.joined(separator: " and ")
        let query = "select article_id,article_title, article_title || \"\n\" || article_content || \"\n\" ||  category_name as whole_content, category_color from article inner join category where \(condition)  and category.category_id=article.category_id group by article.article_id"

        let result = queryFetch(query) { (rs) -> (id:UInt64, title:String, color:UInt64) in
            (id:rs.unsignedLongLongInt(forColumn: "article_id"),title:rs.string(forColumn: "article_title")!,color: rs.unsignedLongLongInt(forColumn: "category_color"))
        }
        print("find \(result.count) results")
        return result
    }

    
    func fetchArticle(id:UInt64)->Article{
        let query = "select article.article_id, article_title, article_content, category_name, article.category_id, created_time, updated_time, favorite, group_concat(tag.tag_name) as tag_names, group_concat(tag.tag_id) as tag_ids ,group_concat(tag.tag_color) as tag_colors from article  inner join tagged_article, tag, category where article.article_id = \(id) and article.category_id = category.category_id and tagged_article.article_id = article.article_id and tagged_article.tag_id = tag.tag_id group by article.article_id"
        let articles = queryFetch(query, mapTo: {(rs)->Article in
            var article =  Article(fetchResult: rs)
            let tag_ids = rs.string(forColumn: "tag_ids").split(",").map({UInt64($0)}) as! [UInt64]
            let tag_names = rs.string(forColumn: "tag_names").split(",")
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
    
    
    // MARK: - 
    func addArticle(_ article:Article, to category:Category)->Article{
        
        var _article = article
        let _category = addCategory(category)
        if case let Saved.local(id: category_id) = _category.isSaved{
            _ = queryChange("INSERT INTO article (article_title, article_content, category_id) VALUES (\(article.title), \(article.content), \(category_id))")
            let articleId = queryFetch("SELECT article_id from article where article_title = \(article.title) and article_content = \(article.content)", mapTo: {
                $0.unsignedLongLongInt(forColumn: "article_id")
            }).first!
            _article.isSaved = .local(id: articleId)
        }
        return _article
    }
    
    func addCategory(_ category:Category) -> Category{
        var _category = category
        switch category.isSaved {
        case .notYet:
            _ = queryChange("INSERT OR IGNORE INTO category (category_name) VALUES (\(category.name))")
            let categoryId = queryFetch("SELECT category_id from category where category_name = \(category.name)", mapTo: {
                $0.unsignedLongLongInt(forColumn: "category_id")
            }).first!
            _category.isSaved = .local(id: categoryId)

        default:
            break
        }
        return _category
    }
    
    func addTag(_ tag:Tag) -> Tag{
        var _tag = tag
        switch tag.isSaved {
        case .notYet:
            _ = queryChange("INSERT OR IGNORE INTO category (tag_name) VALUES (\(tag.name))")
            let tagId = queryFetch("SELECT tag_id from category where tag_name = \(tag.name)", mapTo: {
                $0.unsignedLongLongInt(forColumn: "tag_id")
            }).first!
            _tag.isSaved = .local(id: tagId)
            
        default:
            break
        }
        return _tag
    }
    
}
