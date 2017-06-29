//
//  User.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import Firebase


struct MyUser {
    

    var name: String!
    var email: String?
    var photoUrl: String!
    var ref: DatabaseReference?
    var key: String?
    var facebookId: String!
    var totalLikes: Int?
    var totalTips : Int?
    var isActive: Bool!
    var hideTips: Bool!
    var reportType: String?
    var reportMessage: String?
    var friends: [String : Any]?
   
    
    
    init(snapshot: DataSnapshot) {
        
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
        
        if let id = (snapshot.value! as! NSDictionary)["facebookId"] as? String {
        facebookId = id
        }
        else {
        facebookId = ""
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
        
        if let friend = (snapshot.value! as! NSDictionary)["friends"] as? [String : Any] {
            friends = friend
        }
        else {
            friends = [String : Any]()
        }
        
        if let hide = (snapshot.value! as! NSDictionary)["hideTips"] as? Bool {
            hideTips = hide
        }
        else {
            hideTips = false
        }
        
        ref = snapshot.ref
        
    }
    
 
    
    init(authData: User) {
        if let mail = authData.providerData.first?.email {
        email = mail
        }
        else {
        email = ""
        }
    }
 
    
    init(_ facebookId: String, _ email: String, _ name: String, _ photoUrl: String, _ totalLikes: Int, _ totalTips: Int, reportType: String = "", reportMessage: String = "", _ isActive: Bool, _ friends: [String : Any], _ hideTips: Bool) {
        
        self.facebookId = facebookId
        self.email = email
        self.name = name
        self.photoUrl = photoUrl
        self.totalLikes = totalLikes
        self.totalTips = totalTips
        self.isActive = isActive
        self.friends = friends
        self.hideTips = hideTips
        self.ref = nil
    }
    
}
