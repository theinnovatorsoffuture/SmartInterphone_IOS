//
//  ViewController.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/7/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    
    @IBOutlet weak var passwordTxt: HomeCustomTextField!
    @IBOutlet weak var emailTxt: HomeCustomTextField!

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
    
    func makeAlert( message: String ) {
        let alert = UIAlertController(title: "Alert !", message: message, preferredStyle: .alert)
        let backButton = UIAlertAction (title: "Okay", style: .cancel, handler: nil)
        alert.addAction(backButton)
        self.present(alert,animated: true, completion: nil)
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
        
    }
    
    
	
}


