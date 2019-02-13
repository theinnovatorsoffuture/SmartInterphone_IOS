//
//  RoundedButton.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/12/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit


@IBDesignable
class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.setupView()
        }
    }

    
    override func awakeFromNib() {
        self.setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = cornerRadius
    }
}
