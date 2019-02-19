//
//  Message.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 2/18/19.
//  Copyright © 2019 iof. All rights reserved.
//

import Foundation


struct Message {
    private(set) public var id: String
    private(set) public var text: String
    private(set) public var displayedAt: String
    private(set) public var hiddenAt: String
    init(id : String , text : String , displayedAt : String , hiddenAt : String) {
        self.id = id
        self.text = text
        self.displayedAt = displayedAt
        self.hiddenAt = hiddenAt
    }
}
