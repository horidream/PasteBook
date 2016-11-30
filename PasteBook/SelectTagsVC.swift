//  SelectTagsVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/26/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

extension Sequence where Self.Iterator.Element == Tag{
    func contains(_ tag:Tag)->Bool{
        return self.contains {($0.isSaved == tag.isSaved) && ($0.name == tag.name)}
    }
}

class SelectTagsVC: UITableViewController {}

//class TagChanges : CustomStringConvertible{
//    var tags:Array<Tag>
//    var addedTags:[Tag] = []
//    var removedTags:[Tag] = []
//    init(tags:Array<Tag>){
//        self.tags = tags
//    }
//    
//    func add(_ tag:Tag){
//        if !removedTags.contains(tag){
//            addedTags.append(tag)
//        }else{
//            if let index = removedTags.index(where: {$0.id == tag.id && $0.name == tag.name}){
//                removedTags.remove(at: index)
//            }
//        }
//    }
//    
//    func remove(_ tag:Tag){
//        if !addedTags.contains(tag){
//            removedTags.append(tag)
//        }else{
//            if let index = addedTags.index(where: {$0.id == tag.id && $0.name == tag.name}){
//                addedTags.remove(at: index)
//            }
//        }
//    }
//    
//    
//    var selectedTags:[Tag]{
//        return ((self.tags + self.addedTags).filter{
//            !self.removedTags.contains($0)
//            })
//    }
//    
//    var displayedTags:String{
//        
//        return selectedTags.map({ (id, name) -> String in
//            return name
//        }).joined(separator: ",")
//    }
//    
//    func updateWithItemId(_ itemId:Int){
//        for t in removedTags{
//            PBDBHandler.sharedInstance.removeTagWithId(t.id)
//        }
//        
//        for t in addedTags{
//            PBDBHandler.sharedInstance.addTag(t.id, withItemID: itemId)
//        }
//        
//        self.tags = (self.tags + self.addedTags).filter{
//            !self.removedTags.contains($0)
//            }
//
//    }
//    
//    
//    var description:String {
//        return "added: \(addedTags), removed:\(removedTags)"
//    }
//}
//
//class SelectTagsVC: UITableViewController {
//    
//    var data:Array<(id:Int, name:String)> = []
//    var currentItem:Item?{
//        didSet{
//            selectedTags = currentItem?.tags ?? []
//        }
//    }
//    var selectedTagIds:Array = [Int]() // for fast check if a cell is checked
//    var selectedTags:Array<(id:Int, name:String)> = []{
//        didSet{
//            selectedTagIds = selectedTags.map{$0.id}
//        }
//    }
//    var tagChanges:TagChanges?
//    override func viewDidLoad() {
//        self.tableView.register(TagCell.self, forCellReuseIdentifier: "TagCell")
//        self.data = PBDBHandler.sharedInstance.fetchAllTags()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        let allTagIds = data.map{$0.id}
//        for (i, _ )  in tagChanges!.selectedTags{
//            if let index = allTagIds.index(of: i){
//                self.tableView.selectRow(at: IndexPath(row:index, section: 0),animated:false, scrollPosition:.none)
//            }
//        }
//    }
//    
//    // MARK: datasource
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return data.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell") as! TagCell
//        cell.textLabel?.text = data[(indexPath as NSIndexPath).row].name
//        cell.ticked = tagChanges!.selectedTags.map{$0.id}.contains(data[(indexPath as NSIndexPath).row].id)
//        
//        return cell
//    }
//
//    // MARK: table view delegate
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! TagCell
//        cell.ticked = true
//        tagChanges?.add(data[(indexPath as NSIndexPath).row])
//        
//        
//    }
//    
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! TagCell
//        cell.ticked = false
//        tagChanges?.remove(data[(indexPath as NSIndexPath).row])
//    }
//    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if(editingStyle == .delete){
//            tagChanges?.remove(data[(indexPath as NSIndexPath).row])
//            PBDBHandler.sharedInstance.removeTagWithId(self.data[(indexPath as NSIndexPath).row].id)
//            self.data.remove(at: (indexPath as NSIndexPath).row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
//    
//    
//    @IBAction func onDonePressed(_ sender: AnyObject) {
//        let newItemVC = self.navigationController!.popoverPresentationController!.delegate as! CreateNewItemVC
////        newItemVC.popoverPresentationControllerDidDismissPopover(self.navigationController!.popoverPresentationController!)
//        self.navigationController?.dismiss(animated: true) {
//            newItemVC.tagChanges = self.tagChanges
//            newItemVC.tagsTF.text = self.tagChanges?.displayedTags
//        }
//        
//    }
//    
//    
//
//    
//}
