//
//  AppDelegate.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/7/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , GIDSignInDelegate {

    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // facebook
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        // google
         GIDSignIn.sharedInstance()?.clientID = "387121122978-f71th4igf353hag1nr4ufht586qv0kuj.apps.googleusercontent.com"
         GIDSignIn.sharedInstance().delegate = self
        
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
       
        let returnFB = FBSDKApplicationDelegate.sharedInstance().application(app, open: url , options: options)
        let returnGoogle =  GIDSignIn.sharedInstance().handle(url as URL?,
                                                              sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                              annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        return returnFB || returnGoogle
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print ("google went here") 
        if let error = error {
          
            debugPrint("could not login with google :\(error.localizedDescription)")
            
        } else {
                print ("logged in with google")
        //   let userId = user.userID                  // For client-side use only!
       //     let idToken = user.authentication.idToken // Safe to send to the server
     //       let fullName = user.profile.name
    //        let givenName = user.profile.givenName
    //        let familyName = user.profile.familyName
            let email = user.profile.email
            let imageUrl = user.profile.imageURL(withDimension: 100)?.absoluteString
              print (email)
            print (imageUrl)
            guard let controller = GIDSignIn.sharedInstance()?.uiDelegate as? LoginVC else {
                return
            }
            controller.changeImage(url: imageUrl!)
          
                }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

