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

class CreateNewItemVC: UIViewController, UIPopoverPresentationControllerDelegate,DropperDelegate  {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var categorySelector: UIButton!
    
    
    var currentArticle:Article?
    private var dropper:Dropper!
    var categories:Array<CategorySet> = []
    var selectedCategory:CategorySet?
    override func viewDidLoad() {
        self.title = "New Article"
        
        
        // done button
        self.prepareAutoScrollContentTextView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didCreateNewArticle))
        
        
        categorySelector.addTarget(self, action: #selector(onSelectCategory), for: UIControlEvents.touchUpInside)
        dropper = Dropper(width: 150, height: 200)
        dropper.theme = .black(.gray)
        dropper.border = (width: 1, color:.white)
        dropper.cellTextSize = 14
        dropper.spacing = 0
        dropper.maxHeight = 200
        dropper.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = "BACK"
        categorySelector.setTitle(self.selectedCategory?.any?.name ?? "", for: .normal)
        categories = PBDBManager.default.fetchAllCategories()
        dropper.items = categories.map{$0.any?.name ?? ""}
        
        if let article = currentArticle{
            self.title = article.title
            titleTF.text = article.title
            contentTextView.text = article.content
        }
    }
    
    func onSelectCategory(_ sender:UIButton){
        if dropper.status == .hidden {
            dropper.showWithAnimation(0.15, options: .left, button: sender)
        }else{
            dropper.hideWithAnimation(0.1)
        }
    }
    
    func DropperSelectedRow(_ path: IndexPath, contents: String, tag: Int) {
        selectedCategory = categories[path.row]
//        currentArticle?.categoryId = selectedCategory?.localId
        categorySelector.setTitle(selectedCategory?.any?.name, for: .normal)
    }
    
    
    var isCreatingNew:Bool{
        if let _ = currentArticle{
            return false
        }
        return true
    }
    
    func didCreateNewArticle(){
        if isCreatingNew{

            let article = Article(title:titleTF.text!, content:contentTextView.text)
            article.category.localId = selectedCategory?.localId
            article.saveToLocal()
            self.currentArticle = article
            if let titleVC = self.navigationController?.viewControllers.last as? TitleTableVC{
                delay(0.3, closure: {
                    titleVC.refresh()
                    
                })
            }else if let titleVC = self.splitViewController?.viewControllers.first?.childViewControllers.first as? TitleTableVC{
                delay(0.3, closure: {
                    titleVC.refresh()
                    
                })
            }
        }else{
            currentArticle?.title = titleTF.text!
            currentArticle?.content = contentTextView.text
            let article = PBDBManager.default.updateArticle(currentArticle!, with: self.currentArticle?.category ?? .undefined)
            _ = self.navigationController?.popViewController(animated: true)
            if let detailVC = self.navigationController?.viewControllers.last as? ArticleDetailViewController{
                delay(0.3, closure: {
                    detailVC.article = article
                    detailVC.refreshDisplay()
                })
            }
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: popover delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let advc = segue.destination as! ArticleDetailViewController
            advc.article = self.currentArticle
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}


// MARK: - Auto Scroll contentTextView
extension CreateNewItemVC: UITextViewDelegate{
    
    func prepareAutoScrollContentTextView() {
        self.contentTextView.delegate = self
        
        // observe these 2 notification for the cases in either
        // with soft keyboard or blue tooth keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(CreateNewItemVC.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateNewItemVC.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // resign all in view
        self.view.endEditing(true)
    }
    
    func updateTextView(notification:Notification){
        let userInfo = notification.userInfo!
        // value is a NSValue , needs cast
        var keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        // the rect is not count on the orientation, so we need to convert it base on windows
        keyboardRect = self.view.convert(keyboardRect, to: self.view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            self.contentTextView.contentInset = .zero
        }else{
            // inset minus the keyboard height
            self.contentTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.height, right: 0)
            self.contentTextView.scrollIndicatorInsets = self.contentTextView.contentInset
        }
        // scroll to the selection
        self.contentTextView.scrollRangeToVisible(self.contentTextView.selectedRange)
    }
}


