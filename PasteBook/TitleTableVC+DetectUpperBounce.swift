//
//  TitleTableVC+DetectUpperBounce.swift
//  Knoma
//
//  Created by Baoli.Zhai on 21/06/2017.
//  Copyright © 2017 Baoli Zhai. All rights reserved.
//

import Foundation

extension TitleTableVC{
    
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(self.tableView.contentOffset.y )
        if(self.tableView.contentOffset.y <= -64 && !self.searchController.searchBar.isFirstResponder){
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
}
