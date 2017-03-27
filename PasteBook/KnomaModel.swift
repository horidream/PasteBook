//
//  KnomaModel.swift
//  Knoma
//
//  Created by Baoli Zhai on 08/03/2017.
//  Copyright © 2017 Baoli Zhai. All rights reserved.
//

import Foundation
import EZSwiftExtensions

let namespace:String = "com.horidream.app.knoma"

protocol KnomaModelProtocal {
    var articles:[Article]{get}
    func articles(inCategory:Category)->[Article]
    func articles(withKeyword:String, inCategory:Category?)->[Article]
}

class LocalModel:KnomaModelProtocal{
    lazy var articles:[Article] = {
       return PBDBManager.default.fetchAllArticles()
    }()
    
    func articles(inCategory category:Category)->[Article]{
        if let lc = category as? LocalCategory{
            return PBDBManager.default.fetchAllArticles(category: lc)
        }
        return []
    }
    
    func articles(withKeyword keyword:String, inCategory category:Category? = nil)->[Article]{
        if let lc = category as? LocalCategory{
            return PBDBManager.default.fetchArticles(withKeywords: keyword, category: lc)
        }else{
            return PBDBManager.default.fetchArticles(withKeywords: keyword)
        }
    }
}


// TODO: not implemented
class CloudModel:KnomaModelProtocal{
    lazy var articles:[Article] = {
        return []
    }()
    
    func articles(inCategory category:Category)->[Article]{
        return []
    }
    
    func articles(withKeyword keyword:String, inCategory category:Category? = nil)->[Article]{
        return []
    }
}

class KnomaModel:KnomaModelProtocal{
    private var localArticles:[LocalArticle] = []
    private var cloudArticles:[CloudArticle] = []
    var articles:[ArticleSet] {
        return self.localArticles.map({ (article) -> ArticleSet in
            if let index = (self.cloudArticles as [Article]).index(of: article){
                return ArticleSet(local: article, cloud: self.cloudArticles[index])
            }else{
                return ArticleSet(local: article, cloud: nil)
            }
        }) + ((self.cloudArticles as [Article]).difference(self.localArticles as [Article]).map{
            article in
            return ArticleSet(local: nil, cloud: (article as! CloudArticle))
        })
    }
    
    var categories:[CategorySet] = []
    init () {
        let q = DispatchQueue(label:namespace)
        q.async {
            self.localArticles = PBDBManager.default.fetchAllArticles()
            CloudKitManager.instance.fetchAllArticles {
                self.cloudArticles = $0
            }
            self.broadcast()
        }
        
        
    }
    
    
    func broadcast(){
        NotificationCenter.default.post(name: .KNOMA_UPDATE, object: self)
        
    }
}


extension Notification.Name{
    public static  let KNOMA_UPDATE = Notification.Name(rawValue: "com.horidream.app.knoma.udpate")
}


extension UIViewController{
    var knoma:KnomaModel{
        return (UIApplication.shared.delegate as! AppDelegate).knomaModel
    }
    
    func onKnomaUpdate(){
        print("model updated: \(knoma.articles.count) items")
    }
    
    func observeKnoma(){
        NotificationCenter.default.addObserver(self, selector: #selector(onKnomaUpdate), name: .KNOMA_UPDATE, object: nil)
    }
    
    
}
