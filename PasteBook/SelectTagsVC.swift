//  SelectTagsVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/26/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

extension SequenceType where Self.Generator.Element == Tag{
    func contains(tag:Tag)->Bool{
        return self.contains {($0.id == tag.id) && ($0.name == tag.name)}
    }
}

class TagChanges : CustomStringConvertible{
    let tags:Array<Tag>
    var addedTags:[Tag] = []
    var removedTags:[Tag] = []
    init(tags:Array<Tag>){
        self.tags = tags
    }
    
    func add(tag:Tag){
        if !removedTags.contains(tag){
            addedTags.append(tag)
        }else{
            if let index = removedTags.indexOf({$0.id == tag.id && $0.name == tag.name}){
                removedTags.removeAtIndex(index)
            }
        }
    }
    
    func remove(tag:Tag){
        if !addedTags.contains(tag){
            removedTags.append(tag)
        }else{
            if let index = addedTags.indexOf({$0.id == tag.id && $0.name == tag.name}){
                addedTags.removeAtIndex(index)
            }
        }
    }
    
    var description:String {
        return "added: \(addedTags), removed:\(removedTags)"
    }
}

class SelectTagsVC: UITableViewController {
    
    var data:Array<(id:Int, name:String)> = []
    var currentItem:Item?{
        didSet{
            selectedTags = currentItem?.tags ?? []
        }
    }
    var selectedTagIds:Array = [Int]() // for fast check if a cell is checked
    var selectedTags:Array<(id:Int, name:String)> = []{
        didSet{
            selectedTagIds = selectedTags.map{$0.id}
        }
    }
    var tagChanges:TagChanges?
    override func viewDidLoad() {
        self.tableView.registerClass(TagCell.self, forCellReuseIdentifier: "TagCell")
        self.data = PBDBHandler.sharedInstance.fetchAllTags()
    }
    
    override func viewWillAppear(animated: Bool) {
        tagChanges = TagChanges(tags: data)
        let allTagIds = data.map{$0.id}
        for i in selectedTagIds{
            if let index = allTagIds.indexOf(i){
                self.tableView.selectRowAtIndexPath(NSIndexPath(forRow:index, inSection: 0),animated:false, scrollPosition:.None)
            }
        }
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
        tagChanges?.add(data[indexPath.row])
        
        
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TagCell
        cell.ticked = false
        if let index = self.selectedTags.indexOf({ (id, name) -> Bool in
            id == data[indexPath.row].id
        }){
            self.selectedTags.removeAtIndex(index)
        }
        tagChanges?.remove(data[indexPath.row])
    }
    
    
    
    
    @IBAction func onDonePressed(sender: AnyObject) {
        let newItemVC = self.navigationController!.popoverPresentationController!.delegate as! CreateNewItemVC
        newItemVC.popoverPresentationControllerDidDismissPopover(self.navigationController!.popoverPresentationController!)
        self.navigationController?.dismissViewControllerAnimated(true) {
            print(self.tagChanges)
        }
        
    }
    
    

    
}
