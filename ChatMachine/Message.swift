//
//  Message.swift
//  ChatMachine
//
//  Created by Yin Hua on 3/11/2015.
//  Copyright © 2015 Yin Hua. All rights reserved.
//

import Foundation.NSDate


class Message {
    
    let incoming: Bool
    let text: String
    let sentDate: NSDate
    
    init(incoming: Bool, text: String, sentDate: NSDate) {
        self.incoming = incoming
        self.text = text
        self.sentDate = sentDate
    }
    
}
