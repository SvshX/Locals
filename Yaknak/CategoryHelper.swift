//
//  CategoryHelper.swift
//  Yaknak
//
//  Created by Sascha Melcher on 28/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD
import Foundation
import FirebaseDatabase
import GeoFire
import Firebase
import FirebaseAuth

class CategoryHelper: NSObject {

    var dashboardCategories = Dashboard()
    var categoryArray: [Dashboard.Entry]!
    var overallCount = 0
    var dataService: DataService!
    var categoryRef: FIRDatabaseReference!


    override init() {
        super.init()
        self.dataService = DataService()
        self.categoryRef = dataService.CATEGORY_REF
        categoryArray = []
        overallCount = 0
    }



    func findNearbyTips(completionHandler: @escaping ((_ success: Bool) -> Void)) {
        
        var keys = [String]()
        let geo = GeoFire(firebaseRef: dataService.GEO_TIP_REF)
        if let lat = LocationService.sharedInstance.currentLocation?.coordinate.latitude {
            if let long = LocationService.sharedInstance.currentLocation?.coordinate.longitude {
                let myLocation = CLLocation(latitude: lat, longitude: long)
                if let radius = LocationService.sharedInstance.determineRadius() {
                    let circleQuery = geo!.query(at: myLocation, withRadius: radius)  // radius is in km
                    
                    circleQuery!.observe(.keyEntered, with: { (key, location) in
                        
                        if let key = key {
                            keys.append(key)
                        }
                        
                    })
                    
                    //Execute this code once GeoFire completes the query!
                    circleQuery?.observeReady ({
                        self.prepareTable(keys: keys, completion: { (Void) in
                            // self.doTableRefresh()
                            completionHandler(true)
                        })
                        
                    })
                }
            }
        }
    }
    
    
    func prepareTable(keys: [String], completion: @escaping (Void) -> ()) {
        
        let entry = dashboardCategories.categories
        self.categoryArray.removeAll(keepingCapacity: true)
        self.overallCount = 0
        let group = DispatchGroup()
        
        
        for (index, cat) in entry.enumerated() {
            
            cat.tipCount = 0
            
            group.enter()
            self.categoryRef.child(cat.category.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let i = snapshot.childrenCount
                print(i)
                if (snapshot.hasChildren()) {
                    
                    for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        
                        if (keys.contains(child.key)) {
                            cat.tipCount += 1
                            self.overallCount += 1
                        }
                    }
                    
                }
                self.categoryArray.append(entry[index])
                group.leave()
            })
            
        }
        
        
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
        
    }



}
