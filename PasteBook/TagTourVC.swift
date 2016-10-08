//
//  TagTourVC.swift
//  PasteBook
//
//  Created by Baoli.Zhai on 5/31/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

class TagTourVC: UIViewController {

    @IBOutlet weak var tagCarousel: iCarousel!
    

    var data:[Tag] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        data = PBDBHandler.sharedInstance.fetchAllTags()
        tagCarousel.type = .coverFlow2
        tagCarousel.dataSource = self
        tagCarousel.delegate = self
        
        
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}



extension TagTourVC:iCarouselDataSource{
    func numberOfItems(in carousel: iCarousel) -> Int {
        return self.data.count
    }
    
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        var itemView: UIImageView
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            itemView = UIImageView(frame:CGRect(x:0, y:0, width:200, height:200))
            itemView.image = UIImage(named: "page.png")
            itemView.contentMode = .center
            
            label = UILabel(frame:itemView.bounds)
            label.backgroundColor = UIColor.clear
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = UIColor.gray
            label.font = label.font.withSize(32)
            label.tag = 1
            itemView.addSubview(label)
        }
        else
        {
            itemView = view as! UIImageView;
            label = itemView.viewWithTag(1) as! UILabel!
        }
        
        let attriTxt = NSAttributedString(string: "\(data[index].name.capitalized)", attributes: [NSTextEffectAttributeName: NSTextEffectLetterpressStyle])
        label.attributedText = attriTxt
        
        return itemView
    }
    
    @objc(carousel:valueForOption:withDefault:) func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .spacing:
            return value
        default:
            return value
        }
    }
}

extension TagTourVC:iCarouselDelegate{
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        print("select index at \(index)")
            self.navigationController?.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: {})
                
            })
            
    }
}
