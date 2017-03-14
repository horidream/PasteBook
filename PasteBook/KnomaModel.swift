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

class KnomaModel{
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
    
    func addLocal(article:Article){
        if(!localArticles.contains(article)){
            article.saveToLocal()
            localArticles.append(article)
            broadcast()
        }
    }
    
    func removeLocal(article:Article){
        if let index = localArticles.index(of: article){
            localArticles.remove(at: index).deleteFromLocal()
            broadcast()
        }
    }
    
    func addCloud(article:Article){
        guard article.cloudRecord != nil else{
            return
        }

        if(!cloudArticles.contains(article)){
            article.saveToCloud()
            cloudArticles.append(article)
            broadcast()
        }
    }
    
    func removeCloud(article:Article){
        if let index = cloudArticles.index(of: article){
            cloudArticles.remove(at: index).deleteFromCloud()
            broadcast()
        }
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
