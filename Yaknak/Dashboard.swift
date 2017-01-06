//
//  Dashboard.swift
//  Yaknak
//
//  Created by Sascha Melcher on 23/12/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation

struct Dashboard {


    class Entry {
    
        var category: String
        var imageName: String
        var tipCount: Int
        
        init(category: String, imageName: String, tipCount: Int) {
            
            self.category = category
            self.imageName = imageName
            self.tipCount = tipCount
            
        }
        
    }
    
        var allCategories = Entry(category: Constants.HomeView.EntryEverything, imageName: Constants.HomeView.EntryImageName, tipCount: 0)
        
        var categories = [
            
            Entry(category: Constants.HomeView.Categories[0], imageName: Constants.HomeView.CategoryImages[0], tipCount: 0),
            Entry(category: Constants.HomeView.Categories[1], imageName: Constants.HomeView.CategoryImages[1], tipCount: 0),
            Entry(category: Constants.HomeView.Categories[2], imageName: Constants.HomeView.CategoryImages[2], tipCount: 0),
            Entry(category: Constants.HomeView.Categories[3], imageName: Constants.HomeView.CategoryImages[3], tipCount: 0),
            Entry(category: Constants.HomeView.Categories[4], imageName: Constants.HomeView.CategoryImages[4], tipCount: 0),
            Entry(category: Constants.HomeView.Categories[5], imageName: Constants.HomeView.CategoryImages[5], tipCount: 0),
            Entry(category: Constants.HomeView.Categories[6], imageName: Constants.HomeView.CategoryImages[6], tipCount: 0),
            Entry(category: Constants.HomeView.Categories[7], imageName: Constants.HomeView.CategoryImages[7], tipCount: 0),
            Entry(category: Constants.HomeView.Categories[8], imageName: Constants.HomeView.CategoryImages[8], tipCount: 0),
            Entry(category: Constants.HomeView.Categories[9], imageName: Constants.HomeView.CategoryImages[9], tipCount: 0)
            
        ]
        

}
