//
//  Constants.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/15/19.
//  Copyright © 2019 iof. All rights reserved.
//

import Foundation

typealias CompletionHandler = (_ Success: Bool) -> ()

// URL Constants
let BASE_URL = "http://192.168.174.1:8080/api/"
let URL_REGISTER = "\(BASE_URL)signup"
let URL_LOGIN = "\(BASE_URL)signin"

// Notification Constants
let NOTIF_USER_DATA_DID_CHANGE = Notification.Name("notifUserDataChanged")

// Segues
let LOGIN_TO_MENU = "LoginToMenu"
let REGISTER_TO_MENU = "RegisterToMenu"
let MENU_TO_REGISTER = "MenuToLogin"
let REGISTER_TO_LOGIN  = "RegisterToLogin"


// User Defaults
let TOKEN_KEY = "token"
let LOGGED_IN_KEY = "loggedIn"
let USER_EMAIL = "userEmail"

// Headers
let HEADER = [
    "Content-Type": "application/json"
]

