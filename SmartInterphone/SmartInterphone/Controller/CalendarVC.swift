//
//  CalendarVC.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 3/2/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var deviceCollection : UICollectionView!
    @IBOutlet weak var messageTable : UITableView!
    private(set) public var devices = [Device]()
    private(set) public var allMessages = [Message]()
    private(set) public var selectedMessages = [Message]()
    private(set) public var displayedMessages = [Message]()
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "y-MM-dd'T'H:mm:ss.SSS'Z'"
        setupCalendar()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
             initDevices(reload: true)
    }
    func setupCalendar() {
        
        if UIDevice.current.model.hasPrefix("iPad") {
            calendar.heightAnchor.constraint(equalToConstant: 400)
        }
    }
        
    @objc func reloadMessages() {
        let oldItems = self.displayedMessages
        let items = DevicesService.selectedDevice?.messages
        let changes = diff(old: oldItems, new: items!)
            self.messageTable.reload(changes: changes, updateData: {
                self.displayedMessages = (DevicesService.selectedDevice?.messages)!
            })
    }
    /*
    @objc func reloadCalendar() {
        let oldItems = self.selectedMessages
        let items = DevicesService.selectedDevice!.messages
        let changes = diff(old: oldItems, new: items)
        self.calendar.reload(changes: changes, updateData: {
            self.displayedMessages = (DevicesService.selectedDevice?.messages)!
        })
    }
     */
    
    @objc func reloadDevices() {
        let oldItems = self.devices
        let items = DevicesService.devices
        let changes = diff(old: oldItems, new: items)
        self.deviceCollection.reload(changes: changes, updateData: {
            self.devices = DevicesService.devices
        })
    }
    
    
    func initDevices (reload:Bool) {
        if (DevicesService.devices.count == 0 || DevicesService.devices.count != self.devices.count ) {
        DevicesService.instance.getDevices(){ (success) in
            if success {
                print ("in init devices callendar")
                print(DevicesService.devices.count)
                if reload {
                    self.reloadDevices()
                }
            } else {
                print("not ok")
            }
        }
        }
        else {
            self.devices = DevicesService.devices
        }
    }
    
    // unused , needs update
    func reloadAllMessages() {
        
        DevicesService.instance.getMessagesForUserDevices() { (success) in
            if success {
                self.allMessages = DevicesService.messages
                self.selectedMessages = self.allMessages
                self.calendar.reloadData()
                debugPrint(self.allMessages.count)
                 DevicesService.messages.removeAll()
                    debugPrint(self.allMessages.count)
            }
            else {
                print ("error getting all messages")
            }
        }
    }
}
extension CalendarVC : FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var count: Int = 0
        selectedMessages.forEach { message in
            var startDate = formatter.date(from: message.displayedAt)
            var endDate = formatter.date(from: message.hiddenAt)
            startDate = startDate?.stripTime()
            endDate = endDate?.stripTime()
            if (startDate != nil && endDate != nil) {
            if (date.isBetween(startDate! , and: endDate!)) {
                count = count + 1
                }
                
            }
        }
         return count
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if (deviceCollection.indexPathsForSelectedItems != nil){
               if (deviceCollection.indexPathsForSelectedItems!.count > 0){
        DevicesService.instance.getDeviceMessagesForDate(device: devices[(deviceCollection.indexPathsForSelectedItems?[0].row)!], date: date) {
            (success) in
            if success {
                 self.reloadMessages()
            }
            else {
                print ("error getting messages for this date")
            }
        }
        }
        }
    
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
}

extension CalendarVC : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
            return devices.count
            
     
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deviceCallendarCell", for: indexPath) as? DeviceCalendarCell
        cell?.title.text = devices[indexPath.row].name
        return cell!
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? DeviceCalendarCell
            cell?.background.layer.borderColor = UIColor(red:0.96, green:0.40, blue:0.38, alpha:1.0).cgColor
        
        DevicesService.instance.getDeviceMessages(device: devices[indexPath.row]) { success in
            if success {
                self.selectedMessages = DevicesService.selectedDevice!.messages
                    self.calendar.reloadData()
            } else {
                print ("error fetching device messages")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? DeviceCalendarCell
        cell?.background.layer.borderColor = UIColor.white.cgColor
            cell?.isSelected = false
        
      
    }
    
    
}
extension CalendarVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return displayedMessages.count
        }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageTableCell
            cell?.device.text = displayedMessages[indexPath.row].deviceName
            cell?.message.text = displayedMessages[indexPath.row].text
            let startDate = formatter.date(from: displayedMessages[indexPath.row].displayedAt)
            let endDate = formatter.date(from: displayedMessages[indexPath.row].hiddenAt)
            cell?.time.text = "\(startDate!.format(with: "HH:mm")) - \( endDate!.format(with: "HH:mm"))"
            return cell!
       
    }
}

extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)) ~= self
    }
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }

}
