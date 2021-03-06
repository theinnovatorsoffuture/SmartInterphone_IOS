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
import CoreData
import GoogleSignIn

class LoginVC: UIViewController , GIDSignInUIDelegate {
  
    @IBOutlet weak var passwordTxt: HomeCustomTextField!
    @IBOutlet weak var emailTxt: HomeCustomTextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        GIDSignIn.sharedInstance()?.uiDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
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
              self.addFirstUseCoreData(email: AuthService.instance.userEmail)
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.performSegue(withIdentifier: LOGIN_TO_MENU, sender: nil)
            } else {
                // zid alerte hnés
                self.makeAlert(message: "invalid creditentials , please try again")
            }
        }
      
    }
    // used for fb/google signin
    public func Signin(email: String , password : String , url : String) {
        print ("sign in entered")
        AuthService.instance.loginUser(email: email, password: password) { (success) in
            if success {
                self.addFirstUseCoreData(email: AuthService.instance.userEmail)
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                AuthService.instance.imageUrl = url
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
    }
 

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    @IBAction func googlLoginClicked(_ sender: Any) {
        print("clicked google")
        GIDSignIn.sharedInstance()?.signIn()
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
                print (result!.token.tokenString!)
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
            
            self.Signin(email: first_name, password: "generatedPass", url : url)
          
            
    })
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


