//
//  ChatViewController.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 2/22/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import Firebase

class ChatViewController: MessagesViewController, UITextFieldDelegate, MessageInputBarDelegate  {

    var user: (id: String, name: String)!
    private var messages: [Message] = []
    var database = Database.database().reference()
    var displayName : String = ""
    var handle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = user.name
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        database.child("conversations").child("messages").child(user.id).removeObserver(withHandle: handle!)
    }
    
    func fetchMessages(){
        handle = database.child("conversations").child("messages").child(user.id).observe(.childAdded) { (snapshot) in
            let text = snapshot.childSnapshot(forPath: "text").value as! String
            let senderID = snapshot.childSnapshot(forPath: "senderID").value as! String
            let timestamp = snapshot.childSnapshot(forPath: "timestamp").value as! Double
            let date = Date(timeIntervalSince1970: timestamp)
            print("\(timestamp)  -  \(date)")
            self.database.child("conversations").child("openConversations").child(self.user.id).child("unread").setValue(false)
            let message = Message(sender: Sender(id: senderID, displayName: ""), messageId: snapshot.key, sentDate: date, kind: MessageKind.text(text))
            self.insertNewMessage(message)
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        
        messages.append(message)
        messagesCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let timestamp = NSDate().timeIntervalSince1970
        let message = ["text": text, "senderID": "admin", "timestamp": timestamp] as [String : Any]
        database.child("conversations").child("messages").child(user.id).childByAutoId().setValue(message)
        database.child("users").child(user.id).child("hasUnreadMessages").setValue(true)
        database.child("conversations").child("openConversations").child(user.id).setValue(["unread":false,"latestMessage":text, "timeOfLastMessage":timestamp])
        
        inputBar.inputTextView.text = ""
    }
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return Sender(id: "admin", displayName: "admin")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension ChatViewController: MessagesDisplayDelegate{
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red:0.00, green:0.52, blue:1.00, alpha:1.0) : UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        
        return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .pointedEdge)
    }
    
}

extension ChatViewController: MessagesLayoutDelegate{
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return .zero
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: 0, height: 0)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath,
                           with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}
