//
//  StackObserver.swift
//  Yaknak
//
//  Created by Sascha Melcher on 07/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation

class StackObserver {
    
    static let shared = StackObserver()
    var onCategorySelected: ((Int)->())?
    
    
     private init() {
    categorySelected = 10
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
