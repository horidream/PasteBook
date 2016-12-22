//
//  AddNewTagVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 5/16/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit
class AddNewTagVC: UIViewController {

    @IBOutlet weak var newTagInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onAddNewTag))
    }
    
    func onAddNewTag(){
        if let newTag = self.newTagInput.text{
//            let newTag = PBDBHandler.sharedInstance.createNewTag(newTag)
//            let _ = self.navigationController?.popViewController(animated: true)
//            if let tagsVC = self.navigationController?.viewControllers.last as? SelectTagsVC, let newTag = newTag{
////                tagsVC.data.append((id:newTag["id"] as! Int, name:newTag["name"] as! String))
//                tagsVC.tableView.reloadSections(IndexSet(integer:0), with: .fade)
//            }
        }
    }
}
