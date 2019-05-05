//
//  User.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 2/22/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import Foundation

class User {
    
    var id: String
    var email: String
    var name: String?
    var hasCompletedRegistration: Bool?
    var hasUnreadMessages: Bool?
    var prescribedMacros: (kcal: Int, carbs: Int, protein: Int, fat: Int)?
    var userInfo: (age: Int, weight: Float, height: Int, goal: String, activity: String)?
    var lastMealDate: Date?
    
    init(id: String, email: String) {
        self.id = id
        self.email = email
    }
    
}


