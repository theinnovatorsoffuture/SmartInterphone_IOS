//
//  HomeVC.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/11/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
   

    @IBOutlet weak var usernamelabel: UILabel!
     var username:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        usernamelabel.text = username
    }
    


}

