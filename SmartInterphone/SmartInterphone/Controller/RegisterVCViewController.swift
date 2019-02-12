//
//  RegisterVCViewController.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/7/19.
//  Copyright © 2019 iof. All rights reserved.
//
import Alamofire
import UIKit

class RegisterVCViewController: UIViewController {

    //Defined a constant that holds the URL for our web service
    let URL_USER_REGISTER = "http://192.168.174.1/TIOF/register.php"
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var email: HomeCustomTextField!
    @IBOutlet weak var password: HomeCustomTextField!
    @IBOutlet weak var passwordRepeat: HomeCustomTextField!
    @IBOutlet weak var username: HomeCustomTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    

    @IBAction func registerOnClick(_ sender: Any) {
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "username":username.text!,
            "password":password.text!,
            "email":email.text!,
        ]
        
        //Sending http post request
        Alamofire.request(URL_USER_REGISTER, method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
                if let result = response.result.value {
                    
                    //converting it as NSDictionary
                    let jsonData = result as! NSDictionary
                    
                    //displaying the message in label
                    self.messageLabel.text = jsonData.value(forKey: "message") as! String?
                    if jsonData.value(forKey: "error") as! Int? == 0 {
                         _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            
        }
        
    }
}
