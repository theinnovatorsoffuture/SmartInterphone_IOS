//
//  CallendarVC.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/25/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CallendarVC: UIViewController ,
JTAppleCalendarViewDelegate , JTAppleCalendarViewDataSource {
    
    // outlets
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    // vars
    let formatter = DateFormatter()
    var testCalendar = Calendar.current
    let corner: CGFloat = 20.0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    override func viewWillAppear(_ animated: Bool) {
         setupCalendar()
    }
    func setupCalendar () {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        sharedFunctionToConfigureCell(cell: cell, cellState: cellState, date: date)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        sharedFunctionToConfigureCell(cell: cell, cellState: cellState, date: date)
    }
    
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        let endDate = formatter.date(from: "2025 12 31")
        let startDate = formatter.date(from: "2019 02 01")
        let params = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        return params
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else {return}
        validCell.selectedBackgroundView?.isHidden = false
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else {return}
        validCell.selectedBackgroundView?.isHidden = true
    }
    
    func sharedFunctionToConfigureCell(cell: CustomCell, cellState: CellState, date: Date) {
        cell.dateLabel.text = cellState.text
        
        if testCalendar.isDateInToday(date) {
            cell.backgroundView?.backgroundColor =  UIColor.lightGray
            cell.backgroundView?.layer.cornerRadius = corner
            
            
        } else {
            cell.backgroundView?.backgroundColor =  UIColor.white
            cell.backgroundView?.layer.cornerRadius = corner
        }
        
        cell.selectedBackgroundView?.layer.cornerRadius = corner
        cell.selectedBackgroundView?.backgroundColor = UIColor.blue
        
        
        // more code configurations
        // ...
        // ...
        // ...
    
}

    

    
}
