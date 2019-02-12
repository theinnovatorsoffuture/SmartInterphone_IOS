//
//  ViewController.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/7/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var password: HomeCustomTextField!
    @IBOutlet weak var email: HomeCustomTextField!
    var users : [User] = []
    var userString : String = ""
    
    struct User: Codable {
        let username : String
        let email : String
        let password : String
        init(username: String , password: String) {
            self.username = username
            self.password = password
            self.email = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
       self.users = Login()
    }


    @IBAction func SignInClicked(_ sender: Any) {
      
      
        for user in users  {
            print (user.email)
            print(user.password)
            if email.text! == user.username && password.text! == user.password {
                print("logged in")
                userString = user.username
                performSegue(withIdentifier: "LoginToHomeSeg", sender: self)
                return
            }
        }
            let alert = UIAlertController(title: "Login failed", message: "your username/email or password are not correct! please try again", preferredStyle: .alert)
            let backButton = UIAlertAction (title: "Okay", style: .cancel, handler: nil)
            alert.addAction(backButton)
            self.present(alert,animated: true, completion: nil)
            print ("user not found")
    }
    func ForgotPassword(alert: UIAlertAction!) {
        print("forgot password cool")
    }
    
    public func Login() ->  [User] {
        
        let url = URL(string: "http://192.168.174.1/login.php")
        URLSession.shared.dataTask(with: url! ,completionHandler: {(data , response , error) in
            guard let data = data , error == nil else {print (error!); return}
            
            let decoder = JSONDecoder()
            self.users = try! decoder.decode([User].self , from: data)
		
        }).resume()
	 return users
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let homeVC = segue.destination as? HomeVC {
            homeVC.username = userString
        }
    }
	
}


