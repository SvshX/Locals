//
//  User.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


struct User {
    

    var name: String!
    var email: String?
    var photoUrl: String!
    var ref: FIRDatabaseReference?
    var key: String?
    var uid: String!
    var totalLikes: Int?
    var totalTips : Int?
   
    
    
    init(snapshot: FIRDataSnapshot) {
        
        key = snapshot.key
        
        if let userName = (snapshot.value! as! NSDictionary)["name"] as? String {
        name = userName
        }
        else {
        name = ""
        }
        
        if let userEmail = (snapshot.value! as! NSDictionary)["email"] as? String {
        email = userEmail
        }
        else {
        email = ""
        }
        
        if let url = (snapshot.value! as! NSDictionary)["photoUrl"] as? String {
        photoUrl = url
        }
        else {
        photoUrl = ""
        }
        
        if let id = (snapshot.value! as! NSDictionary)["uid"] as? String {
        uid = id
        }
        else {
        uid = ""
        }
        
        if let likes = (snapshot.value! as! NSDictionary)["totalLikes"] as? Int {
        totalLikes = likes
        }
        else {
        totalLikes = 0
        }
        
        if let tips = (snapshot.value! as! NSDictionary)["totalTips"] as? Int {
        totalTips = tips
        }
        else {
        totalTips = 0
        }
        
        ref = snapshot.ref
        
    }
    
 
    
    init(authData: FIRUser) {
        uid = authData.uid
        if let mail = authData.providerData.first?.email {
        email = mail
        }
        else {
        email = ""
        }
    }
 
    
    init(uid: String, email: String, name: String, photoUrl: String, totalLikes: Int, totalTips: Int) {
        self.uid = uid
        self.email = email
        self.name = name
        self.photoUrl = photoUrl
        self.totalLikes = totalLikes
        self.totalTips = totalTips
        self.ref = nil
    }
    
}
