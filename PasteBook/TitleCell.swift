//
//  TitleCell.swift
//  PasteBook
//
//  Created by Baoli.Zhai on 24/11/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit
import FoldingCell
import EZSwiftExtensions

class TitleCell: FoldingCell {

    @IBOutlet weak var iconBg: UIView!
    @IBOutlet weak var iconTitle: UILabel!
    @IBOutlet weak var title: UILabel!

    @IBOutlet weak var detailBtn: UIButton!
    
    weak var tableView:UITableView?

    override func awakeFromNib() {
        super.awakeFromNib()
        let foreLayer = self.foregroundView.layer
        foreLayer.cornerRadius = 10
        foreLayer.shadowOffset = CGSize(width: 0, height: 0)
        foreLayer.shadowRadius = 2
        foreLayer.shadowOpacity = 0.7
        self.containerView.layer.cornerRadius = 10
        self.containerView.layer.contents = #imageLiteral(resourceName: "cell_open").cgImage
        self.accessoryView?.backgroundColor = self.containerView.backgroundColor
        self.backViewColor = UIColor.lightGray
        iconBg.layer.cornerRadius = iconBg.layer.frame.width / 2
        iconBg.backgroundColor = UIColor.randomColor()
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onShowDetail(tap:)))
        detailBtn.addGestureRecognizer(tap)
    }
    
    func onShowDetail(tap:UITapGestureRecognizer){
        print("\(self) detail button is tapped")
        if let tableView = tableView{
            tableView.delegate?.tableView!(tableView, accessoryButtonTappedForRowWith: tableView.indexPath(for: self)!)
        }
    }
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
        
    }
}
