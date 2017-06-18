//
//  Friend.swift
//  Yaknak
//
//  Created by Sascha Melcher on 29/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import Firebase



struct Friend {

    var key: String?
    var id: String!
    var name: String!
    var imageUrl: String!
    var ref: FIRDatabaseReference?
    
    
    init(_ id: String? = nil, _ name: String? = nil, _ imageUrl: String? = nil) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }
    
    
    init(snapshot: FIRDataSnapshot) {
        
        key = snapshot.key
        
        if let friendId = (snapshot.value! as! NSDictionary)["id"] as? String {
            id = friendId
        }
        else {
            id = ""
        }
        
        if let friendName = (snapshot.value! as! NSDictionary)["name"] as? String {
            name = friendName
        }
        else {
            name = ""
        }
        
        if let url = (snapshot.value! as! NSDictionary)["imageUrl"] as? String {
            imageUrl = url
        }
        else {
            imageUrl = ""
        }
        
        ref = snapshot.ref
        
    }
    
    
    func toAnyObject() -> Any {
        return [
            "id": id,
            "name": name,
            "imageUrl": imageUrl
        ]
    }


}
