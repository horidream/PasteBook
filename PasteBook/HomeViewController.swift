//
//  HomeViewController.swift
//  PasteBook
//
//  Created by Baoli.Zhai on 5/20/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    var data:[Tag] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        searchBar.delegate = self
        self.view.addGestureRecognizer(tap)
    }

    func dismissKeyboard(){
        self.searchBar.resignFirstResponder()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}

extension HomeViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("search button clicked")
        guard let _ = self.searchBar.text else {
            return
        };
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            self.dismissViewControllerAnimated(true, completion: {})
            
        })
    }
}

