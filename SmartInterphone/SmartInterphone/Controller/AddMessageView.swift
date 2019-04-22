//
//  AddMessageView.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/18/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit

class AddMessageView: UIViewController {

    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var startTxt: UITextField!
    @IBOutlet weak var endTxt: UITextField!
    @IBOutlet weak var userTxt: UILabel!
    @IBOutlet weak var deviceTxt: UILabel!
    let datePicker = UIDatePicker()
    let datePicker2 = UIDatePicker()
    public var startDate : String?
    public var endDate : String?
    public var device : Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        endTxt.isEnabled = false
    }
    func setupView() {
        
        
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        datePicker2.datePickerMode = UIDatePicker.Mode.dateAndTime
           datePicker2.minimumDate = Date()
        datePicker2.addTarget(self, action: #selector(datePicker2ValueChanged(sender:)), for: UIControl.Event.valueChanged)
        startTxt.inputView = datePicker
        endTxt.inputView = datePicker2
        userTxt.text = AuthService.instance.username
        deviceTxt.text = device?.name
    }

    @objc func datePickerValueChanged (sender : UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = DateFormatter.Style.short
        startTxt.text = formatter.string(from: sender.date)
        // conversion
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        startDate = df.string(from: sender.date)
        print(df.string(from: sender.date))
        datePicker2.minimumDate = sender.date
        datePicker2.date = sender.date
        endTxt.isEnabled = true
    }
    @objc func datePicker2ValueChanged (sender : UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = DateFormatter.Style.short
        endTxt.text = formatter.string(from: sender.date)
        // conversion
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
          endDate = df.string(from: sender.date)
        print(df.string(from: sender.date))
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
      
        guard let messagetext = messageTxt.text , messageTxt.text != "" else {
            makeAlert(message: "type a message first!")
            return }
        if (startDate == nil || endDate == nil) {
             makeAlert(message: "please choose a valid date !")
            return
        }
        if (device == nil)  {
              makeAlert(message: "error")
            return
        }
        let message = Message(id: "s", text: messagetext, displayedAt: startDate!, hiddenAt: endDate!, deviceName: device!.name)
        DevicesService.instance.newMessage(device: device!, message: message) { (success) in
            if success {
                print("message added")
                NotificationCenter.default.post(name: NOTIF_DEVICE_DATA_DID_CHANGE, object: nil)
                self.dismiss(animated: false, completion: nil)
            } else {
                // zid alerte hnés
                self.makeAlert(message: "message not added , please try again")
            }
        }

        
    }
    @IBAction func exitButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    func makeAlert( message: String ) {
        let alert = UIAlertController(title: "Alert !", message: message, preferredStyle: .alert)
        let backButton = UIAlertAction (title: "Okay", style: .cancel, handler: nil)
        alert.addAction(backButton)
        self.present(alert,animated: true, completion: nil)
    }

}
