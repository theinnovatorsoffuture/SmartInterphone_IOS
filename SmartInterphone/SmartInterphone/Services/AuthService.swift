//
//  AuthService.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/15/19.
//  Copyright © 2019 iof. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class AuthService {
    static let instance = AuthService()
    let defaults = UserDefaults.standard
    
    var isLoggedIn : Bool {
        get {
            return defaults.bool(forKey: LOGGED_IN_KEY)
        }
        set {
            defaults.set(newValue, forKey: LOGGED_IN_KEY)
        }
    }
    
    var userEmail: String {
        get {
            return defaults.value(forKey: USER_EMAIL) as! String
        }
        set {
            defaults.set(newValue, forKey: USER_EMAIL)
        }
    }
    var userFullName: String {
        get {
            return defaults.value(forKey: USER_FULLNAME) as! String
        }
        set {
            defaults.set(newValue, forKey: USER_FULLNAME)
        }
    }
    
    var username: String {
        get {
            return defaults.value(forKey: USER_NAME) as! String
        }
        set {
            defaults.set(newValue, forKey: USER_NAME)
        }
    }
    
    
    var authToken: String {
        get {
            return defaults.value(forKey: TOKEN_KEY) as! String
        }	
        set {
            defaults.set(newValue, forKey: TOKEN_KEY)
        }
    }
    var imageUrl: String  {
        get {
            return defaults.value(forKey: IMAGE_URL) as! String
        }
        set {
            return defaults.set(newValue , forKey: IMAGE_URL)
        }
    }
    
    func registerUser(email: String, password: String, name : String , username : String, imageUrl : String, completion: @escaping CompletionHandler) {
        
        let lowerCaseEmail = email.lowercased()
        
        let body: [String: Any] = [
            "email": lowerCaseEmail,
            "name": name,
            "username": username,
            "password": password,
           // "url": imageUrl,
        ]
        
        Alamofire.request(URL_REGISTER, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            
            if response.result.error == nil {
                  guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                      print (json)
                    if json["message"].stringValue != "User Registered Sucessfully !" {
                        completion(false)
                        return
                    }
                } catch {
                    completion(false)
                    print(error)
                }
                // EERROOOORRRRRR TALFI9
                self.imageUrl = imageUrl
                completion(true)
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping CompletionHandler) {
        
      
        
        let credentialData = "\(email):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let loginHeader = ["Authorization": "Basic \(base64Credentials)"]
        
        Alamofire.request(URL_LOGIN, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: loginHeader).responseJSON { (response) in
            
            if response.result.error == nil {
                guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                    print (json)
                    self.userFullName = json["message"]["name"].stringValue
                    self.username = json["message"]["username"].stringValue
                    self.userEmail = json["message"]["email"].stringValue
                    self.authToken = json["token"].stringValue
                    self.isLoggedIn = true
                    self.imageUrl = ""
                    if self.authToken == "" || self.userEmail == ""  {
                        completion(false)
                        return
                    }
                    completion(true)
                } catch {
                      completion(false)
                    print(error)
                }
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    
    func logoutUser () {
        userEmail = ""
        authToken = ""
        userFullName = ""
        username = ""
        imageUrl = ""
        isLoggedIn = false
        let fbloginManager =  FBSDKLoginManager()
        
        fbloginManager.logOut()
        GIDSignIn.sharedInstance().signOut()
    }
    
    
}
