//
//  HomeViewController.swift
//  PasteBook
//
//  Created by Baoli.Zhai on 5/20/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tagCarousel: iCarousel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var data:[Tag] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        data = PBDBHandler.sharedInstance.fetchAllTags()
        tagCarousel.type = .Wheel
        tagCarousel.dataSource = self
        tagCarousel.delegate = self
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    func dismissKeyboard(){
        self.searchBar.resignFirstResponder()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}



extension HomeViewController:iCarouselDataSource{
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return self.data.count
    }
    
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var label: UILabel
        var itemView: UIImageView
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            itemView = UIImageView(frame:CGRect(x:0, y:0, width:200, height:200))
            itemView.image = UIImage(named: "page.png")
            itemView.contentMode = .Center
            
            label = UILabel(frame:itemView.bounds)
            label.backgroundColor = UIColor.clearColor()
            label.numberOfLines = 0
            label.textAlignment = .Center
            label.textColor = UIColor.grayColor()
            label.font = label.font.fontWithSize(32)
            label.tag = 1
            itemView.addSubview(label)
        }
        else
        {
            itemView = view as! UIImageView;
            label = itemView.viewWithTag(1) as! UILabel!
        }
        
        let attriTxt = NSAttributedString(string: "\(data[index].name.capitalizedString)", attributes: [NSTextEffectAttributeName: NSTextEffectLetterpressStyle])
        label.attributedText = attriTxt
        
        return itemView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .Spacing:
            return value
        default:
            return value
        }
    }
}
extension HomeViewController:iCarouselDelegate{
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        print("select index at \(index)")
    }
}