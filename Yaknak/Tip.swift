//
//  Tip.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import GeoFire


struct Tip {
    
    var key: String!
    var category: String!
    var description: String!
    var location: GeoFire!
    var likes: Int!
    var userName: String!
    var addedByUser: String!
    var userPicUrl: String!
    var tipImageUrl: String!
    var ref: FIRDatabaseReference?
    
    
    init(key: String = "", category: String, description: String, location: GeoFire, likes: Int, userName: String, addedByUser: String, userPicUrl: String, tipImageUrl: String) {
        self.category = category
        self.description = description
        self.location = location
        self.likes = likes
        self.userName = userName
        self.addedByUser = addedByUser
        self.userPicUrl = userPicUrl
        self.tipImageUrl = tipImageUrl
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        
        key = snapshot.key
        
        if let tipCategory = (snapshot.value! as! NSDictionary)["category"] as? String {
        category = tipCategory
        }
        else {
        category = ""
        }
        
        if let tipDescription = (snapshot.value! as! NSDictionary)["description"] as? String {
        description = tipDescription
        }
        else {
        description = ""
        }
        
        
        if let tipLocation = (snapshot.value! as! NSDictionary)["location"] as? GeoFire {
        location = tipLocation
        }
        else {
            location = GeoFire()
        }
        
        if let tipLikes = (snapshot.value! as! NSDictionary)["likes"] as? Int {
        likes = tipLikes
        }
        else {
        likes = 0
        }
        
        if let tipUserName = (snapshot.value! as! NSDictionary)["userName"] as? String {
        userName = tipUserName
        }
        else {
        userName = ""
        }
        
        if let byUser = (snapshot.value! as! NSDictionary)["addedByUser"] as? String {
        addedByUser = byUser
        }
        else {
        addedByUser = ""
        }
        
        if let userPic = (snapshot.value! as! NSDictionary)["userPicUrl"] as? String {
        userPicUrl = userPic
        }
        else {
        userPicUrl = ""
        }
        
        if let tipPic = (snapshot.value! as! NSDictionary)["tipImageUrl"] as? String {
            tipImageUrl = tipPic
        }
        else {
            tipImageUrl = ""
        }
        
        ref = snapshot.ref
        
    }
    
    
    
    func toAnyObject() -> Any {
        return [
            "category": category,
            "description": description,
            "location": location,
            "likes": likes,
            "userName": userName,
            "addedByUser": addedByUser,
            "userPicUrl": userPicUrl,
            "tipImageUrl": tipImageUrl
        ]
    }
 
 
    
}
