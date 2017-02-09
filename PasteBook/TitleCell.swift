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

    @IBOutlet weak var ribbonForClose: UIView!
    @IBOutlet weak var ribbonForOpen: UIView!
    @IBOutlet weak var title: UILabel!

    @IBOutlet weak var detailBtn: UIButton!
    @IBOutlet weak var closeDetailBtn: UIButton!
    
    @IBOutlet weak var addFavoriteBtn: UIButton!
    @IBOutlet weak var cloudBtn: UIButton!
    weak var tableView:UITableView?
    weak var article:Article?
    
    var ribbonColor:UIColor = UIColor.clear{
        didSet{
            ribbonForClose.backgroundColor = ribbonColor
            ribbonForOpen.backgroundColor = ribbonColor
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cornerLevel:CGFloat = 8
        // close
        let foreLayer = self.foregroundView.layer
        foreLayer.cornerRadius = cornerLevel
//        foreLayer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
//        foreLayer.borderWidth = 1
        
        // containerView has already set masksToBounds to true
        foreLayer.masksToBounds = true
//        foreLayer.shadowOffset = CGSize(width: 0, height: 0)
//        foreLayer.shadowRadius = 1
//        foreLayer.shadowOpacity = 0.5

        // open
        let containerLayer = self.containerView.layer
        containerLayer.cornerRadius = cornerLevel
//        containerLayer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
//        containerLayer.borderWidth = 1
        
        
        // back
        self.backViewColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        // icon
//        iconBg.layer.cornerRadius = iconBg.layer.frame.width / 2
//        iconBg.layer.borderColor = UIColor.gray.cgColor
//        iconBg.layer.borderWidth = 1.0
        
        
        
        
        
        setup()
    }
    
    func setup(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(onShowDetail(tap:)))
        detailBtn.addGestureRecognizer(tap)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(onShowDetail(tap:)))
        closeDetailBtn.transform = CGAffineTransform(scaleX: 1, y: -1)
        closeDetailBtn.addGestureRecognizer(tap2)
        
        cloudBtn.addTarget(self, action: #selector(onCloudBtnClicked(sender:)), for: .touchUpInside)
        
    }
    
    func onCloudBtnClicked(sender:UIButton){
        
    }
    
    func onShowDetail(tap:UITapGestureRecognizer){
        if let tableView = tableView{
            tableView.delegate?.tableView!(tableView, accessoryButtonTappedForRowWith: tableView.indexPath(for: self)!)
        }
    }
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
        
    }
}
