//
//  SelectTagsVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/26/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

class SelectTagsVC: UITableViewController {
    
    var data:Array<(id:Int, name:String)> = []
    override func viewDidLoad() {
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TagCell")
        self.data = PBDBHandler.sharedInstance.fetchAllTags()
    }
    
    // MARK: datasource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TagCell")!
        cell.textLabel?.text = data[indexPath.row].name
        return cell
    }

    // MARK: table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newItemVC = self.navigationController!.popoverPresentationController!.delegate as! CreateNewItemVC
        self.dismissViewControllerAnimated(true) {
            let tf = newItemVC.tagsTF
            tf.text = tf.text?.stringByAppendingString((tf.text == "" ? "" : ",")+self.data[indexPath.row].name)
        }
    }

    
}
