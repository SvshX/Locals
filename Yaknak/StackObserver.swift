//
//  StackObserver.swift
//  Yaknak
//
//  Created by Sascha Melcher on 07/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation

class StackObserver: NSObject {
    
    var onCategorySelected: ((Int)->())?
    
    class var sharedInstance : StackObserver {
        struct Static {
            static let instance : StackObserver = StackObserver()
        }
        return Static.instance
    }
    
     override init() {
     super.init()
    }
    
    
    var categorySelected = Int() {
    
        didSet {
            if (categorySelected != oldValue) {
                onCategorySelected?(categorySelected)
            }
       
        }
    }
    
    var likeCountChanged = Bool() {
    
        didSet {
          //  if (likeCountChanged != oldValue) {
                UserDefaults.standard.set(likeCountChanged, forKey: "likeCountChanged")
          //  }
        }
    
    }
    
    
}
