//
//  profilePictureImage.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/17/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

@IBDesignable
class ProfilePictureImage: UIImageView {
    
    func change() {
        layer.borderWidth = 3.0
        layer.borderColor = UIColor.init(displayP3Red: 250, green: 199, blue: 197, alpha: 1).cgColor
        layer.cornerRadius = frame.size.height/2
        clipsToBounds = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        change()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        change()
    }
    
    
    
    
}
