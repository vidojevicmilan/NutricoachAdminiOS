//
//  UsersViewController.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 2/22/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UITableViewController {
    
    var users: [User]?
    var usersHandle: DatabaseHandle?
    var usersChangedHandle: DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchUsers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Database.database().reference().child("users").removeObserver(withHandle: usersHandle!)
    }
    
    func fetchUsers() {
        users = [User]()
        usersHandle = Database.database().reference().child("users").observe(.childAdded, with: { (snap) in
            let id = snap.key
            let email = snap.childSnapshot(forPath: "email").value as! String
            let user = User(id: id, email: email)
            
            user.name = snap.childSnapshot(forPath: "name").value as? String
            user.hasUnreadMessages = snap.childSnapshot(forPath: "hasUnreadMessages").value as? Bool
            user.hasCompletedRegistration = snap.childSnapshot(forPath: "hasCompletedRegistration").value as? Bool
            
            let carbs = snap.childSnapshot(forPath: "prescribedMacros").childSnapshot(forPath: "carbs").value as? Int
            let protein = snap.childSnapshot(forPath: "prescribedMacros").childSnapshot(forPath: "protein").value as? Int
            let fat = snap.childSnapshot(forPath: "prescribedMacros").childSnapshot(forPath: "fat").value as? Int
            let kcal = snap.childSnapshot(forPath: "prescribedMacros").childSnapshot(forPath: "kcal").value as? Int
            user.prescribedMacros = (kcal: kcal ?? 0, carbs: carbs ?? 0, protein: protein ?? 0, fat: fat ?? 0)
            
            let age = snap.childSnapshot(forPath: "userInfo").childSnapshot(forPath: "age").value as? Int
            let height = snap.childSnapshot(forPath: "userInfo").childSnapshot(forPath: "height").value as? Int
            let weight = snap.childSnapshot(forPath: "userInfo").childSnapshot(forPath: "weight").value as? Float
            let goal = snap.childSnapshot(forPath: "userInfo").childSnapshot(forPath: "goal").value as? String
            let activity = snap.childSnapshot(forPath: "userInfo").childSnapshot(forPath: "activity").value as? String
            user.userInfo = (age: age ?? 0, weight: weight ?? 0, height: height ?? 0, goal: goal ?? "n/a", activity: activity ?? "n/a")
            
            let lastMealDate = snap.childSnapshot(forPath: "lastMealDate").value as? Int
            let form = DateFormatter()
            form.dateFormat = "yyyyMMdd"
            user.lastMealDate = form.date(from: "\(lastMealDate ?? -1)" )
            
            self.users?.append(user)
            self.users?.sort(by: { (user1, user2) -> Bool in
                if user1.lastMealDate != nil && user2.lastMealDate != nil {
                    if user1.lastMealDate! < user2.lastMealDate! {
                        return true
                    }
                } else if user1.lastMealDate == nil {
                    return true
                }
                return false
            })
            self.tableView.reloadData()
        })
        
        usersChangedHandle = Database.database().reference().child("users").observe(.childChanged, with: { (snap) in
            for i in 0..<self.users!.count {
                if self.users![i].id == snap.key {
                    self.users?.remove(at: i)
                    
                    let email = snap.childSnapshot(forPath: "email").value as! String
                    let user = User(id: snap.key, email: email)
                    
                    user.name = snap.childSnapshot(forPath: "name").value as? String
                    user.hasUnreadMessages = snap.childSnapshot(forPath: "hasUnreadMessages").value as? Bool
                    user.hasCompletedRegistration = snap.childSnapshot(forPath: "hasCompletedRegistration").value as? Bool
                    
                    let carbs = snap.childSnapshot(forPath: "prescribedMacros").childSnapshot(forPath: "carbs").value as? Int
                    let protein = snap.childSnapshot(forPath: "prescribedMacros").childSnapshot(forPath: "protein").value as? Int
                    let fat = snap.childSnapshot(forPath: "prescribedMacros").childSnapshot(forPath: "fat").value as? Int
                    let kcal = snap.childSnapshot(forPath: "prescribedMacros").childSnapshot(forPath: "kcal").value as? Int
                    user.prescribedMacros = (kcal: kcal ?? 0, carbs: carbs ?? 0, protein: protein ?? 0, fat: fat ?? 0)
                    
                    let age = snap.childSnapshot(forPath: "userInfo").childSnapshot(forPath: "age").value as? Int
                    let height = snap.childSnapshot(forPath: "userInfo").childSnapshot(forPath: "height").value as? Int
                    let weight = snap.childSnapshot(forPath: "userInfo").childSnapshot(forPath: "weight").value as? Float
                    let goal = snap.childSnapshot(forPath: "userInfo").childSnapshot(forPath: "goal").value as? String
                    let activity = snap.childSnapshot(forPath: "userInfo").childSnapshot(forPath: "activity").value as? String
                    user.userInfo = (age: age ?? 0, weight: weight ?? 0, height: height ?? 0, goal: goal ?? "n/a", activity: activity ?? "n/a")
                    
                    let lastMealDate = snap.childSnapshot(forPath: "lastMealDate").value as? String
                    let form = DateFormatter()
                    form.dateFormat = "yyyyMMdd"
                    user.lastMealDate = form.date(from: lastMealDate ?? "n/a")
                    
                    self.users?.append(user)
                    self.users?.sort(by: { (user1, user2) -> Bool in
                        if user1.lastMealDate != nil && user2.lastMealDate != nil {
                            if user1.lastMealDate! < user2.lastMealDate! {
                                return true
                            }
                        } else if user1.lastMealDate == nil {
                            return true
                        }
                        return false
                    })
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users![indexPath.row].name ?? users![indexPath.row].email
        cell.detailTextLabel?.textColor = .gray
        if users![indexPath.row].lastMealDate != nil {
            let form = DateFormatter()
            form.dateFormat = "EEEE, dd. MMM y."
            cell.detailTextLabel?.text = "Last meal added for: " + form.string(from: users![indexPath.row].lastMealDate!)
        } else {
            cell.detailTextLabel?.text = "No meal plan added!"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "userDetailsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userDetailsSegue" {
            let vc = segue.destination as! UserDetailsViewController
            let index = tableView.indexPathForSelectedRow!.row
            vc.user = users![index]
        }
    }
    
}
