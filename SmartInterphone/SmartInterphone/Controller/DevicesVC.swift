//
//  DevicesVC.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/17/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit
import Instructions
import CoreData

class DevicesVC: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource,CoachMarksControllerDelegate  {
    
    @IBOutlet weak var deviceCollection: UICollectionView!
    @IBOutlet weak var deviceCodeTxt: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    //variables
    @IBOutlet weak var refreshBtn: UIButton!
    
    private(set) public var devicesC = [Device]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var coachMarksController = CoachMarksController()
    let txts = ["Here is your device!","If you want to go into the schedule view tap here" , "Here you can add a message" , "If you expect a new device to be added, Tap here to refresh"]
    let nextButtonText = ["Nice","Okay", "Got it" , "Good"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onboardingSetup() 
         NotificationCenter.default.addObserver(self, selector: #selector(
          DevicesVC.devicesDataDidChange(_:)), name: NOTIF_DEVICES_ADDED , object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coachMarksController.stop(immediately: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        setupView()
        initDevices(reload: true, scrolltolast: false)
    }
    
    func startInstructions() {
        coachMarksController.start(in: .window(over: self))
    }
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController,
                                at index: Int) -> Bool {
        return true
    }
    
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
                return firstUse.firstUseDevices
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
    public func updateCoreData() {
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
                    firstUse.firstUseDevices = false
                    firstUse.firstUseProfile = false
                    try context.save()
                    print ("save succeded")
                } catch {
                    print("error saving")
                }
            } else {
                do {
                    let userdata = Result[0] as! FirstUse
                    userdata.firstUseDevices = false
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devicesC.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceCell", for: indexPath) as? DeviceCell {
            let device = devicesC[indexPath.row]
            cell.updateViews(device: device, index: indexPath.row)

   
            cell.addMessageButton.addTarget(self, action: #selector(MessageButtonTapped), for: .touchUpInside)
          
            cell.settingsButton.addTarget(self, action: #selector(SettingsButtonTapped), for: .touchUpInside)
            
            cell.infoButton.addTarget(self, action: #selector(InfoButtonTapped), for: .touchUpInside)
            
            return cell
        }
        
        return DeviceCell()
        
    }
    
    func initDevices (reload:Bool , scrolltolast : Bool) {
        spinner.isHidden = false
        spinner.startAnimating()
         DevicesService.instance.getDevices(){ (success) in
            if success {
                    print ("in init devices")
                   print(DevicesService.devices.count)
                if reload { self.reload()
                }
                if scrolltolast{
                    let lastSectionIndex = self.deviceCollection!.numberOfSections - 1
                    let lastRowIndex = self.deviceCollection!.numberOfItems(inSection: lastSectionIndex) - 1
                    let pathToLastRow = NSIndexPath(row: lastRowIndex, section: lastSectionIndex)

                    self.deviceCollection.scrollToItem(at: pathToLastRow as IndexPath, at: .bottom, animated: true)
                }
                // start instructions
                if (DevicesService.devices.count>0 && self.isFirstUse()){
                    self.startInstructions()
                }
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.spinner.setNeedsDisplay()
            } else {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.spinner.setNeedsDisplay()
                print("not ok")
            }
            
        }
    }
  
    @IBAction func addDeviceClicked(_ sender: Any) {
        spinner.isHidden = false
        spinner.startAnimating()
        guard let deviceCode = deviceCodeTxt.text , deviceCodeTxt.text != "" else { return }
        DevicesService.instance.addDevice(code: deviceCode){ (success) in
            if success {
                // NotificationCenter.default.post(name: NOTIF_DEVICES_DATA_DID_CHANGE, object: nil)
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                print(DevicesService.devices.count)
                self.initDevices(reload: true, scrolltolast: true)
          
                print("added device")
              	
                
            } else {
                print("can't add device")
                
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.spinner.setNeedsDisplay()
                self.makeAlert(message: "this code is wrong , try again")
            }
            
        }
    }
  
    @IBAction func refreshClicked(_ sender: Any) {
          initDevices(reload: true, scrolltolast: true)
    }
    
    @IBAction func MessageButtonTapped(_ sender: UIButton ) {
        let addmessageview = AddMessageView()
        addmessageview.modalPresentationStyle = .custom
        addmessageview.device = devicesC[sender.tag]
        addmessageview.modalTransitionStyle = .crossDissolve
        present(addmessageview, animated: true , completion: nil)
        
    }
    @IBAction func SettingsButtonTapped(_ sender: UIButton ) {
        makeAlert(message: "settings for : \(devicesC[sender.tag].name)")
    }
    
    // schedule
    @IBAction func InfoButtonTapped(_ sender: UIButton ) {
        let scheduleView = ScheduleController()
        print("enter")
       DevicesService.instance.getDeviceMessages(device: self.devicesC[sender.tag]){ (success) in
            if success {
                      print("enter2")
                scheduleView.device = DevicesService.selectedDevice
                let navEditorViewController: UINavigationController = UINavigationController(rootViewController: scheduleView)
                navEditorViewController.modalTransitionStyle = .crossDissolve
 
                self.present(navEditorViewController, animated: true, completion: nil)
               
            } else {
                      print("error")
                // zid alerte hnés
                self.makeAlert(message: "error")
            }
        }
  
       
        
        
    }
    func makeAlert( message: String ) {
        let alert = UIAlertController(title: "Alert !", message: message, preferredStyle: .alert)
        let backButton = UIAlertAction (title: "Okay", style: .cancel, handler: nil)
        alert.addAction(backButton)
        self.present(alert,animated: true, completion: nil)
    }
    @objc func handleTap() {
        view.endEditing(true)
    }
    func setupView () {
        // enable exiting keyboard with tap
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DevicesVC.handleTap))
        view.addGestureRecognizer(tap)
 
    }
    @objc func devicesDataDidChange(_ notif: Notification) {
        initDevices(reload : true,scrolltolast: true )
    }
    @objc func reload() {
        let oldItems = self.devicesC
        let items = DevicesService.devices
        let changes = diff(old: oldItems, new: items)
        
        
        self.deviceCollection.reload(changes: changes, updateData: {
            self.devicesC = DevicesService.devices
        })
        
        
        
    }
    
 
    
}

