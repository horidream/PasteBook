//
//  KnomaModel.swift
//  Knoma
//
//  Created by Baoli Zhai on 08/03/2017.
//  Copyright © 2017 Baoli Zhai. All rights reserved.
//

import Foundation

class KnomaModel{
    private var localArticles:[Article] = []
    private var cloudArticles:[Article] = []
    private var bothSideArticles:[Article] = []
    var articles:[Article]  {
        return localArticles + cloudArticles + bothSideArticles
    }
    
    
    func addLocal(article:Article){
        if let index = cloudArticles.index(of: article){
            if(!bothSideArticles.contains(article)){
                let ca = cloudArticles[index]
                article.cloudRecord = ca.cloudRecord
                bothSideArticles.append(article)
            }
        }else{
            if(!localArticles.contains(article)){
                localArticles.append(article)
            }
        }
    }
    
    func removeLocal(article:Article){
        if let index = localArticles.index(of: article){
            localArticles.remove(at: index)
        }
        if let index = bothSideArticles.index(of: article){
            bothSideArticles.remove(at: index)
            if(!cloudArticles.contains(article)){
                cloudArticles.append(article)
            }
        }
    }
    
    func addCloud(article:Article){
        guard article.cloudRecord != nil else{
            return
        }
        if let index = localArticles.index(of: article){
            if(!bothSideArticles.contains(article)){
                let la = localArticles[index]
                article.localId = la.localId
                bothSideArticles.append(article)
            }
        }else{
            if(!cloudArticles.contains(article)){
                cloudArticles.append(article)
            }
        }
    }
    
    func removeCloud(article:Article){
        if let index = cloudArticles.index(of: article){
            cloudArticles.remove(at: index)
        }
        if let index = bothSideArticles.index(of: article){
            bothSideArticles.remove(at: index)
            if(!localArticles.contains(article)){
                localArticles.append(article)
            }
        }
    }
}
