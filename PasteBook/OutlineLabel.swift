//
//  OutlineLabel.swift
//  PasteBook
//
//  Created by Baoli.Zhai on 07/12/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

class OutlineLabel:UILabel{
    var fillColor:UIColor?{
        didSet{
            self.setNeedsDisplay()
        }
    }
    var lineWidth:CGFloat = 1 {
        didSet{
            self.setNeedsDisplay()
        }
    }
    override func drawText(in rect: CGRect) {
        let shadowOffset = self.shadowOffset
        let textColor = self.textColor
        if let c = UIGraphicsGetCurrentContext(){
            c.setLineWidth(lineWidth)
            c.setLineJoin(.miter)
            c.setTextDrawingMode(.fill)
            self.textColor = fillColor ?? .clear
            super.drawText(in: rect)
            
            c.setTextDrawingMode(.stroke)
            self.textColor = textColor
            self.shadowOffset = shadowOffset
            super.drawText(in: rect)
        }
        
    }
    
}
