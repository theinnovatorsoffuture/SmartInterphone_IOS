import UIKit
import CalendarKit
import DateToolsSwift

enum SelectedStyle {
  case Dark
  case Light
}

class ScheduleController: DayViewController, DatePickerControllerDelegate {
    
    public var device : Device?
    var colors = [
                UIColor.yellow,
                UIColor.red]
    var currentStyle = SelectedStyle.Light
    let formatter = DateFormatter()
    var k: Int = 0
  override func viewDidLoad() {
    super.viewDidLoad()
    // nav setup


    configureButtons()
    dayView.autoScrollToFirstEvent = true
      navigationController?.navigationBar.isTranslucent = false	
    reloadData()

     NotificationCenter.default.addObserver(self, selector: #selector(ScheduleController.deviceUpdate(_:)), name: NOTIF_DEVICE_DATA_DID_CHANGE, object: nil)
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
        backBtn.addTarget(self, action :  #selector(ScheduleController.backAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        let addMsgBtn = UIButton(type: .custom)
        addMsgBtn.setImage(UIImage(named: "newMessageIcon"), for: .normal)
        addMsgBtn.addTarget(self, action: #selector(ScheduleController.addButtonAction) , for: .touchUpInside)
        let dateChangeBtn = UIButton(type: .custom)
        dateChangeBtn.setImage(UIImage(named: "changeDate"), for: .normal)
        dateChangeBtn.addTarget(self, action: #selector(ScheduleController.presentDatePicker) , for: .touchUpInside)
        
        
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
        addmessageview.modalTransitionStyle = .crossDissolve
        present(addmessageview, animated: true , completion: nil)
      
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
      	
        formatter.dateFormat = "y-MM-dd'T'H:mm:ss.SSS'Z'"
    
        for model in models {
            if( !events.contains(where: {$0.text == model.text})) {
            if (model.displayedAt != "" && model.hiddenAt != "") {
            // Create new EventView
            let event = Event()
            // Specify StartDate and EndDate
         
                event.userInfo = model
            event.startDate = model.displayedAt.iso8601!
            event.endDate =  model.hiddenAt.iso8601!
             
            // Add info: event title, subtitle, location to the array of Strings
            var info = [model.text]
           info.append("\(event.startDate.format(with: "HH:mm")) - \(event.endDate.format(with: "HH:mm"))")
            // Set "text" value of event by formatting all the information needed for display
            event.text = info.reduce("", {$0 + $1 + "\n"})
                if (k==0){
                    event.color = colors[1]}
                else { event.color = colors[0]}
                events.append(event)
                }
            }
        }
        return events
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
    editmessageview.modalTransitionStyle = .crossDissolve
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
                   self.dayView.state?.move(to: self.device!.messages.last!.displayedAt.iso8601!)
        
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
