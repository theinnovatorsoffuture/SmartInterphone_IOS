import UIKit
import CalendarKit
import DateToolsSwift

enum SelectedStyle {
  case Dark
  case Light
}

class ExampleController: DayViewController, DatePickerControllerDelegate {
    
    public var device : Device?
    var colors = [UIColor.blue,
                UIColor.yellow,
                UIColor.red]
    var currentStyle = SelectedStyle.Light
    let formatter = DateFormatter()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // nav setup


    configureButtons()
    dayView.autoScrollToFirstEvent = true
      navigationController?.navigationBar.isTranslucent = false	
    reloadData()

     NotificationCenter.default.addObserver(self, selector: #selector(ExampleController.deviceUpdate(_:)), name: NOTIF_DEVICE_DATA_DID_CHANGE, object: nil)
  }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }


    func configureButtons () {
        title = "Schedule for: \(device!.name)"
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "smackBack"), for: .normal)
        backBtn.setTitle("Back" , for: .normal)
        backBtn.addTarget(self, action :  #selector(ExampleController.backAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        let addMsgBtn = UIButton(type: .custom)
        addMsgBtn.setImage(UIImage(named: "newMessageIcon"), for: .normal)
        addMsgBtn.addTarget(self, action: #selector(ExampleController.addButtonAction) , for: .touchUpInside)
        let dateChangeBtn = UIButton(type: .custom)
        dateChangeBtn.setImage(UIImage(named: "changeDate"), for: .normal)
        dateChangeBtn.addTarget(self, action: #selector(ExampleController.presentDatePicker) , for: .touchUpInside)
        
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: addMsgBtn),UIBarButtonItem(customView:dateChangeBtn ) ]
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    @objc func backAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    @objc func addButtonAction(sender: UIButton!) {
        let addmessageview = AddMessageView()
        addmessageview.modalPresentationStyle = .custom
        addmessageview.device = self.device
        present(addmessageview, animated: false , completion: nil)
      
    }

    @objc func presentDatePicker() {
        let picker = DatePickerController()
        picker.date = dayView.state!.selectedDate
        picker.delegate = self
        let navC = UINavigationController(rootViewController: picker)
        navigationController?.present(navC, animated: true, completion: nil)
    }
    
    func datePicker(controller: DatePickerController, didSelect date: Date?) {
        if let date = date {
            dayView.state?.move(to: date)
        }
        controller.dismiss(animated: true, completion: nil)
    }



  // MARK: EventDataSource

    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let models = device!.messages
        
        var events = [Event]()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "y-MM-dd'T'H:mm:ss.SSS'Z'"
    
        for model in models {
            if( !events.contains(where: {$0.text == model.text})) {
            if (model.displayedAt != "" && model.hiddenAt != "") {
            // Create new EventView
            let event = Event()
            // Specify StartDate and EndDate
         
                event.userInfo = model
            event.startDate = formatter.date(from: model.displayedAt)!
            event.endDate = formatter.date(from: model.hiddenAt)!
             
            // Add info: event title, subtitle, location to the array of Strings
            var info = [model.text]
           info.append("\(event.startDate.format(with: "HH:mm")) - \(event.endDate.format(with: "HH:mm"))")
            // Set "text" value of event by formatting all the information needed for display
            event.text = info.reduce("", {$0 + $1 + "\n"})
            event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                events.append(event)
                
                }
                
            }
        }
        
        
        return events
    }
  
  private func textColorForEventInDarkTheme(baseColor: UIColor) -> UIColor {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return UIColor(hue: h, saturation: s * 0.3, brightness: b, alpha: a)
  }

  // MARK: DayViewDelegate

  override func dayViewDidSelectEventView(_ eventView: EventView) {
    guard let descriptor = eventView.descriptor as? Event else {
      return
    }
    let editmessageview = EditMessageView()
    editmessageview.modalPresentationStyle = .custom
    editmessageview.device = self.device
    editmessageview.message = descriptor.userInfo as? Message
    present(editmessageview, animated: false , completion: nil)
    
    }
    
     @objc func deviceUpdate(_ notif: Notification)  {
            print("notification update")
        print("before: ")
        let deviceBackup = self.device
        
                DevicesService.instance.getDeviceMessages(device: device!){ (success) in
                if success {
                    print("update success")
                    print(DevicesService.selectedDevice!.messages)
                    self.device! = DevicesService.selectedDevice!
                    self.reloadData()
                   self.dayView.state?.move(to: self.formatter.date(from: self.device!.messages.last!.displayedAt)!)
        
                } else {
                    self.device = deviceBackup
                    print("error")
                    
                }
                
            }
  
    }

  override func dayViewDidLongPressEventView(_ eventView: EventView) {
    guard let descriptor = eventView.descriptor as? Event else {
      return
    }
    print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
  }

  override func dayView(dayView: DayView, willMoveTo date: Date) {
    print("DayView = \(dayView) will move to: \(date)")
  }
  
  override func dayView(dayView: DayView, didMoveTo date: Date) {
    print("DayView = \(dayView) did move to: \(date)")
  }

}
