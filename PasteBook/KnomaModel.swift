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
}
