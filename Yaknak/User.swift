//
//  User.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
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
    var isActive: Bool!
    var reportType: String?
    var reportMessage: String?
   
    
    
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
        
        if let active = (snapshot.value! as! NSDictionary)["isActive"] as? Bool {
            isActive = active
        }
        else {
            isActive = true
        }
        
        ref = snapshot.ref
        
    }
    
 
    
    init(authData: FIRUser) {
        self.uid = authData.uid
        if let mail = authData.providerData.first?.email {
        email = mail
        }
        else {
        email = ""
        }
    }
 
    
    init(_ uid: String, _ email: String, _ name: String, _ photoUrl: String, _ totalLikes: Int, _ totalTips: Int, reportType: String = "", reportMessage: String = "", _ isActive: Bool) {
        self.uid = uid
        self.email = email
        self.name = name
        self.photoUrl = photoUrl
        self.totalLikes = totalLikes
        self.totalTips = totalTips
        self.isActive = isActive
        self.ref = nil
    }
    
}
