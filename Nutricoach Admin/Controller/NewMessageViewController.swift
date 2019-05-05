//
//  NewMessageViewController.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 2/22/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UITableViewController {

    var users = [(id: String, email: String, name: String)]()
    var cellId = "cellId"
    var parentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandle))
        
        navigationItem.title = "New message"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUsers()
    }
    
    @objc func cancelHandle() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUsers() {
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (snap) in
            for userSnap in snap.children {
                let user = userSnap as! DataSnapshot
                let id = user.key
                let email = user.childSnapshot(forPath: "email").value as! String
                let name = user.childSnapshot(forPath: "name").value as! String
                let u = (id: id, email: email, name: name)
                self.users.append(u)
            }
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].email
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = ChatViewController()
        chatVC.user = (id: users[indexPath.row].id, name: users[indexPath.row].name)
        tableView.deselectRow(at: indexPath, animated: true)
        //navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true) {
            self.parentVC?.navigationController?.pushViewController(chatVC, animated: true)
        }
        //navigationController?.pushViewController(chatVC, animated: false)
    }
}


