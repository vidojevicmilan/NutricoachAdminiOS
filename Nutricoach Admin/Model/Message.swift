//
//  Message.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 2/24/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import MessageKit

class Message: MessageType {
    
    var sender: Sender
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    init(sender: Sender, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
}
