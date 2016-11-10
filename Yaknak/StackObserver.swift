//
//  StackObserver.swift
//  Yaknak
//
//  Created by Sascha Melcher on 07/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation

class StackObserver: NSObject {
    
    var triggerReloadStack: Bool!
    var triggerReloadData: Bool!
    var triggerReload: Bool!
    var passedValue: Int {
        
        didSet {
            if (passedValue != oldValue) {
                triggerReloadStack = true
            }
        }
        
    }
    
    var likeCountValue: Int {
        
        didSet {
            if (likeCountValue != oldValue) {
                triggerReloadData = true
            }
        }
        
    }
    
    var reloadValue: Int {
        
        didSet{
            if (reloadValue != oldValue) {
                triggerReload = true
            }
        }
        
    }
    
    
    
    class var sharedInstance : StackObserver {
        struct Static {
            static let instance : StackObserver = StackObserver()
        }
        return Static.instance
    }
    
    override init() {
        triggerReloadStack = false
        triggerReloadData = false
        triggerReload = false
        passedValue = 100
        likeCountValue = 1
        reloadValue = 1
        
    }
    
    
}
