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
    @IBOutlet weak var userTxt: UILabel!
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var startTxt: UITextField!
    
    @IBOutlet weak var endTxt: UITextField!
    public var startDate : String?
    public var endDate : String?
      public var device : Device?
    public var message : Message?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView() {
        
        let datePicker = UIDatePicker()
        let datePicker2 = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        datePicker2.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker2.addTarget(self, action: #selector(datePicker2ValueChanged(sender:)), for: UIControl.Event.valueChanged)
        startTxt.inputView = datePicker
        endTxt.inputView = datePicker2
        userTxt.text = AuthService.instance.username
        deviceTxt.text = device?.name
        startTxt.text = message?.displayedAt
        endTxt.text = message?.hiddenAt
        messageTxt.text = message?.text
        
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
    
    
    @IBAction func exitButtonClicked(_ sender: Any) {
           dismiss(animated: true, completion: nil)
    }
    @IBAction func updateButton(_ sender: Any) {
        let updatedmessage = Message(id: message!.id,
                                     text: messageTxt.text!,
                                     displayedAt: startDate!, hiddenAt: endDate!)
        DevicesService.instance.EditMessage(message: updatedmessage, deviceId: device!.id){ (success) in
            if success {
                print("message added")
                if let presenter = self.presentingViewController as? ExampleController {
                    if let fooOffset = presenter.device?.messages.index(where: {$0.id == self.message?.id}) {
                        presenter.device?.messages[fooOffset] = updatedmessage
                    }
                }
                self.dismiss(animated: false, completion: nil)
            } else {
                // zid alerte hnés
                self.makeAlert(message: "message not updated , please try again")
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
