//
//  TitleTableVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 1/5/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

// define Item type
typealias Tag = (id:Int, name:String)
typealias Item = (id:Int, title:String, content:String, tags:[Tag])

func == <T:Equatable> (tuple1:(T,T,T,T),tuple2:(T,T,T,T)) -> Bool
{
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1) && (tuple1.2 == tuple2.2) && (tuple1.3 == tuple2.3)
}

func != <T:Equatable> (tuple1:(T,T,T,T),tuple2:(T,T,T,T)) -> Bool
{
    return !(tuple1==tuple2)
}

class TitleTableVC: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UISplitViewControllerDelegate {
    
    var data:Array<(id:Int,title:String)> = []
    let searchController = UISearchController(searchResultsController: nil)
    var tvControl:SensibleTableViewControl?
    var firstLaunch:Bool = true
    var lastShowingIndex:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        tvControl = SensibleTableViewControl(self.tableView, self.inputAccessoryView)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshData), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        self.tableView.dataSource = self
        data = PBDBHandler.sharedInstance.fetchAllTitle().reverse()
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.returnKeyType = .Done
        
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addNewItem))
        self.navigationItem.title = "Manage Your Knowledge"
        let searchBar = searchController.searchBar
        self.tableView.tableHeaderView = searchBar
        self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchBar.frame))
        
        self.splitViewController?.preferredDisplayMode = .AllVisible
        self.splitViewController?.delegate = self
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // stop refresh when done
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstLaunch{
            self.splitViewController?.performSegueWithIdentifier("HomeView", sender: self)
            firstLaunch = false
        }
        
    }
    
    func refreshData(){
        self.refreshControl?.beginRefreshing()
        data = PBDBHandler.sharedInstance.fetchAllTitle().reverse()
        self.refreshControl!.endRefreshing()
        self.tableView.reloadSections(NSIndexSet(index:0), withRowAnimation: .Bottom)
    }
    
    func addNewItem(){
        self.performSegueWithIdentifier("CreateNew", sender: self)
    }
    // MARK: navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier{
            switch id {
            case "showDetail":
                let nv = segue.destinationViewController as! UINavigationController
                let vc = nv.viewControllers[0] as! ContentDetailVC
                let id = (sender?.valueForKey("id")?.integerValue)!
                let detail = PBDBHandler.sharedInstance.fetchDetail(id)
                vc.tags = PBDBHandler.sharedInstance.fetchTagsById(id)
                vc.contentTitle = detail.title
                vc.contentDetail = detail.detail
                vc.itemID = id
            case "CreateNew":
                let cnvc = segue.destinationViewController as! CreateNewItemVC
                cnvc.isNewItem = true
            default:()
            }
        }
        
        
    }
    
    // MARK: table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell")!
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.lineBreakMode = .ByWordWrapping;
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
    
    // MARK: table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetail", sender: ["id":data[indexPath.row].id])
        searchController.searchBar.resignFirstResponder()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete){
            PBDBHandler.sharedInstance.removeItemWithId(self.data[indexPath.row].id)
            self.data.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let currentShowingIndex = indexPath.row
        
        cell.alpha = 0
        var trans = CATransform3DTranslate(CATransform3DIdentity, 0, lastShowingIndex > currentShowingIndex ? -200 : 200, -500)
        lastShowingIndex = currentShowingIndex
        trans.m34 = -1.0 / 500
        cell.layer.transform = trans
        UIView.animateWithDuration(0.5) {
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
        }
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
