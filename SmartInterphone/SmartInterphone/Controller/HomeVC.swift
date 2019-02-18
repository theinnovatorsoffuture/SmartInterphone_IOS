//
//  HomeVC.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/11/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
   

    @IBOutlet weak var usernameTxt: UILabel!
    @IBOutlet weak var emailTxt: UILabel!

    @IBOutlet weak var usernamelabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInfo()
    }

    @IBAction func logoutClicked(_ sender: Any) {
        AuthService.instance.logoutUser()
        performSegue(withIdentifier: MENU_TO_REGISTER, sender: nil)
    }
    
    func setupUserInfo () {
        if AuthService.instance.isLoggedIn {
            
            // setup everything here
            usernamelabel.text = AuthService.instance.userFullName
            usernameTxt.text  = AuthService.instance.username
            emailTxt.text = AuthService.instance.userEmail
        }
        else {
           debugPrint(AuthService.instance.userEmail)
        }
    }


}

