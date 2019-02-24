//
//  DevicesVC.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/17/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class DevicesVC: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {

    
    
    @IBOutlet weak var deviceCollection: UICollectionView!
    
    private(set) public var devicesC = [Device]()

    @IBOutlet weak var deviceCodeTxt: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        deviceCollection.dataSource = self
        deviceCollection.delegate = self
         NotificationCenter.default.addObserver(self, selector: #selector(
            DevicesVC.devicesDataDidChange(_:)), name: NOTIF_DEVICES_ADDED , object: nil)
       
    }
    override func viewDidAppear(_ animated: Bool) {
        // self.tabBarController?.delegate = self
          initDevices(reload : true)
    }
    override func viewWillAppear(_ animated: Bool) {
        
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
    
    func initDevices (reload:Bool) {
         DevicesService.instance.getDevices(){ (success) in
            if success {
                 self.devicesC = DevicesService.devices
                print ("in init devices")
                   print(DevicesService.devices.count)
                if reload {
                    self.deviceCollection.reloadData() }
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
            } else {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
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
       
                print(DevicesService.devices.count)
                self.initDevices(reload: true )
                self.devicesC = DevicesService.devices
                print("added device")
                
            } else {
                print("can't add device")
                
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.makeAlert(message: "this code is wrong , try again")
            }
            
        }
    }
  
    @IBAction func MessageButtonTapped(_ sender: UIButton ) {
        let addmessageview = AddMessageView()
        addmessageview.modalPresentationStyle = .custom
        addmessageview.device = devicesC[sender.tag]	
        present(addmessageview, animated: true , completion: nil)
        
    }
    @IBAction func SettingsButtonTapped(_ sender: UIButton ) {
        makeAlert(message: "settings for : \(devicesC[sender.tag].name)")
    }
    
    // schedule
    @IBAction func InfoButtonTapped(_ sender: UIButton ) {
        let scheduleView = ExampleController()
       DevicesService.instance.getDeviceMessages(device: self.devicesC[sender.tag]){ (success) in
            if success {
                scheduleView.device = DevicesService.selectedDevice
                let navEditorViewController: UINavigationController = UINavigationController(rootViewController: scheduleView)
                self.navigationController?.present(navEditorViewController, animated: true, completion: nil)
               
            } else {
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
        spinner.isHidden = false
        spinner.startAnimating()
        // enable exiting keyboard with tap
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DevicesVC.handleTap))
        view.addGestureRecognizer(tap)
 
    }
    @objc func devicesDataDidChange(_ notif: Notification) {
        initDevices(reload : true )
    }
    

    
}

