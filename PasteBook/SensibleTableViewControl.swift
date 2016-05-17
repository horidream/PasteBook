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
    
    init(tableView:UITableView, inputAccessoryView:UIView?) {
        self.tableView = tableView
        self.inputAccessoryView = inputAccessoryView
    }
    
    convenience init(tableView:UITableView){
        self.init(tableView: tableView, inputAccessoryView: nil)
        start()
    }
    
    func start(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
    }
    
    func keyboardWillShow(aNotification:NSNotification){
        if keyboardShown{
            return
        }
        keyboardShown = true
        var tv:UIScrollView = self.tableView
        if(Mirror(reflecting: self.tableView.superview).subjectType == UIScrollView.self){
            tv = self.tableView.superview as! UIScrollView
        }
        if let userInfo = aNotification.userInfo{
            let aValue = userInfo[UIKeyboardFrameEndUserInfoKey]
            let keyboardRect = tv.superview?.convertRect(aValue!.CGRectValue(), fromView: nil)
            var animationDuration:NSTimeInterval = 0
            userInfo[UIKeyboardAnimationDurationUserInfoKey]?.getValue(&animationDuration)
            var animationCurve:UIViewAnimationCurve = .Linear
            userInfo[UIKeyboardAnimationCurveUserInfoKey]?.getValue(&animationCurve)
            
            // Determine how much overlap exists between tableView and the keyboard
            var tableFrame = tableView.frame
            let tableLowerYCoord = tableFrame.origin.y + tableFrame.size.height
            var keyboardOverlap = tableLowerYCoord - keyboardRect!.origin.y
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
                
                var delay:NSTimeInterval = 0;
                if(keyboardRect!.size.height > 0)
                {
                    delay = Double(1 - keyboardOverlap/keyboardRect!.size.height)*animationDuration;
                    animationDuration = animationDuration * Double(keyboardOverlap/keyboardRect!.size.height);
                }
                
                UIView.animateWithDuration(animationDuration, delay: delay, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                        print("animate table view frame from \(self.tableView.frame) to \(tableFrame)")
                        self.tableView.frame = tableFrame
                    }, completion: { (finished) in
                    self.tableAnimationEnded()
                })

            }
        }
    }
    func tableAnimationEnded(){
    }
}


//
//    - (void)keyboardWillHide:(NSNotification *)aNotification
//    {
//    if(!keyboardShown)
//    return;
//    
//    keyboardShown = NO;
//    
//    UIScrollView *tableView;
//    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
//    tableView = (UIScrollView *)self.tableView.superview;
//    else
//    tableView = self.tableView;
//    if(self.inputAccessoryView)
//    {
//    tableView.contentInset = UIEdgeInsetsZero;
//    tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
//    }
//    
//    if(keyboardOverlap == 0)
//    return;
//    
//    // Get the size & animation details of the keyboard
//    NSDictionary *userInfo = [aNotification userInfo];
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
//    
//    NSTimeInterval animationDuration;
//    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
//    UIViewAnimationCurve animationCurve;
//    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
//    
//    CGRect tableFrame = tableView.frame;
//    tableFrame.size.height += keyboardOverlap;
//    
//    if(keyboardRect.size.height)
//    animationDuration = animationDuration * keyboardOverlap/keyboardRect.size.height;
//    
//    [UIView animateWithDuration:animationDuration delay:0
//    options:UIViewAnimationOptionBeginFromCurrentState
//    animations:^{ tableView.frame = tableFrame; }
//    completion:nil];
//    }
//    
//    - (void) tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context
//    {
//    // Scroll to the active cell
//    if(self.activeCellIndexPath)
//    {
//    [self.tableView scrollToRowAtIndexPath:self.activeCellIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
//    [self.tableView selectRowAtIndexPath:self.activeCellIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//    }
//    }
//}
