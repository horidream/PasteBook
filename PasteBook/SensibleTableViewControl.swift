//
//  SensibleTableViewControl.swift
//  PasteBook
//
//  Created by Baoli Zhai on 5/16/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

struct SensibleTableViewControl {
    let tableView:UITableView
    var keyboardShow:Bool = false
    mutating func keyboardWillShow(aNotification:NSNotification){
        if keyboardShow{
            return
        }
        keyboardShow = true
        var tv:UIScrollView = self.tableView
        if(Mirror(reflecting: self.tableView.superview).subjectType == UIScrollView.self){
            tv = self.tableView.superview as! UIScrollView
        }
        if let userInfo = aNotification.userInfo{
            let aValue = userInfo[UIKeyboardFrameEndUserInfoKey]
            let keybaordRect = tv.superview?.convertRect(aValue!.CGRectValue(), fromView: nil)
            var animationDuration:NSTimeInterval
            userInfo[UIKeyboardAnimationDurationUserInfoKey]?.getValue(&animationDuration)
        }
    }
}
    
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
//    
//    // Get the keyboard's animation details
//    NSTimeInterval animationDuration;
//    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
//    UIViewAnimationCurve animationCurve;
//    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
//    
//    // Determine how much overlap exists between tableView and the keyboard
//    CGRect tableFrame = tableView.frame;
//    CGFloat tableLowerYCoord = tableFrame.origin.y + tableFrame.size.height;
//    keyboardOverlap = tableLowerYCoord - keyboardRect.origin.y;
//    if(self.inputAccessoryView && keyboardOverlap>0)
//    {
//    CGFloat accessoryHeight = self.inputAccessoryView.frame.size.height;
//    keyboardOverlap -= accessoryHeight;
//    
//    tableView.contentInset = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
//    tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
//    }
//    
//    if(keyboardOverlap < 0)
//    keyboardOverlap = 0;
//    
//    if(keyboardOverlap != 0)
//    {
//    tableFrame.size.height -= keyboardOverlap;
//    
//    NSTimeInterval delay = 0;
//    if(keyboardRect.size.height)
//    {
//    delay = (1 - keyboardOverlap/keyboardRect.size.height)*animationDuration;
//    animationDuration = animationDuration * keyboardOverlap/keyboardRect.size.height;
//    }
//    
//    [UIView animateWithDuration:animationDuration delay:delay
//    options:UIViewAnimationOptionBeginFromCurrentState
//    animations:^{ tableView.frame = tableFrame; }
//    completion:^(BOOL finished){ [self tableAnimationEnded:nil finished:nil contextInfo:nil]; }];
//    }
//    }
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
