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



class LocationService {
    
    static let shared = LocationService()
    var circleQuery: GFCircleQuery!
    var dataService: DataService!
    var keys: [String]!
    let geoTipRef: GeoFire!
    var dashboardCategories = Dashboard()
    var categoryRef: DatabaseReference!
    var animate: Bool!
    
    var onFillDashboard: ((_ categories: [Dashboard.Entry], _ overallCount: Int, _
    animate: Bool)->())?
 
    
    private init() {
        self.dataService = DataService()
        self.circleQuery = GFCircleQuery()
        self.keys = []
        self.geoTipRef = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
        self.categoryRef = self.dataService.CATEGORY_REF
        self.animate = true
    }
    
    
    func queryGeoFence(center: CLLocation, radius: Double) {
    
     //   var keyArray = [String]()
        circleQuery = geoTipRef?.query(at: Location.lastLocation.last, withRadius: radius)
        
        circleQuery.observe(.keyEntered, with: { (key, location) in
            
            if let key = key {
                self.keys.append(key)
            }
        })
        
        circleQuery.observe(.keyExited, with: { (key, location) in
            
            if let key = key, let index = self.keys.index(of: key) {
                self.keys.remove(at: index)
            }
        })
        
        circleQuery.observeReady({
          self.fillDashboard(completion: { (categories, overallCount) in
            self.onFillDashboard?(categories, overallCount, self.animate)
            self.animate = false
          })
        })

    }

    
    func fillDashboard(completion: @escaping (_ categories: [Dashboard.Entry], _ overallCount: Int) -> ()) {
        
        let entry = dashboardCategories.categories
        var categories: [Dashboard.Entry] = []
        var overallCount: Int = 0
        let group = DispatchGroup()
        
        
        for (index, cat) in entry.enumerated() {
            
            cat.tipCount = 0
            
            group.enter()
            self.categoryRef.child(cat.category.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if (snapshot.hasChildren()) {
                    
                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        if (self.keys.contains(child.key)) {
                            cat.tipCount += 1
                            overallCount += 1
                        }
                    }
                    
                }
                categories.append(entry[index])
                group.leave()
            })
            
        }
        
        
        group.notify(queue: DispatchQueue.main) {
            completion(categories, overallCount)
        }
        
    }

    
    
    func onDistanceChanged() {
       
        if let radius = Location.determineRadius() {
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
