//
//  ConversationsViewController.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 2/22/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import Firebase

class ConversationsViewController: UITableViewController {

    var usersForTable = [(id: String, userName: String, unread: Bool, latestMessage: String, timestamp: Double)]()
    @IBOutlet weak var newMessageButton: UIBarButtonItem!
    var conHandle: DatabaseHandle?
    var conChangedHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "cell")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchConversations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Database.database().reference().child("conversations").child("openConversations").removeObserver(withHandle: conHandle!)
        Database.database().reference().child("conversations").child("openConversations").removeObserver(withHandle: conChangedHandle!)
    }
    
    
    @IBAction func newMessageHandle(_ sender: Any) {
        let newMessageController = NewMessageViewController()
        newMessageController.parentVC = self
        let navVC = UINavigationController(rootViewController: newMessageController)
        present(navVC, animated: true, completion: nil)
    }
    
    func fetchConversations() {
        usersForTable.removeAll()
        conHandle = Database.database().reference().child("conversations").child("openConversations").observe(.childAdded) { (snap) in
            let uid = snap.key
            let latestMessage = snap.childSnapshot(forPath: "latestMessage").value as! String
            let unread = snap.childSnapshot(forPath: "unread").value as! Bool
            let timestamp = snap.childSnapshot(forPath: "timeOfLastMessage").value as! Double
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (user) in
                let name = user.childSnapshot(forPath: "name").value as! String
                let userWithId = (id: uid, userName: name, unread: unread, latestMessage: latestMessage, timestamp: timestamp)
                if unread == true {
                    self.usersForTable.insert(userWithId, at: 0)
                } else {
                    self.usersForTable.append(userWithId)
                }
                self.usersForTable.sort(by: { (arg0, arg1) -> Bool in
                    return arg0.timestamp > arg1.timestamp
                })
                self.tableView.reloadData()
            })
        }
        
        conChangedHandle = Database.database().reference().child("conversations").child("openConversations").observe(.childChanged, with: { (snap) in
            let uid = snap.key
            let latestMessage = snap.childSnapshot(forPath: "latestMessage").value as! String
            let unread = snap.childSnapshot(forPath: "unread").value as! Bool
            let timestamp = snap.childSnapshot(forPath: "timeOfLastMessage").value as! Double
            
            for i in 0..<self.usersForTable.count {
                if self.usersForTable[i].id == uid {
                    self.usersForTable[i].unread = unread
                    self.usersForTable[i].latestMessage = latestMessage
                    self.usersForTable[i].timestamp = timestamp
                }
            }
            self.usersForTable.sort(by: { (arg0, arg1) -> Bool in
                return arg0.timestamp > arg1.timestamp
            })
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersForTable.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = usersForTable[indexPath.row].userName
        cell.detailTextLabel?.text = usersForTable[indexPath.row].latestMessage
        if self.usersForTable[indexPath.row].unread == true {
            cell.textLabel?.textColor = UIColor(red: 23/255, green: 128/255, blue: 251/255, alpha: 1)
            cell.detailTextLabel?.textColor = UIColor(red: 23/255, green: 128/255, blue: 251/255, alpha: 1)
        } else {
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .gray
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = ChatViewController()
        chatVC.user = (id: usersForTable[indexPath.row].id, name: usersForTable[indexPath.row].userName)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.textLabel?.textColor = .black
        cell?.detailTextLabel?.textColor = .black
        usersForTable[indexPath.row].unread = false
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
