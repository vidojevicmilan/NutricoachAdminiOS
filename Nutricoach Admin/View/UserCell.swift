//
//  UserCell.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 2/24/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
