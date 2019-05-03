//
//  Constants.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/15/19.
//  Copyright © 2019 iof. All rights reserved.
//

import Foundation

typealias CompletionHandler = (_ Success: Bool) -> ()
typealias CompletionHandler2 = (_ Success: Bool) -> ()

// URL Constants
let BASE_URL = "https://smart-interphone.herokuapp.com/api/"
let URL_REGISTER = "\(BASE_URL)signup"
let URL_LOGIN = "\(BASE_URL)signin"
let URL_MESSAGES = "\(BASE_URL)messages"
		
// Notification Constants
let NOTIF_DEVICE_DATA_DID_CHANGE = Notification.Name("notifDeviceDataChanged")
let NOTIF_DEVICES_ADDED = Notification.Name("addedNewDevices")
// Segues
let LOGIN_TO_MENU = "LoginToMenu"
let REGISTER_TO_MENU = "RegisterToMenu"
let MENU_TO_REGISTER = "MenuToLogin"
let REGISTER_TO_LOGIN  = "RegisterToLogin"
let DEVICES_TO_SCHEDULE     =  "devicesToSchedule"
let SCHEDULE_TO_MENU =  "ScheduleToMenu"


// User Defaults
let TOKEN_KEY = "token"
let LOGGED_IN_KEY = "loggedIn"
let USER_EMAIL = "userEmail"
let USER_FULLNAME = "userFullName"
let USER_NAME = "username"
let SELECTED_DEVICE = "selectedDevice"
let IMAGE_URL = "imageUrl"

// Headers
let HEADER = [
    "Content-Type": "application/json"
]

// Colors
let lightRed = UIColor(red:0.98, green:0.78, blue:0.77, alpha:1.0)


extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 3600)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}
extension Formatter {
    static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}
extension String {
    var iso8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
}
