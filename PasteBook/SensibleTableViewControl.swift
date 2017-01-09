//
//  SensibleTableViewControl.swift
//  PasteBook
//
//  Created by Baoli Zhai on 5/16/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

// [StackOverflow](http://stackoverflow.com/questions/13845426/generic-uitableview-keyboard-resizing-algorithm)
class SensibleTableViewControl:NSObject {
    let tableView:UITableView
    let inputAccessoryView:UIView?
    var keyboardShown:Bool = false
    var keyboardOverlap:CGFloat = 0
    
    init(tableView:UITableView, inputAccessoryView:UIView?) {
        self.tableView = tableView
        self.inputAccessoryView = inputAccessoryView
    }
    
    convenience init(_ tableView:UITableView, _ inputAccessoryView:UIView? = nil, _ autoStart:Bool = true){
        self.init(tableView: tableView, inputAccessoryView: inputAccessoryView)
        if autoStart{
            start()
        }
    }
    
    func start(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func keyboardWillShow(_ aNotification:Notification){
        if keyboardShown || self.tableView.window == nil{
            return
        }
        keyboardShown = true
        var tv:UIScrollView = self.tableView
        if(Mirror(reflecting: self.tableView.superview as Any).subjectType == UIScrollView.self){
            tv = self.tableView.superview as! UIScrollView
        }
        if let userInfo = (aNotification as NSNotification).userInfo{
            let aValue = userInfo[UIKeyboardFrameEndUserInfoKey]
            let keyboardRect = tv.superview?.convert((aValue! as AnyObject).cgRectValue, from: nil)
            var animationDuration:TimeInterval = 0
            (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).getValue(&animationDuration)
            var animationCurve:UIViewAnimationCurve = .linear
            (userInfo[UIKeyboardAnimationCurveUserInfoKey] as AnyObject).getValue(&animationCurve)
            
            // Determine how much overlap exists between tableView and the keyboard
            var tableFrame = tableView.frame
            let tableLowerYCoord = tableFrame.origin.y + tableFrame.size.height
            keyboardOverlap = tableLowerYCoord - keyboardRect!.origin.y
            if((self.inputAccessoryView != nil) && (keyboardOverlap > 0)){
                let accessoryHeight = self.inputAccessoryView!.frame.size.height;
                keyboardOverlap -= accessoryHeight;
                tableView.contentInset = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
                tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
            }
            if(keyboardOverlap < 0){
                keyboardOverlap = 0;
            }
            
            if(keyboardOverlap != 0)
            {
                tableFrame.size.height -= keyboardOverlap;
                
                var delay:TimeInterval = 0;
                if(keyboardRect!.size.height > 0)
                {
                    delay = Double(1 - keyboardOverlap/keyboardRect!.size.height)*animationDuration;
                    animationDuration = animationDuration * Double(keyboardOverlap/keyboardRect!.size.height);
                }
                
                UIView.animate(withDuration: animationDuration, delay: delay, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                        self.tableView.frame = tableFrame
                    }, completion: { (finished) in
                    self.tableAnimationEnded()
                })

            }
        }
    }
    
    func keyboardWillHide(_ aNotification:NSNotification){
        if(!keyboardShown) || self.tableView.window == nil{
            return
        }
        keyboardShown = false
        var tv:UIScrollView = self.tableView
        if(Mirror(reflecting: self.tableView.superview as Any).subjectType == UIScrollView.self){
            tv = self.tableView.superview as! UIScrollView
        }
        if(self.inputAccessoryView) != nil{
            tv.contentInset = .zero
            tv.scrollIndicatorInsets = .zero
        }
        
        if(keyboardOverlap == 0){
            return
        }
        
        if let userInfo = (aNotification as NSNotification).userInfo{
            let aValue = userInfo[UIKeyboardFrameEndUserInfoKey]
            let keyboardRect = (tv.superview?.convert((aValue! as AnyObject).cgRectValue, from: nil))!
            var animationDuration:TimeInterval = 0
            (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).getValue(&animationDuration)
            var animationCurve:UIViewAnimationCurve = .linear
            (userInfo[UIKeyboardAnimationCurveUserInfoKey] as AnyObject).getValue(&animationCurve)
            var tableFrame:CGRect = tv.frame
            tableFrame.size.height += keyboardOverlap
            
            if keyboardRect.size.height > 0{
                animationDuration = animationDuration * Double(keyboardOverlap/keyboardRect.size.height)
            }
            UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                self.tableView.frame = tableFrame
            }, completion: { (finished) in
                self.tableAnimationEnded()
            })

            
        }
    }
    
    
    func tableAnimationEnded(){
        
    }
    
    deinit{
        print("remove keyboard notification observer")
        NotificationCenter.default.removeObserver(self)
    }
}
