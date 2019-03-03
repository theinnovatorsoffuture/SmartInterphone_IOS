//
//  tableDevice.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 3/2/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class DeviceCalendarCell: UICollectionViewCell {
    @IBOutlet weak var title : UILabel!
    @IBOutlet weak var background : UIView!
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
            self.background.layer.borderWidth = 3
        self.background.layer.borderColor = UIColor.white.cgColor
        self.background.layer.cornerRadius = 10
    }

}
