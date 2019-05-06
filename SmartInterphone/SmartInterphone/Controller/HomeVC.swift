//
//  HomeVC.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/11/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit
import Kingfisher
import Instructions
import CoreData

class HomeVC: UIViewController,CoachMarksControllerDelegate  {
   

    @IBOutlet weak var usernameTxt: UILabel!
    @IBOutlet weak var emailTxt: UILabel!
    
    @IBOutlet weak var userImg: ProfilePictureImage!
    @IBOutlet weak var usernamelabel: UILabel!
    @IBOutlet weak var logoutBtn: RoundedButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //variables
    var coachMarksController = CoachMarksController()
    
    let txts = ["That's your profile picture. You look gorgeous!","If you want to logout, Here is the place!", "Thanks"]
    let nextButtonText = ["Nice","Okay", "Got it", "Thanks"]
    
    fileprivate func onboardingSetup() {
        coachMarksController.delegate = self
        coachMarksController.animationDelegate = self
        coachMarksController.dataSource = self
        
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip", for: .normal)
        
        coachMarksController.skipView = skipView
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        updateCoreData()
    }
    func isFirstUse() -> Bool {
        let email = AuthService.instance.userEmail
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FirstUse")
        fetchRequest.predicate = NSPredicate(format: "email == %@",email)
        do{
            let Result = try context.fetch(fetchRequest)
            if Result.count > 0 {
              
                    let firstUse = Result[0] as! FirstUse
              return firstUse.firstUseProfile
            } else {
                return true
            }
        }
        catch {
            print("error saving")
        }
        print ("couldnt fetch results core data is first use")
        return false
    }
    
    func updateCoreData() {
        let email = AuthService.instance.userEmail
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
                    firstUse.firstUseProfile = false
                    try context.save()
                    print ("save succeded")
                } catch {
                    print("error saving")
                }
            } else {
                  do {
                let userdata = Result[0] as! FirstUse
                userdata.firstUseProfile = false
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
         coachMarksController.overlay.allowTap = true
        setupUserInfo()
        onboardingSetup()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstUse() {
            startInstructions() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coachMarksController.stop(immediately: true)
    }

    
    func startInstructions() {
        coachMarksController.start(in: .window(over: self))
    }
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController,
                                at index: Int) -> Bool {
        return true
    }
    
    @IBAction func EditButtonClicked(_ sender: Any) {}
    
    @IBAction func logoutClicked(_ sender: Any) {
        AuthService.instance.logoutUser()
        performSegue(withIdentifier: MENU_TO_REGISTER, sender: nil)
    }
    
    func setupUserInfo () {
        if AuthService.instance.isLoggedIn {
            
            // setup everything here
              self.changeImage(url: AuthService.instance.imageUrl)
            usernamelabel.text = AuthService.instance.userFullName
            usernameTxt.text  = AuthService.instance.username
            emailTxt.text = AuthService.instance.userEmail
        }
        else {
           debugPrint(AuthService.instance.userEmail)
        }
    }
    
    func changeImage (url:String) {
        let url = URL(string: url)
        let processor = DownsamplingImageProcessor(size: userImg.frame.size)
        
        userImg.kf.indicatorType = .activity
        userImg.kf.setImage(
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


}


