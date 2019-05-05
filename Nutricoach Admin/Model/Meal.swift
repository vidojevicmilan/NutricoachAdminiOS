//
//  Meal.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 3/2/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import Foundation

class Meal {
    var title: String
    var ingreedients: [Ingreedient]
    
    init(title: String, ingreedients: [Ingreedient]){
        self.title = title
        self.ingreedients = ingreedients
    }
}

class Ingreedient {
    var name: String
    var amount: Int
    var unit: String
    
    init(name: String, amount: Int, unit: String){
        self.name = name
        self.amount = amount
        self.unit = unit
    }
}
