//
//  TitleTableVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 1/5/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
        self.refreshControl!.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        self.tableView.dataSource = self
        data = PBDBHandler.sharedInstance.fetchAllTitle().reversed()
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.returnKeyType = .done
        
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItem))
        self.navigationItem.title = "Manage Your Knowledge"
        let searchBar = searchController.searchBar
        self.tableView.tableHeaderView = searchBar
        self.tableView.contentOffset = CGPoint(x: 0, y: searchBar.frame.height)
        
        self.splitViewController?.preferredDisplayMode = .allVisible
        self.splitViewController?.delegate = self
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // stop refresh when done
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstLaunch{
            self.splitViewController?.performSegue(withIdentifier: "HomeView", sender: self)
            firstLaunch = false
        }
        
    }
    
    func refreshData(){
        self.refreshControl?.beginRefreshing()
        data = PBDBHandler.sharedInstance.fetchAllTitle().reversed()
        self.refreshControl!.endRefreshing()
        self.tableView.reloadSections(IndexSet(integer:0), with: .bottom)
    }
    
    func addNewItem(){
        self.performSegue(withIdentifier: "CreateNew", sender: self)
    }
    // MARK: navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier{
            switch id {
            case "showDetail":
                let nv = segue.destination as! UINavigationController
                let vc = nv.viewControllers[0] as! ContentDetailVC
                let id = ((sender as AnyObject).value(forKey: "id") as! Int)
                let detail = PBDBHandler.sharedInstance.fetchDetail(id)
                vc.tags = PBDBHandler.sharedInstance.fetchTagsById(id)
                vc.contentTitle = detail.title
                vc.contentDetail = detail.detail
                vc.itemID = id
            case "CreateNew":
                let cnvc = segue.destination as! CreateNewItemVC
                cnvc.isNewItem = true
            default:()
            }
        }
        
        
    }
    
    // MARK: table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.lineBreakMode = .byWordWrapping;
        cell.textLabel?.text = data[(indexPath as NSIndexPath).row].title
        return cell
    }
    
    // MARK: table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: ["id":data[(indexPath as NSIndexPath).row].id])
        searchController.searchBar.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            PBDBHandler.sharedInstance.removeItemWithId(self.data[(indexPath as NSIndexPath).row].id)
            self.data.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let currentShowingIndex = (indexPath as NSIndexPath).row
        
        cell.alpha = 0
        var trans = CATransform3DTranslate(CATransform3DIdentity, 0, lastShowingIndex > currentShowingIndex ? -200 : 200, -500)
        lastShowingIndex = currentShowingIndex
        trans.m34 = -1.0 / 500
        cell.layer.transform = trans
        UIView.animate(withDuration: 0.5, animations: {
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
        }) 
    }
    
    // MARK: search result
    func updateSearchResults(for searchController: UISearchController) {
        self.data = PBDBHandler.sharedInstance.fetchTitlesLike(searchController.searchBar.text!)
        self.tableView.reloadData()
    }
 
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
