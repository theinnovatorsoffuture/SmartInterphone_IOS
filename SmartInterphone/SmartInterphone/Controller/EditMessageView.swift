//
//  EditMessageView.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/19/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class EditMessageView: UIViewController {

    @IBOutlet weak var deviceTxt: UILabel!
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var startTxt: UITextField!
    
    @IBOutlet weak var endTxt: UITextField!
    public var startDate : String?
    public var endDate : String?
      public var device : Device?
    public var message : Message?
    let datePicker = UIDatePicker()
    let datePicker2 = UIDatePicker()
    var edited2 : Bool = false
    var edited1 : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        // Do any additional setup after loading the view.
    }
    
    func setupView() {
        

        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        datePicker.minimumDate = Date()
        datePicker2.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker2.addTarget(self, action: #selector(datePicker2ValueChanged(sender:)), for: UIControl.Event.valueChanged)
        startTxt.inputView = datePicker
        endTxt.inputView = datePicker2
        deviceTxt.text = device?.name
        startTxt.text = formatDate(dateString: message!.displayedAt)
        endTxt.text = formatDate(dateString: message!.hiddenAt)
        messageTxt.text = message?.text
        
    }
    
    func formatDate(dateString:String) -> String {
        let formatter = DateFormatter()

        formatter.dateFormat = "y-MM-dd'T'H:mm:ss.SSS'Z'"
        let date : Date? = formatter.date(from: dateString)!
        formatter.dateFormat = "dd MMM yy' at: 'H:mm a"
        return formatter.string(from: date!)
    }
    @objc func datePickerValueChanged (sender : UIDatePicker) {
        edited1 = true
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = DateFormatter.Style.short
        startTxt.text = formatter.string(from: sender.date)
        // conversion

        startDate = sender.date.iso8601
    
        datePicker2.minimumDate = sender.date
        
    }
    @objc func datePicker2ValueChanged (sender : UIDatePicker) {
          edited2 = true
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = DateFormatter.Style.short
        endTxt.text = formatter.string(from: sender.date)
        // conversion
        endDate = sender.date.iso8601
        print(endDate)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @IBAction func exitButtonClicked(_ sender: Any) {
           dismiss(animated: true, completion: nil)
    }
    @IBAction func updateButton(_ sender: Any) {
        if (!edited1) {
            startDate =  message!.displayedAt.iso8601!.iso8601
        }
        
        if (!edited2) {
      
            endDate = message!.hiddenAt.iso8601!.iso8601
          
        }
        let updatedmessage = Message(id: message!.id,
                                     text: messageTxt.text!,
                                     displayedAt: startDate!, hiddenAt: endDate!, deviceName: "kais's device")
        
        
        print (updatedmessage)
        DevicesService.instance.EditMessage(message: updatedmessage, deviceId: device!.id){ (success) in
            if success {
                print("message added")
                var dict : Dictionary = Dictionary<AnyHashable,Any>()
                dict["device"] = self.device
                dict["message"] = updatedmessage
                NotificationCenter.default.post(name: NOTIF_DEVICE_DATA_DID_CHANGE, object: nil , userInfo: dict)
            } else {
                  print("error editing")
            }
        }
    }
    
    func makeAlert( message: String ) {
        let alert = UIAlertController(title: "Alert !", message: message, preferredStyle: .alert)
        let backButton = UIAlertAction (title: "Okay", style: .cancel, handler: nil)
        alert.addAction(backButton)
        self.present(alert,animated: true, completion: nil)
    }

}
