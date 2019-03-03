//
//  Device.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/17/19.
//  Copyright © 2019 iof. All rights reserved.
//

import Foundation

struct Device : Equatable{
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
extension Device : DiffAware {
    var diffId: Int {
        return self.id.hashValue
    }
    
    static func compareContent(_ a: Device, _ b: Device) -> Bool {
        return a.name == b.name
    }
    
    
}
