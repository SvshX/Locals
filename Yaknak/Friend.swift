//
//  Friend.swift
//  Yaknak
//
//  Created by Sascha Melcher on 29/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation



struct Friend {

    var id: String!
    var name: String!
    var imageUrl: String!
    
    
    init(_ id: String? = nil, _ name: String? = nil, _ imageUrl: String? = nil) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }


}
