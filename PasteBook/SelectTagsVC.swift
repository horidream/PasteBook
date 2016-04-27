//  SelectTagsVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/26/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

class SelectTagsVC: UITableViewController {
    
    var data:Array<(id:Int, name:String)> = []
    var currentItem:Item?
    var selectedTagIds:Array = [Int]()
    var selectedTags:Array<(id:Int, name:String)> = []{
        didSet{
            selectedTagIds = selectedTags.map{$0.id}
        }
    }
    override func viewDidLoad() {
        self.tableView.registerClass(TagCell.self, forCellReuseIdentifier: "TagCell")
        self.data = PBDBHandler.sharedInstance.fetchAllTags()
    }
    
    // MARK: datasource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TagCell") as! TagCell
        cell.textLabel?.text = data[indexPath.row].name
        cell.ticked = selectedTagIds.contains(data[indexPath.row].id)
        return cell
    }

    // MARK: table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TagCell
        cell.ticked = true
        self.selectedTags.append(data[indexPath.row])
        
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TagCell
        cell.ticked = false
        if let index = self.selectedTags.indexOf({ (id, name) -> Bool in
            id == data[indexPath.row].id
        }){
            self.selectedTags.removeAtIndex(index)
        }
    }
    
    
    
    @IBAction func onDonePressed(sender: AnyObject) {
        let newItemVC = self.navigationController!.popoverPresentationController!.delegate as! CreateNewItemVC
        self.dismissViewControllerAnimated(true) {
            newItemVC.item = self.currentItem
//            let tf = newItemVC.tagsTF
            //            PBDBHandler.sharedInstance.addTag(self.data[indexPath.row].id, withItemID: (self.currentItem?.id)!)
//            tf.text = tf.text?.stringByAppendingString((tf.text == "" ? "" : ",")+self.data[indexPath.row].name)
//            newItemVC.item = self.currentItem
//            newItemVC.refreshUI()
        }
        
    }
    
    

    
}
