//
//  HomeVC.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/11/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit
import Kingfisher

class HomeVC: UIViewController {
   

    @IBOutlet weak var usernameTxt: UILabel!
    @IBOutlet weak var emailTxt: UILabel!
    
    @IBOutlet weak var userImg: ProfilePictureImage!
    @IBOutlet weak var usernamelabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInfo()
    }

    @IBAction func EditButtonClicked(_ sender: Any) {
        
     
        
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        AuthService.instance.logoutUser()
        performSegue(withIdentifier: MENU_TO_REGISTER, sender: nil)
    }
    
    func setupUserInfo () {
        if AuthService.instance.isLoggedIn {
            
            // setup everything here
              self.changeImage(url: AuthService.instance.imageUrl)
            usernamelabel.text = AuthService.instance.userFullName
            usernameTxt.text  = AuthService.instance.username
            emailTxt.text = AuthService.instance.userEmail
        }
        else {
           debugPrint(AuthService.instance.userEmail)
        }
    }
    
    func changeImage (url:String) {
        let url = URL(string: url)
        let processor = DownsamplingImageProcessor(size: userImg.frame.size)
        
        userImg.kf.indicatorType = .activity
        userImg.kf.setImage(
            with: url,
            placeholder: UIImage(named: "profile-placeholder"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }


}

