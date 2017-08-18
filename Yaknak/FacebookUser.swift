//
//  FacebookUser.swift
//  Yaknak
//
//  Created by Sascha Melcher on 20/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation

struct FacebookUser {
  
    public let id: String
    public let accessToken: String
    public let email: String?
    public let name: String?
    public let picUrl: String?
    
    public init(id: String, accessToken: String, email: String?, name: String?, picUrl: String?) {
        
        self.id = id
        self.accessToken = accessToken
        self.email = email
        self.name = name
        self.picUrl = picUrl
    }
}
