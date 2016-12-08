//
//  SeperatorLineView.swift
//  PasteBook
//
//  Created by Baoli.Zhai on 07/12/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

class SeperatorLineView: UIView {

    var color:UIColor = .lightGray
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x:rect.x,y:rect.y + rect.height/2))
        path.addLine(to: CGPoint(x:rect.x+rect.width, y:rect.y + rect.height/2))
        path.lineWidth = rect.height
        // the real pattern will be 4-2 (3+1 , 3-1), for the line width will offset the pattern
        let dashes: [CGFloat] = [path.lineWidth * 3, path.lineWidth * 3]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.square
        self.color.setStroke()
        path.stroke()
    }

}
