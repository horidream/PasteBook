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
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        src.navigationController!.view.layer.add(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
    
}


class CreateNewItemVC: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var tagsTF: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    var currentCategory:Category?

    
    override func viewDidLoad() {
        self.title = "New Article"
        // make the text view's border is same as text field
        contentTextView.layer.cornerRadius = 5
        contentTextView.layer.borderWidth = 1
        let borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        contentTextView.layer.borderColor = borderColor.cgColor
        
        
        // done button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didCreateNewItem))
    }
    

    
    func didCreateNewItem(){
        _ = PBDBManager.default.addArticle(Article(title:titleTF.text!, content:contentTextView.text), to: currentCategory ?? .unsaved)
        
        
        let _ = self.navigationController?.popViewController(animated: true)
        if let titleVC = self.navigationController?.viewControllers.last as? TitleTableVC{
            delay(0.3, closure: { 
                titleVC.refreshData()
                
            })
        }
    }
    
    // MARK: popover delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectTag" {
            let navigationVC = segue.destination as! UINavigationController
//            let selectTagVC = navigationVC.viewControllers.first as! SelectTagsVC
            navigationVC.modalPresentationStyle = UIModalPresentationStyle.popover
            navigationVC.popoverPresentationController!.delegate = self
            
            if let popoverPresentationController = segue.destination.popoverPresentationController, let sourceView = sender as? UIView {
                popoverPresentationController.sourceRect = sourceView.bounds
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
