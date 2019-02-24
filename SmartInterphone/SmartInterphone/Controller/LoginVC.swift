//
//  ViewController.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/7/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Kingfisher

class LoginVC: UIViewController {
  
    
    
    @IBOutlet weak var passwordTxt: HomeCustomTextField!
    @IBOutlet weak var emailTxt: HomeCustomTextField!
    
    @IBOutlet weak var testImg: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }


    @IBAction func SignInClicked(_ sender: Any) {
        spinner.isHidden = false
        spinner.startAnimating()
        
        guard let email = emailTxt.text , emailTxt.text != "" else {
            makeAlert(message: "invalid email")
            return }
        guard let pass = passwordTxt.text , passwordTxt.text != "" else {
            makeAlert(message: "invalid password")
            return }
        
        AuthService.instance.loginUser(email: email, password: pass) { (success) in
            if success {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.performSegue(withIdentifier: LOGIN_TO_MENU, sender: nil)
            } else {
                // zid alerte hnés
                self.makeAlert(message: "invalid creditentials , please try again")
            }
        }
      
    }
    func ForgotPassword(alert: UIAlertAction!) {
        print("forgot password cool")
    }
    
    func setupView () {
        // hide spinner
        spinner.isHidden = true
        // enable exiting keyboard with tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.handleTap))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @IBAction func fbLoginClicked(_ sender: Any) {
            let fbloginManager =  FBSDKLoginManager()
        
        fbloginManager.logIn(withReadPermissions: ["public_profile" , "email"],from: self) {
            (result, error) in
            if let error = error {
                debugPrint("could not login facebook", error)
            } else if result!.isCancelled {
                print("cancelled facebook login")
            } else {
                print("login success")
                print (result?.token.tokenString)
               self.fetchProfile()
            }
            
        }
    }
    
    /*
    func getUserProfile(currentAccessToken : String) {
    let connection = FBSDKGraphRequestConnection()
        
        connection.add(FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email,first_name,last_name,picture.type(large),id"],
                                         accessToken : currentAccessToken , httpMethod: .GET )) {
                                            
        }
            
        
    } */
    
    func fetchProfile () {
        let parameters = ["fields": "email,first_name,last_name,picture.type(large),id"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler:  {
            (connection, result, error) in
            print("d5al 1")
            if error != nil {
                print ("erreur : ")
                print (error)
                return
            }
            print("t3ada")
            guard
                let result = result as? NSDictionary,
                let email = result["email"] as? String,
                let first_name = result["first_name"] as? String,
                let last_name = result["last_name"] as? String
                else {
                    print ("error fetching data")
                    return
            }
            print (first_name)
            print( last_name)
            print (email)
            guard
                let picture = result["picture"] as? NSDictionary,
                let data = picture["data"] as? NSDictionary,
                let url = data["url"] as? String
                else {
                    print("error image")
                    return
            }
            print (url)
            self.changeImage(url: url)
            
    })
    }
    func changeImage (url:String) {
        let url = URL(string: url)
        let processor = DownsamplingImageProcessor(size: testImg.frame.size)
            >> RoundCornerImageProcessor(cornerRadius: 20)
        testImg.kf.indicatorType = .activity
        testImg.kf.setImage(
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
    
    
    func makeAlert( message: String ) {
        let alert = UIAlertController(title: "Alert !", message: message, preferredStyle: .alert)
        let backButton = UIAlertAction (title: "Okay", style: .cancel, handler: nil)
        alert.addAction(backButton)
        self.present(alert,animated: true, completion: nil)
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
        
    }
    
    
	
}


