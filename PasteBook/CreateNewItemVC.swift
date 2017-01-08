//
//  CreateNewItemVC.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/25/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit
import QuartzCore
import Dropper

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


class CreateNewItemVC: UIViewController, UIPopoverPresentationControllerDelegate,DropperDelegate  {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var categorySelector: UIButton!
    
    
    var currentCategory:Category?
    var currentArticle:Article?
    private var dropper:Dropper!
    var categories:Array<CategoryInfo> = []
    var selectedCategoryInfo:CategoryInfo?
    override func viewDidLoad() {
        self.title = "New Article"
        // make the text view's border is same as text field
        
        contentTextView.layer.cornerRadius = 5
        contentTextView.layer.borderWidth = 1
        let borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        contentTextView.layer.borderColor = borderColor.cgColor
        
        
        // done button
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didCreateNewArticle))
        
        
        categorySelector.addTarget(self, action: #selector(onSelectCategory), for: UIControlEvents.touchUpInside)
        dropper = Dropper(width: categorySelector.frame.width, height: 200)
        dropper.theme = .black(categorySelector.backgroundColor ?? .black)
        dropper.border = (width: 2, color:.black)
        dropper.spacing = 0
        dropper.maxHeight = 200
        dropper.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = "BACK"
        categorySelector.setTitle(currentCategory?.name ?? Category.unsaved.name, for: .normal)
        categories = PBDBManager.default.fetchAllCategories()
        dropper.items = categories.map{$0.name}
        
        if let article = currentArticle{
            self.title = article.title
            titleTF.text = article.title
            contentTextView.text = article.content
        }
    }
    
    func onSelectCategory(_ sender:UIButton){
        if dropper.status == .hidden {
            dropper.showWithAnimation(0.15, options: .center, button: sender)
        }else{
            dropper.hideWithAnimation(0.1)
        }
    }
    
    func DropperSelectedRow(_ path: IndexPath, contents: String, tag: Int) {
        selectedCategoryInfo = categories[path.row]
        if let d = selectedCategoryInfo{
            currentCategory = Category(name:d.name, id:d.id)
        }
        categorySelector.setTitle(selectedCategoryInfo?.name, for: .normal)
    }
    
    
    var isCreatingNew:Bool{
        if let _ = currentArticle{
            return false
        }
        return true
    }
    
    func didCreateNewArticle(){
        if isCreatingNew{
            _ = PBDBManager.default.addArticle(Article(title:titleTF.text!, content:contentTextView.text), to: currentCategory ?? .unsaved)
            _ = self.navigationController?.popViewController(animated: true)
            if let titleVC = self.navigationController?.viewControllers.last as? TitleTableVC{
                delay(0.3, closure: {
                    titleVC.refresh()
                    
                })
            }
        }else{
            currentArticle?.title = titleTF.text!
            currentArticle?.content = contentTextView.text
            print(currentCategory)
            let article = PBDBManager.default.updateArticle(currentArticle!, with: currentCategory ?? .unsaved)
            _ = self.navigationController?.popViewController(animated: true)
            if let detailVC = self.navigationController?.viewControllers.last as? ArticleDetailViewController{
                delay(0.3, closure: {
                    detailVC.article = article
                    detailVC.refreshDisplay()
                })
            }
        }
        
        
    }
    
    // MARK: popover delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectTag" {
            let navigationVC = segue.destination as! UINavigationController
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


