//
//  Device.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/17/19.
//  Copyright © 2019 iof. All rights reserved.
//

import Foundation
class Device {
    private(set) public var id: String
    private(set) public var name: String
    private(set) public var code: String
    public var messages: [Message]

    init(id : String, name: String , code : String , messages : [Message]) {
        self.id = id
        self.name = name
        self.code = code
        self.messages = messages
    }

}
