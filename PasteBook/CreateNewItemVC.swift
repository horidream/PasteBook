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
        (src as! UINavigationController).view.layer.addAnimation(transition, forKey: kCATransition)
        (src as! UINavigationController).pushViewController(dst, animated: false)
    }
    
}

class CreateNewItemVC: UIViewController {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var tagsTF: UITextField!
    
    @IBOutlet weak var contentTextView: UITextView!
    override func viewDidLoad() {
        // make the text view's border is same as text field
        contentTextView.layer.cornerRadius = 5
        contentTextView.layer.borderWidth = 1
        let borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        contentTextView.layer.borderColor = borderColor.CGColor
        
        
        // done button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(didCreateNewItem))
    }
    
    
    func didCreateNewItem(){
        print("did create new item")
    }
}
