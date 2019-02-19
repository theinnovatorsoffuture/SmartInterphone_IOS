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
    
    
    private(set) var devices = [Device]()

    
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
                        let jsonDevices = json[0]["devices"].array
                        if (jsonDevices == nil) {
                            completion(false)
                            return
                        }
                        self.devices.removeAll()
                        
                        for i in 0..<jsonDevices!.count {
                            self.devices.append(Device(
                                id: jsonDevices![i]["_id"].stringValue ,
                                name: jsonDevices![i]["name"].stringValue ,
                                code: jsonDevices![i]["code"].stringValue ,
                                messages : [Message]()
                            ))
                         
                    
                        }
                        print("fi getdevices")
                        print(self.devices)
                       

                      
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
    
    func getDeviceMessages (device : Device ,completion: @escaping CompletionHandler) -> Device {
        
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
                    print (jsonMessages)
                    if (jsonMessages == nil) {
                        completion(false)
                        return
                    }
                    for i in 0..<jsonMessages!.count {
                        
                        let rMessage = Message(id: jsonMessages![i]["_id"].stringValue,
                                               text: jsonMessages![i]["content"].stringValue,
                                               displayedAt: jsonMessages![i]["displayAt"].stringValue,
                                               hiddenAt: jsonMessages![i]["hiddenAt"].stringValue
                        )
                        device.messages.append(rMessage)
                        
                        
                        
                        
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
        return device
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

}
