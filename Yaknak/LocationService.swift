//
//  LocationService.swift
//  Yaknak
//
//  Created by Sascha Melcher on 01/12/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import CoreLocation
import GeoFire
import Firebase
import SwiftLocation



class LocationService {
    
    static let shared = LocationService()
    var circleQuery: GFCircleQuery!
    var dataService: DataService!
    let geoTipRef: GeoFire!
    var dashboardCategories = Dashboard()
    var categoryRef: DatabaseReference!
    var animate: Bool!
    var refresh: Bool!
    var overallCount: Int
    var categories: [Dashboard.Entry]!

    
    var onReloadDashboard: ((_ categories: [Dashboard.Entry], _ overallCount: Int, _
    animate: Bool)->())?
    
    var onPassKeys: ((_ keys: [String]) -> ())?
 
    
    private init() {
        self.dataService = DataService()
        self.circleQuery = GFCircleQuery()
        self.geoTipRef = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
        self.categoryRef = self.dataService.CATEGORY_REF
        self.animate = true
        self.refresh = true
        self.overallCount = 0
        self.categories = []
    }
    
    func clear() {
    self.overallCount = 0
    self.categories = []
    }
    
    
    func queryGeoFence(center: CLLocation, radius: Double) {
    
      var keyArray: [String] = []
        circleQuery = geoTipRef?.query(at: Location.lastLocation.last, withRadius: radius)
        
        circleQuery.observe(.keyEntered, with: { (key, location) in
            
            if let key = key {
                keyArray.append(key)
            }
        })
        
        circleQuery.observe(.keyExited, with: { (key, location) in
            
            if let key = key, let index = keyArray.index(of: key) {
                keyArray.remove(at: index)
            }
        })
        
        circleQuery.observeReady({
            if self.refresh {
            self.fillDashboard(keyArray, completion: {
            self.onReloadDashboard?(self.categories, self.overallCount, self.animate)
            self.onPassKeys?(keyArray)
            self.animate = false
          })
            }
            else {
            self.refresh = true
            }
        })

    }

    
    func fillDashboard(_ keys: [String], completion: @escaping () -> ()) {
        
        self.clear()
        let entry = dashboardCategories.categories
      //  var categories: [Dashboard.Entry] = []
      //  var overallCount: Int = 0
        let group = DispatchGroup()
        
        
        for (index, cat) in entry.enumerated() {
            
            cat.tipCount = 0
            
            group.enter()
            self.categoryRef.child(cat.category.lowercased()).keepSynced(true)
            self.categoryRef.child(cat.category.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if (snapshot.hasChildren()) {
                    
                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        if (keys.contains(child.key)) {
                            cat.tipCount += 1
                            self.overallCount += 1
                        }
                    }
                    
                }
                self.categories.append(entry[index])
                group.leave()
            })
            
        }
        
        
        group.notify(queue: DispatchQueue.main) {
            self.refresh = false
            completion()
        }
        
    }

    
    
    func onDistanceChanged() {
       
        if let radius = Utils.determineRadius() {
        if circleQuery != nil {
            circleQuery.center = Location.lastLocation.last
            circleQuery.radius = radius
        }
        else {
        circleQuery = geoTipRef?.query(at: Location.lastLocation.last, withRadius: radius)
        }
    }
}

}
