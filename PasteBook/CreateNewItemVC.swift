//
//  CreateNewItemVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/25/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit
import QuartzCore

class SegueFromLeft: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.sourceViewController
        let dst: UIViewController = self.destinationViewController
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        src.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
    
}

class CreateNewItemVC: UIViewController {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var tagsTF: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    var item:Item?
    var isNewItem:Bool = true
    override func viewDidLoad() {
        self.title = "Create New Item"
        // make the text view's border is same as text field
        contentTextView.layer.cornerRadius = 5
        contentTextView.layer.borderWidth = 1
        let borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        contentTextView.layer.borderColor = borderColor.CGColor
        
        
        // done button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(didCreateNewItem))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let item = self.item{
            titleTF.text = item.title
            contentTextView.text = item.content
            tagsTF.text = item.tags.joinWithSeparator(", ")
            self.title = "Update Item"
            self.isNewItem = false
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.item = nil
        self.isNewItem = true
    }
    
    
    func didCreateNewItem(){
        if( isNewItem){
            PBDBHandler.sharedInstance.addItem(titleTF.text!, content: contentTextView.text)
        }else{
            PBDBHandler.sharedInstance.updateItemWithId((item?.id)!, title: titleTF.text!, content: contentTextView.text)
            let vcs = self.navigationController?.viewControllers
            let cv:ContentViewController = vcs![(vcs?.count)! - 2] as! ContentViewController
            cv.contentTitle = titleTF.text!
            cv.contentDetail = contentTextView.text
            cv.refreshDisplay()
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}
