//
//  TitleTableVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 1/5/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit
import FoldingCell



fileprivate struct C {
    struct CellHeight {
        static let close: CGFloat = 74 // equal or greater foregroundView height (66)
        static let open: CGFloat = 206 // equal or greater containerView height (198)
    }
}


class TitleTableVC: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UISplitViewControllerDelegate {
    var cellHeights:[CGFloat]!
    var data:Array<ArticleSet> = []
    var categoryData:Array<Category>!
    var currentCategory:Category?
    let searchController = UISearchController(searchResultsController: nil)
    var tvControl:SensibleTableViewControl?
    
    lazy var swipeGesture:UISwipeGestureRecognizer = {
        let g = UISwipeGestureRecognizer(target: self, action: #selector(self.onBackBarPressed))
        g.direction = .right
        return g
    }()
    
    var firstLaunch:Bool = true
    var lastShowingIndex:Int?
    let rootTitle = "Knoma"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvControl = SensibleTableViewControl(self.tableView, self.inputAccessoryView)
        
        tableView.register(UINib.init(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier:"myCell")
        
        self.tableView.dataSource = self
        
        
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self

        self.searchController.searchBar.barTintColor = .white
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.returnKeyType = .done
        // add input accessor view for search 
        let toolbar = UIToolbar(frame: CGRect(x:0, y:0, width:self.view.frame.size.width, height: 50))
        
        let cameraIcon = "\u{F118}".icon(fontSize: 30, fontColor: .blue)
        toolbar.items = [
            UIBarButtonItem(image:cameraIcon, style:.plain , target: self, action: #selector(addNewItem))
        ]
        self.searchController.searchBar.inputAccessoryView = toolbar
        
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItem))
        self.navigationItem.title = rootTitle
        let searchBar = searchController.searchBar
        self.tableView.tableHeaderView = searchBar
        self.tableView.contentOffset = CGPoint(x: 0, y: searchBar.frame.height + 1)
        
        self.splitViewController?.preferredDisplayMode = .allVisible
        self.splitViewController?.delegate = self
        
        self.tableView.estimatedRowHeight = 75
        self.tableView.rowHeight = UITableViewAutomaticDimension
        refresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func addNewItem(){
//        let detail:ArticleDetailViewController = (UIStoryboard.mainStoryboard?.instantiateViewController(withIdentifier: "detail"))! as! ArticleDetailViewController
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        self.splitViewController?.showDetailViewController(detail, sender: self)
//        CATransaction.commit()
        if let edit:CreateNewItemVC = UIStoryboard.mainStoryboard?.instantiateViewController(withIdentifier: "edit") as? CreateNewItemVC{
            edit.selectedCategory = self.currentCategory
            self.splitViewController?.showDetailViewController(edit, sender: self)
            
        }
    }
    
    
    // MARK: navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier{
            if shouldShowArticles{
                switch id {
                case "showDetail":
                    let nav = segue.destination as! UINavigationController
                    let vc = nav.topViewController as! ArticleDetailViewController
                    let article = ((sender as AnyObject).value(forKey: "article") as! Article)
                    vc.article = article
                    vc.searchText = ((sender as AnyObject).value(forKey: "searchText")) as? String
                case "CreateNew":
                    let navi = segue.destination as! UINavigationController
                    let cnvc = navi.viewControllers.first as! CreateNewItemVC
                    cnvc.selectedCategory = self.currentCategory
                default:()
                }
            }
        }
        
        
    }
    
    // MARK: table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouldShowArticles ? data.count : categoryData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowArticles{
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! TitleCell
            let cellData = data[(indexPath as NSIndexPath).row]
            cell.tableView = self.tableView
            cell.title.text = cellData.title
//            cell.ribbonColor = cellData.color
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CategoryCell")
            let cellData = categoryData[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = cellData.name
//            cell.detailTextLabel?.text = "\(cellData.count) items"
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return shouldShowArticles ? cellHeights[indexPath.row] : 50
    }
    
    // MARK: table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowArticles{
            performSegue(withIdentifier: "showDetail", sender: ["article":data[(indexPath as NSIndexPath).row], "searchText":searchController.searchBar.text!])
        }else{
            let t = CATransition()
            t.duration = 0.2
            t.type = kCATransitionPush
            t.subtype = kCATransitionFromRight
            tableView.layer.add(t, forKey: nil)
            
            currentCategory = categoryData[indexPath.row]
            self.navigationItem.title = currentCategory?.name
            let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.onBackBarPressed))
            backButton.image = #imageLiteral(resourceName: "BackButton")
            self.navigationItem.leftBarButtonItem = backButton
            self.tableView.addGestureRecognizer(self.swipeGesture)
            refresh()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func onBackBarPressed(sender:Any?){
        self.tableView.removeGestureRecognizer(swipeGesture)
        let t = CATransition()
        t.duration = 0.2
        t.type = kCATransitionPush
        t.subtype = kCATransitionFromLeft
        self.tableView.layer.add(t, forKey: nil)
        self.currentCategory = nil
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.title = rootTitle
        refresh()
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            if shouldShowArticles{
                PBDBManager.default.deleteArticleById(id: data[indexPath.row].localId!)
                self.data.remove(at: (indexPath as NSIndexPath).row)
                
                
            }else{
                self.categoryData.remove(at: (indexPath as NSIndexPath).row)
            }
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
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func refresh(){
        if shouldShowArticles{
            self.data = PBDBManager.default.fetchArticles(withKeywords: searchController.searchBar.text!, category:currentCategory).sorted(by: { $0.title.localizedCaseInsensitiveCompare( $1.title) == ComparisonResult.orderedAscending
            })
            cellHeights = (0..<data.count).map { _ in C.CellHeight.close }
            self.tableView.separatorStyle = .none
        }else{
            self.categoryData = PBDBManager.default.fetchAllCategories().sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
            })
            self.tableView.separatorStyle = .singleLine
        }
        self.tableView.reloadData()
    }
    
    private var shouldShowArticles:Bool{
        if let searchText = searchController.searchBar.text, searchText.trimmed() != ""{
            return true
        }
        if currentCategory != nil{
            return true
        }
        return false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        refresh()
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    
    // MARK - 
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        let currentCollation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
        let sectionTitles = currentCollation.sectionTitles as NSArray
        return sectionTitles.object(at: section) as! String
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView!) -> NSArray! {
        let currentCollation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
        return currentCollation.sectionIndexTitles as NSArray
    }
    
    func tableView(tableView: UITableView!, sectionForSectionIndexTitle title: String!, atIndex index: Int) -> Int {
        let currentCollation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
        return currentCollation.section(forSectionIndexTitle: index)
    }
}
