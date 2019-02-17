//
//  RegisterVCViewController.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/7/19.
//  Copyright © 2019 iof. All rights reserved.
//
import Alamofire
import UIKit

class RegisterVC: UIViewController {

//outlets
    @IBOutlet weak var famNameTxt: UITextField!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repPasswordTxt: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupView()
    }

    

    @IBAction func registerOnClick(_ sender: Any) {
        
           spinner.isHidden = false
            spinner.startAnimating()
        guard let username = usernameTxt.text , usernameTxt.text != "" else {
            makeAlert(message: "invalid username")
            return}
        guard let email = emailTxt.text , emailTxt.text != "" else {
            makeAlert(message: "invalid email")
            return}
        guard let passwd = passwordTxt.text , passwordTxt.text != "" else {
            makeAlert(message: "invalid password")
            return}
        guard let repPasswd = repPasswordTxt.text , repPasswordTxt.text != "" else {
            makeAlert(message: "invalid repeated password")
            return}
        guard let name = nameTxt.text , nameTxt.text != "" else {
            makeAlert(message: "invalid name")
            return}
        guard let famName = famNameTxt.text , famNameTxt.text != "" else {
            makeAlert(message: "invalid family name")
            return}
        let fullname = famName + " " + name
        let isEqual = (passwd == repPasswd)
        if !isEqual {
            makeAlert(message: "passwords do not match")
            return}
        AuthService.instance.registerUser(email: email, password: passwd, name: fullname, username: username) { (success) in
            if success {
                AuthService.instance.loginUser(email: username, password: passwd, completion: {
                    (success) in
                    if success {
                        print ("logged in new user!")
                        self.spinner.isHidden = true
                        self.spinner.stopAnimating()
                        self.performSegue(withIdentifier: REGISTER_TO_MENU, sender: nil)
                    }else {
                        // login failed zid alerte hné
                        self.makeAlert(message: "something went wrong , your account has been registrated please try to login again")
                    
                    }
                })
            }else {
                // registration failed
               self.makeAlert(message: "user already exists")
            }
          
            
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        performSegue(withIdentifier: REGISTER_TO_LOGIN, sender: nil)
        
    }
    func setupView () {
        // hide spinner
        spinner.isHidden = true
        spinner.stopAnimating()
        // enable exiting keyboard with tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterVC.handleTap))
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
