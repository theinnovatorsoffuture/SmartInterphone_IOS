//
//  DevicesService.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/17/19.
//  Copyright © 2019 iof. All rights reserved.
//

import Foundation


class DevicesService {
    
    static let instance = DevicesService()
    
    private let devices = [ Device(name: "Device 1"),
                          Device(name: "Device 2"),
                          Device(name: "Device 3"),
                          Device(name: "Device 4"),
                          Device(name: "Device 5"),
                          Device(name: "Device 6"),
                          Device(name: "Device 7"),
                          Device(name: "Device 8"),
                            ]
    
    func getDevices() -> [Device] {
        print("get devices at service ")
        debugPrint(devices)
        return devices
    }
}
