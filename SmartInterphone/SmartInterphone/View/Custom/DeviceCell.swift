//
//  DeviceCellCollectionViewCell.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/17/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class DeviceCell: UICollectionViewCell {
    @IBOutlet weak var deviceLabel : UILabel!
    @IBOutlet weak var addMessageButton : UIButton!
    @IBOutlet weak var settingsButton : UIButton!
    @IBOutlet weak var infoButton : UIButton!
   
    
    func updateViews (device : Device , index : Int) {
        deviceLabel.text = device.name
        
        addMessageButton.tag = index
        settingsButton.tag = index
        infoButton.tag = index
    }
    
    
 
    
}
