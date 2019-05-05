   //
   //  StartVC.swift
   //  SelfTherapy
   //
   //  Created by Ladjemi Kais on 4/19/19.
   //  Copyright © 2019 esprit.tn. All rights reserved.
   //
   
   import UIKit
   import TransitionableTab


class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
     self.delegate = self
        // Do any additional setup after loading the view.
    }
}

   extension UITabBarController: TransitionableTab {
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return animateTransition(tabBarController, shouldSelect: viewController)
    }
   }
