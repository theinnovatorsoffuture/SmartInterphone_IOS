//
//  DevicesService.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/17/19.
//  Copyright © 2019 iof. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DevicesService {
    
    static let instance = DevicesService()
      let defaults = UserDefaults.standard
    
   static var devices = [Device]()
     static var messages = [Message]()
    static var messagesForDate = [Message]()
   static var selectedDevice : Device?
    
    
    func addDevice (code: String ,completion: @escaping CompletionHandler) {
        let username = AuthService.instance.username
        let URL = BASE_URL + "user/" + username + "/" + code

        Alamofire.request(URL, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            
            if response.result.error == nil {
                guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                    if !json["message"].stringValue.contains("The device has been assigned successfully") {
                        completion(false)
                        return
                    }
                } catch {
                    completion(false)
                    print(error)
                }
             
                completion(true)
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    
    func getDevices(completion: @escaping CompletionHandler) {
        let username = AuthService.instance.username
            let URL = BASE_URL + username + "/devices"
     
            Alamofire.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in 
                
                if response.result.error == nil {
                    guard let data = response.data else { return }
                    do {
                        let json = try JSON(data: data)
                        let jsonDevices = json.array
                        if (jsonDevices == nil) {
                            completion(false)
                            return
                        }
                        DevicesService.devices.removeAll()
                        
                        for i in 0..<jsonDevices!.count {
                            if (!DevicesService.devices.contains(where: {$0.id == jsonDevices![i]["_id"].stringValue})) {
                            DevicesService.devices.append(Device(
                                id: jsonDevices![i]["_id"].stringValue ,
                                name: jsonDevices![i]["name"].stringValue ,
                                code: jsonDevices![i]["code"].stringValue ,
                                messages : [Message]()
                            ))
                         
                            }
                        }
                        print("fi getdevices")
                        print(DevicesService.devices)
                       
                            
                      
                    } catch {
                        completion(false)
                        print(error)
                    }
                    
                    completion(true)
                } else {
                    completion(false)
                    debugPrint(response.result.error as Any)
                }
              
            }
     
   
    }
    
    func newMessage(device : Device , message : Message ,completion: @escaping CompletionHandler)  {
        
        let body: [String: Any] = [
            "content": message.text,
            "displayAt": message.displayedAt,
            "hiddenAt": message.hiddenAt,
            "username": AuthService.instance.username,
            "device_id": device.id
            ]
        
        Alamofire.request(URL_MESSAGES, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            
            if response.result.error == nil {
                guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                    let message = json["message"].stringValue
                    if !message.contains("New Message created")  {
                        completion(false)
                        return
                    }
                
                    
                } catch {
                    completion(false)
                    print(error)
                }
                
                completion(true)
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
        
    }
    
    func getDeviceMessages (device : Device ,completion: @escaping CompletionHandler) {
        DevicesService.selectedDevice = device
        DevicesService.selectedDevice?.messages.removeAll()
        let URL_SHOW = URL_MESSAGES + "/" + device.id
        Alamofire.request(URL_SHOW, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            
            if response.result.error == nil {
                guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                    let message = json["message"].stringValue
                    if !message.contains("Message details")  {
                        completion(false)
                        return
                        
                    }
                    let jsonMessages = json["data"].array
               
                    if (jsonMessages == nil) {
                        completion(false)
                        return
                    }
                    for i in 0..<jsonMessages!.count {
                        if (jsonMessages![i]["displayAt"].stringValue != "" && jsonMessages![i]["hiddenAt"].stringValue != ""){
                        let rMessage = Message(id: jsonMessages![i]["_id"].stringValue,
                                               text: jsonMessages![i]["content"].stringValue,
                                               displayedAt: jsonMessages![i]["displayAt"].stringValue,
                                               hiddenAt: jsonMessages![i]["hiddenAt"].stringValue,
                                               deviceName: device.name
                        )
                            DevicesService.selectedDevice?.messages.append(rMessage)
                        }
                    }
                } catch {
                    completion(false)
                    print(error)
                }
                
                completion(true)
                
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    func getMessagesForUserDevices (completion: @escaping CompletionHandler2) {
        
        if (DevicesService.devices.count != 0){
         
            for i in 0..<DevicesService.devices.count {
            self.getDeviceMessages(device: DevicesService.devices[i]){ (success) in
                if success {
                    if (i == DevicesService.devices.count-1) {
                    DevicesService.messages.append(contentsOf: DevicesService.selectedDevice!.messages)
                    }
                } else {
                    print("error getting devices messages")
                }
            }
          }
              completion(true)
        } else {
            completion(false)
        }
    }
    func EditMessage (message : Message , deviceId: String ,completion: @escaping CompletionHandler) {
        
        let URL_EDIT = URL_MESSAGES + "/" + message.id + "/" + deviceId
     
        let body: [String: Any] = [
            "content": message.text,
            "displayAt": message.displayedAt,
            "hiddenAt": message.hiddenAt,
            "username": AuthService.instance.username,
            "device_id": deviceId
        ]
        print ("before check")
        print(body)
        print (URL_EDIT)
        Alamofire.request(URL_EDIT, method: .put, parameters: body, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            
            if response.result.error == nil {
                guard let data = response.data else { return }
                do {
                 let json = try JSON(data: data)
                    print(json)
                    print ("after check")
                } catch {
                    completion(false)
                    print(error)
                }
               
                
                completion(true)
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
        
        
        
    }
    
    
    func getDeviceMessagesForDate (device : Device , date :Date ,completion: @escaping CompletionHandler) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "y-MM-dd'T'H:mm:ss.SSS'Z'"
        DevicesService.selectedDevice = device
        DevicesService.selectedDevice?.messages.removeAll()
        let URL_SHOW = URL_MESSAGES + "/" + device.id
        Alamofire.request(URL_SHOW, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            
            if response.result.error == nil {
                guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                    let message = json["message"].stringValue
                    if !message.contains("Message details")  {
                        completion(false)
                        return
                        
                    }
                    let jsonMessages = json["data"].array
                    
                    if (jsonMessages == nil) {
                        completion(false)
                        return
                    }
                    for i in 0..<jsonMessages!.count {
                        
                        if (jsonMessages![i]["displayAt"].stringValue != "" && jsonMessages![i]["hiddenAt"].stringValue != ""){
                            var startDate = formatter.date(from: jsonMessages![i]["displayAt"].stringValue)
                            var endDate = formatter.date(from: jsonMessages![i]["hiddenAt"].stringValue)
                            startDate = startDate?.stripTime()
                            endDate = endDate?.stripTime()
                            if (startDate != nil && endDate != nil) {
                                if (date.isBetween(startDate! , and: endDate!)) {
                                    let rMessage = Message(id: jsonMessages![i]["_id"].stringValue,
                                                           text: jsonMessages![i]["content"].stringValue,
                                                           displayedAt: jsonMessages![i]["displayAt"].stringValue,
                                                           hiddenAt: jsonMessages![i]["hiddenAt"].stringValue,
                                                           deviceName: device.name
                                    )
                                    DevicesService.selectedDevice?.messages.append(rMessage)
                                }
                                
                            }
                           
                        }
                    }
                } catch {
                    completion(false)
                    print(error)
                }
                
                completion(true)
                
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }

    func getAllMessagesForDate (date:Date ,completion: @escaping CompletionHandler2) {
        
        if (DevicesService.devices.count != 0){
            
            for i in 0..<DevicesService.devices.count {
                self.getDeviceMessagesForDate(device: DevicesService.devices[i], date: date){ (success) in
                    if success {
                        if (i == DevicesService.devices.count-1) {
                            DevicesService.messagesForDate.append(contentsOf: DevicesService.selectedDevice!.messages)
                        }
                    } else {
                        print("error getting devices messages")
                    }
                }
            }
            completion(true)
        } else {
            completion(false)
        }
    }
}
