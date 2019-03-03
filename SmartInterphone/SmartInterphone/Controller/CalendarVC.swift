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
   @IBOutlet weak var deviceTable: UITableView!
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
    func initDevices (reload:Bool) {
        if DevicesService.devices.count == 0 {
        DevicesService.instance.getDevices(){ (success) in
            if success {
                self.devices = DevicesService.devices
                print ("in init devices callendar")
                print(DevicesService.devices.count)
                if reload { self.deviceTable.reloadData()
                    
                    self.deviceTable.setNeedsLayout()
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
       
        DevicesService.instance.getDeviceMessagesForDate(device: devices[(deviceTable.indexPathForSelectedRow?.row)!], date: date) {
            (success) in
            if success {
                self.displayedMessages = DevicesService.selectedDevice!.messages
                self.messageTable.reloadData()
            }
            else {
                print ("error getting messages for this date")
            }
        }
    
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
}
extension CalendarVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == deviceTable {
        
            return devices.count }
        else  {
            return displayedMessages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == deviceTable {
            
       let cell = tableView.dequeueReusableCell(withIdentifier: "tableDevice", for: indexPath) as? tableDevice
        cell?.title.text = devices[indexPath.row].name
            return cell!
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageTableCell
            cell?.device.text = displayedMessages[indexPath.row].deviceName
            cell?.message.text = displayedMessages[indexPath.row].text
            let startDate = formatter.date(from: displayedMessages[indexPath.row].displayedAt)
            let endDate = formatter.date(from: displayedMessages[indexPath.row].hiddenAt)
            cell?.time.text = "\(startDate!.format(with: "HH:mm")) - \( endDate!.format(with: "HH:mm"))"
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == deviceTable {
        let cell = tableView.cellForRow(at: indexPath) as? tableDevice
        cell?.isSelected = true
        tableView.setNeedsDisplay()
      
            DevicesService.instance.getDeviceMessages(device: devices[indexPath.row]) { success in
                if success {
                    self.selectedMessages = DevicesService.selectedDevice!.messages
                    self.calendar.reloadData()
                } else {
                    print ("error fetching device messages")
                }
            
        }
        }
        else
        {
            return
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView == deviceTable {
        let cell = tableView.cellForRow(at: indexPath) as? tableDevice
        cell?.isSelected = false
        }
        else
        {
        return
        }
        
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
