//
//  BorderButton.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/7/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class BorderButton: UIButton {
    
    func change() {
        layer.borderWidth = 3.0
        layer.borderColor = UIColor.white.cgColor
    }
    override func prepareForInterfaceBuilder() {
        change()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
       change()
    }
    
 
   

}
