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

// TODO: not implemented
class KnomaModel:KnomaModelProtocal{
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
