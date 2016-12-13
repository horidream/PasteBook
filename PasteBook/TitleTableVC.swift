//
//  TitleTableVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 1/5/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit
import FoldingCell

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
//typealias Tag = (id:Int, name:String)
typealias Item = (id:Int, title:String, content:String, tags:[Tag])

func == <T:Equatable> (tuple1:(T,T,T,T),tuple2:(T,T,T,T)) -> Bool
{
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1) && (tuple1.2 == tuple2.2) && (tuple1.3 == tuple2.3)
}

func != <T:Equatable> (tuple1:(T,T,T,T),tuple2:(T,T,T,T)) -> Bool
{
    return !(tuple1==tuple2)
}

fileprivate struct C {
    struct CellHeight {
        static let close: CGFloat = 100 // equal or greater foregroundView height
        static let open: CGFloat = 270 // equal or greater containerView height
    }
}


class TitleTableVC: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UISplitViewControllerDelegate {
    var cellHeights:[CGFloat]!
    var data:Array<(id:UInt64,title:String)> = []
    let searchController = UISearchController(searchResultsController: nil)
    var tvControl:SensibleTableViewControl?
    var firstLaunch:Bool = true
    var lastShowingIndex:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        tvControl = SensibleTableViewControl(self.tableView, self.inputAccessoryView)
        
        tableView.register(UINib.init(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier:"myCell")
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        
        
        data = PBDBManager.default.fetchAllArticleTitles().reversed()
//        data = PBDBHandler.sharedInstance.fetchAllTitle().reversed()
        cellHeights = (0..<data.count).map { _ in C.CellHeight.close }
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
        
        self.tableView.estimatedRowHeight = 75
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // stop refresh when done
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        if firstLaunch{
        //            self.splitViewController?.performSegue(withIdentifier: "HomeView", sender: self)
        //            firstLaunch = false
        //        }
        
    }
    
    func refreshData(){
        data = PBDBManager.default.fetchAllArticleTitles().reversed()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! TitleCell
        cell.tableView = self.tableView
        cell.title.text = data[(indexPath as NSIndexPath).row].title
        cell.iconTitle.textColor = UIColor.randomColor()
//        cell.iconTitle.lineWidth = 1
        cell.iconTitle.text = (data[(indexPath as NSIndexPath).row].title[0..<2]).capitalized
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    // MARK: table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let cell as FoldingCell = tableView.cellForRow(at: indexPath) else {
            return
        }
        var duration = 0.0
        if cellHeights[indexPath.row] ==  C.CellHeight.close{ // open cell
            cellHeights[indexPath.row] = C.CellHeight.open
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[indexPath.row] = C.CellHeight.close
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 1.1
        }
        
        UIView.animate(withDuration:duration, delay: 0, options: .curveEaseOut, animations: { _ in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: ["id":data[(indexPath as NSIndexPath).row].id])
        searchController.searchBar.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
//            PBDBHandler.sharedInstance.removeItemWithId(self.data[(indexPath as NSIndexPath).row].id)
            self.data.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? FoldingCell {
            if cellHeights![indexPath.row] == C.CellHeight.close {
                cell.selectedAnimation(false, animated: false, completion:nil)
            } else {
                cell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
    
    
    // MARK: search result
    func updateSearchResults(for searchController: UISearchController) {
//        self.data = PBDBHandler.sharedInstance.fetchTitlesLike(searchController.searchBar.text!)
        self.tableView.reloadData()
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
