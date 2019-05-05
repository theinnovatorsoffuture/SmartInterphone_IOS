//
//  RegisterVCViewController.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/7/19.
//  Copyright © 2019 iof. All rights reserved.
//
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Kingfisher
import GoogleSignIn
import CoreData

class RegisterVC: UIViewController ,GIDSignInUIDelegate {

//outlets
    @IBOutlet weak var famNameTxt: UITextField!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repPasswordTxt: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    //
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    public func addFirstUseCoreData(email: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FirstUse")
        fetchRequest.predicate = NSPredicate(format: "email == %@",email)
        do{
            let Result = try context.fetch(fetchRequest)
            if Result.count == 0 {
                do {
                    let firstUse = FirstUse(context: self.context)
                    firstUse.email = email
                    firstUse.firstUseCalendar = true
                    firstUse.firstUseDevices = true
                     firstUse.firstUseProfile = true
                    try context.save()
                    print ("save succeded")
                } catch {
                    print("error saving")
                }
            }
        }
        catch {
            print("error saving")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
  
        GIDSignIn.sharedInstance()?.uiDelegate = self
        setupView()
    }


    
    @IBAction func facebookSignupClicked(_ sender: Any) {
        
        let fbloginManager =  FBSDKLoginManager()
        
        fbloginManager.logIn(withReadPermissions: ["public_profile" , "email"],from: self) {
            (result, error) in
            if let error = error {
                debugPrint("could not login facebook", error)
            } else if result!.isCancelled {
                print("cancelled facebook login")
            } else {
                print("login success")
               
                self.fetchProfile()
            }
            
        }
    }
    func fetchProfile () {
        let parameters = ["fields": "email,first_name,last_name,picture.type(large),id"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler:  {
            (connection, result, error) in
            print("d5al 1")
            if error != nil {
                print ("erreur : ")
                print (error!)
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
            self.registerUser(email: email, password: "generatedPass", name: "\(last_name)", username: first_name, imageUrl: url)
            
        })
    }
    @IBAction func registerOnClick(_ sender: Any) {
        
           spinner.isHidden = false
            spinner.startAnimating()
        guard let username = usernameTxt.text , usernameTxt.text != "" else {
            makeAlert(message: "invalid username")
            return
        }
        guard let email = emailTxt.text , emailTxt.text != "" else {
            makeAlert(message: "invalid email")
            return
        }
        guard let passwd = passwordTxt.text , passwordTxt.text != "" else {
            makeAlert(message: "invalid password")
            return
        }
        guard let repPasswd = repPasswordTxt.text , repPasswordTxt.text != "" else {
            makeAlert(message: "invalid repeated password")
            return
        }
        
        guard let name = nameTxt.text , nameTxt.text != "" else {
            makeAlert(message: "invalid name")
            return
        }
        guard let famName = famNameTxt.text , famNameTxt.text != "" else {
            makeAlert(message: "invalid family name")
            return
        }
        let fullname = famName + " " + name
        let isEqual = (passwd == repPasswd)
        if !isEqual {
            makeAlert(message: "passwords do not match")
            return
        }
        
      registerUser(email: email, password: passwd, name: fullname, username: username, imageUrl: "")
    }
    
    func registerUser (email: String , password : String , name : String , username : String , imageUrl : String) {
           print ("sign in entered")
        AuthService.instance.registerUser(email: email, password: password, name: name, username: username , imageUrl: imageUrl) { (success) in
            if success {
             
                AuthService.instance.loginUser(email: username, password: password, completion: {
                    (success) in
                    if success {
                         self.addFirstUseCoreData(email: email)
                        print ("logged in new user!")
                        self.spinner.isHidden = true
                        self.spinner.stopAnimating()
                        self.performSegue(withIdentifier: REGISTER_TO_MENU, sender: nil)
                    }else {
                        self.spinner.isHidden = true
                        self.spinner.stopAnimating()
                        self.makeAlert(message: "something went wrong , please try again later 1")
                        
                    }
                })
            }else {
                // already registred
                AuthService.instance.loginUser(email: username, password: password, completion: {
                    (success) in
                    if success {
                       self.addFirstUseCoreData(email: email)
                        print ("logged in new user!")
                        self.spinner.isHidden = true
                        self.spinner.stopAnimating()
                        self.performSegue(withIdentifier: REGISTER_TO_MENU, sender: nil)
                    }else {
                        self.spinner.isHidden = true
                        self.spinner.stopAnimating()
                        self.makeAlert(message: "something went wrong , please try again later 2")
                        
                    }
                })
            }
            
            
        }
    }
    @IBAction func googleBtnClicked(_ sender: Any) {
        print("clicked google")
        GIDSignIn.sharedInstance()?.signIn()
    }
    @IBAction func backButtonClicked(_ sender: Any) {
        
        performSegue(withIdentifier: REGISTER_TO_LOGIN, sender: nil)
        
    }
    func setupView () {
        // hide spinner
        spinner.isHidden = true
        spinner.stopAnimating()
        // enable exiting keyboard with tap

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
