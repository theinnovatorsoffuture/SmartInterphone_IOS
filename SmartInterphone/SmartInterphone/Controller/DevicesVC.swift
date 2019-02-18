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
    
    private(set) public var devices = [Device]()

    override func viewDidLoad() {
        super.viewDidLoad()
        initDevices()
        deviceCollection.dataSource = self
        deviceCollection.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceCell", for: indexPath) as? DeviceCell {
            let device = devices[indexPath.row]
            cell.updateViews(device: device, index: indexPath.row)

        
            cell.addMessageButton.addTarget(self, action: #selector(MessageButtonTapped), for: .touchUpInside)
          
            cell.settingsButton.addTarget(self, action: #selector(SettingsButtonTapped), for: .touchUpInside)
            
            cell.infoButton.addTarget(self, action: #selector(InfoButtonTapped), for: .touchUpInside)
            
            return cell
        }
        
        return DeviceCell()
        
    }
    
    func initDevices () {
        self.devices = DevicesService.instance.getDevices()
    }
  
    @IBAction func MessageButtonTapped(_ sender: UIButton ) {
        makeAlert(message: "adding message for : \(devices[sender.tag].name)")
    }
    @IBAction func SettingsButtonTapped(_ sender: UIButton ) {
        makeAlert(message: "settings for : \(devices[sender.tag].name)")
    }
    @IBAction func InfoButtonTapped(_ sender: UIButton ) {
        makeAlert(message: "info for : \(devices[sender.tag].name)")
    }
    func makeAlert( message: String ) {
        let alert = UIAlertController(title: "Alert !", message: message, preferredStyle: .alert)
        let backButton = UIAlertAction (title: "Okay", style: .cancel, handler: nil)
        alert.addAction(backButton)
        self.present(alert,animated: true, completion: nil)
    }
}
