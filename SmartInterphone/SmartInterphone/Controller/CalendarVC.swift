//
//  CalendarVC.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 3/2/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit
import Instructions
import CoreData

class CalendarVC: UIViewController, CoachMarksControllerDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var deviceCollection : UICollectionView!
    @IBOutlet weak var messageTable : UITableView!
    private(set) public var devices = [Device]()
    private(set) public var allMessages = [Message]()
    private(set) public var selectedMessages = [Message]()
    private(set) public var displayedMessages = [Message]()
 
    public var updatePath : IndexPath?
    let formatter = DateFormatter()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var coachMarksController = CoachMarksController()
    let txts = ["Here is the calendar! The little dots below days represent messages to be displayed on those days.","Here are your Devices, Select a         device and the calendar will be    updated accordingly!" , "Messages will be displayed here! For now it is empty, To display     messages start by selecting a       Device, then a Date !"]
    let nextButtonText = ["Nice","Okay", "Got it"]
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "y-MM-dd'T'H:mm:ss.SSS'Z'"
        NotificationCenter.default.addObserver(self, selector: #selector(self.messageUpdateResponse(_:)), name: NOTIF_DEVICE_DATA_DID_CHANGE, object: nil)
         onboardingSetup()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
             initDevices(reload: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coachMarksController.stop(immediately: true)
    }
    
    fileprivate func onboardingSetup() {
        coachMarksController.delegate = self
        coachMarksController.animationDelegate = self
        coachMarksController.dataSource = self
        
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip", for: .normal)
        
        coachMarksController.skipView = skipView
    }
    
    func startInstructions() {
        coachMarksController.start(in: .window(over: self))
    }
    
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController,
                                at index: Int) -> Bool {
        return true
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
                    firstUse.firstUseCalendar = false
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
                    userdata.firstUseCalendar = false
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
                return firstUse.firstUseCalendar
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
    
    @objc func reloadMessages(for date: Date) {
        let oldItems = self.displayedMessages
        let items = DevicesService.instance.filterMsgsByDate(date:date , messages:  selectedMessages)
        let changes = diff(old: oldItems, new: items)
            self.messageTable.reload(changes: changes, updateData: {
                self.displayedMessages = items
            })
    }
    
    @objc func reloadAllUserMessages(for date: Date) {
        let oldItems = self.displayedMessages
        let items =  DevicesService.instance.filterMsgsByDate(date:date , messages:  selectedMessages)
        let changes = diff(old: oldItems, new: items)
        self.messageTable.reload(changes: changes, updateData: {
            self.displayedMessages = items
        })
    }

    
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
                if self.isFirstUse() {
                    self.startInstructions() }
            } else {
                print("not ok")
            }
        }
        }
        else {
            self.devices = DevicesService.devices
        }
    }
    func editMsg (device: Device , message : Message){
        let editmessageview = EditMessageView()
        editmessageview.modalPresentationStyle = .custom
        editmessageview.device =  device
        editmessageview.message = message
        editmessageview.modalTransitionStyle = .crossDissolve
        present(editmessageview, animated: false) {
            self.initDevices(reload: true)
     
        }
    }
    @objc func messageUpdateResponse(_ notif: Notification)  {
        print("notification update")
        if let updatedMsg = notif.userInfo?["message"] as? Message {
            print(updatedMsg)
            if (updatePath != nil){
                var paths = [IndexPath]()
                paths.append(updatePath!)
                displayedMessages[updatePath!.row] = updatedMsg
                print (displayedMessages[updatePath!.row])
                self.messageTable.reloadRows(at: paths, with: .fade)
                
            }
   
        }
      
        }
    
    
   
}
extension CalendarVC : FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var count: Int = 0
        selectedMessages.forEach { message in
            var startDate = message.displayedAt.iso8601
            var endDate = message.hiddenAt.iso8601
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
                if (deviceCollection.indexPathsForSelectedItems?[0].row != 0) {
                    self.reloadMessages(for: date)
                }

                else {
                self.reloadAllUserMessages(for: date)
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
            cell?.title.adjustsFontSizeToFitWidth = true
        if (devices.count > 0) {
          cell?.title.text = devices[indexPath.row].name
        }
        
        return cell!
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? DeviceCalendarCell
            cell?.background.layer.borderColor = UIColor(red:0.96, green:0.40, blue:0.38, alpha:1.0).cgColor
          cell?.background.backgroundColor = UIColor(red:0.96, green:0.40, blue:0.38, alpha:0.3)
          cell?.setNeedsDisplay()
 
        DevicesService.instance.getDeviceMessages(device: devices[indexPath.row]) { success in
            if success {
                self.selectedMessages = DevicesService.selectedDevice!.messages
                self.calendar.reloadData()
                self.calendar.setNeedsDisplay()
            } else {
                print ("error fetching device messages")
            }
          }
    }

 
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? DeviceCalendarCell
        cell?.background.layer.borderColor = UIColor.white.cgColor
         cell?.background.backgroundColor =  UIColor.white
            cell?.isSelected = false
        
      
    }
    
    
}
extension CalendarVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return displayedMessages.count
        }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageTableCell
            cell?.message.text = displayedMessages[indexPath.row].text
            let startDate = displayedMessages[indexPath.row].displayedAt.iso8601!
            let endDate = displayedMessages[indexPath.row].hiddenAt.iso8601!
            let components = Calendar.current.dateComponents([ .day ,.hour], from: startDate, to: endDate)
            print(components.day!)
        if (components.day! > 0) {
               cell?.time.adjustsFontSizeToFitWidth = true
              cell?.time.text = "\(startDate.format(with: "MM/dd, H a")) - \( endDate.format(with: "MM/dd, H a"))"
         
        } else {
            cell?.time.text = "\(startDate.format(with: "H:mm a")) - \( endDate.format(with: "H:mm a"))"
        }
        cell?.setNeedsDisplay()
            return cell!
       
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
     
            let editButton = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction,indexPath) in
                print("edit clicked")
                if (self.deviceCollection.indexPathsForSelectedItems != nil){
                    if (self.deviceCollection.indexPathsForSelectedItems!.count > 0){
                        
                            self.updatePath = indexPath
                            self.editMsg(device: self.devices[(self.deviceCollection.indexPathsForSelectedItems?[0].row)!			] , message: self.displayedMessages[indexPath.row])
                            
                    }
                }
                
            }
            editButton.backgroundColor = UIColor.orange
            let deleteButton = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction,indexPath) in
                print("delete clicked")
                var indexs = [IndexPath]()
                indexs.append(indexPath)
                DevicesService.instance.DeleteMessage(message:  self.displayedMessages[indexPath.row], completion: { (Bool) in
                    DevicesService.instance.getDeviceMessages(device: self.devices[indexPath.row]) { success in
                        if success {
                            self.selectedMessages = DevicesService.selectedDevice!.messages
                            
                            self.calendar.reloadData()
                            self.calendar.setNeedsDisplay()
                        } else {
                            print ("error fetching device messages")
                        }
                    }
                })
                self.displayedMessages.remove(at: indexPath.row)
                self.messageTable.deleteRows(at: indexs, with: .fade)
                
            }
            deleteButton.backgroundColor = UIColor(red: 245/255, green: 102/255, blue: 97/255, alpha: 1)
                    return [deleteButton, editButton]
        

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
