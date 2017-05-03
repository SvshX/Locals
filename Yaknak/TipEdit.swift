//
//  TipEdit.swift
//  Yaknak
//
//  Created by Sascha Melcher on 29/04/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


struct TipEdit {

    var key: String!
    var description: String!
    var descriptionEdited: String?
    var category: String!
    var categoryEdited: String?
    var imageUrl: String!
    var imageChanged: Bool?
    var placeId: String!
    var placeIdChanged: String?
    
    
    init(_ key: String, _ description: String, _ category: String, _ imageUrl: String, _ placeId: String) {
        self.key = key
        self.description = description
        self.category = category
        self.imageUrl = imageUrl
        self.placeId = placeId
        self.imageChanged = false
    }
    
    
    var descriptionDidChange: Bool {
        get {
            return descriptionEdited != nil && self.description != descriptionEdited
        }
    }
    
    var categoryDidChange: Bool {
        get {
            return categoryEdited != nil && self.category != categoryEdited?.lowercased()
        }
    }
    
    
    var locationDidChange: Bool {
        get {
            return placeIdChanged != nil && self.placeId != placeIdChanged
        }
    }
    
}
