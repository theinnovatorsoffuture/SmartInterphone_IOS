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
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUserInfo()
    }

    @IBAction func LogoutClicked(_ sender: Any) {
        AuthService.instance.logoutUser()
        print ("logged out check")
        debugPrint(AuthService.instance.userEmail)
        performSegue(withIdentifier: MENU_TO_REGISTER, sender: nil)
    }
    
    func setupUserInfo () {
        if AuthService.instance.isLoggedIn {
            
            // setup everything here
            usernamelabel.text = AuthService.instance.userEmail
        }
        else {
           // not gonna use this
        }
    }


}

