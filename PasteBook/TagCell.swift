//
//  TagCell.swift
//  PasteBook
//
//  Created by Baoli Zhai on 4/27/16.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

class TagCell: UITableViewCell {
    var ticked:Bool = false{
        didSet{
            self.accessoryType = ticked ? .Checkmark : .None
        }
    }
}
