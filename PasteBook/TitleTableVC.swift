//
//  TitleTableVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 1/5/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

class TitleTableVC: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UISplitViewControllerDelegate {
    
    var data:Array<(id:Int,title:String)> = []
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        self.tableView.dataSource = self
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.returnKeyType = .Done
        
        self.definesPresentationContext = true
//        self.navigationItem.titleView = searchController.searchBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addNewItem))
        self.navigationItem.title = "Title"
        let searchBar = searchController.searchBar
        self.tableView.tableHeaderView = searchBar
        self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchBar.frame))
        
        self.splitViewController?.preferredDisplayMode = .AllVisible
        self.splitViewController?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        data = PBDBHandler.sharedInstance.fetchAllTitle().reverse()
        self.tableView.reloadData()
    }
    
    func addNewItem(){
        self.performSegueWithIdentifier("CreateNew", sender: self)
    }
    // MARK: navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier where id == "showDetail"{
            let nv = segue.destinationViewController as! UINavigationController
            let vc = nv.viewControllers[0] as! ContentViewController
            let id = (sender?.valueForKey("id")?.integerValue)!
            let detail = PBDBHandler.sharedInstance.fetchDetail(id)
            vc.tags = PBDBHandler.sharedInstance.fetchTagsById(id)
            vc.contentTitle = detail.title
            vc.contentDetail = detail.detail
        }
    }
    
    // MARK: table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell")!
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
    
    // MARK: table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetail", sender: ["id":data[indexPath.row].id])
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: search result
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.data = PBDBHandler.sharedInstance.fetchTitlesLike(searchController.searchBar.text!)
        self.tableView.reloadData()
    }
 
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
}
