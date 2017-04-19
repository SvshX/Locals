//
//  GeoTasks.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/03/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import CoreLocation


class GeoTasks: NSObject {
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    var lookupAddressResults: [String:Any]!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    var fetchedAddressCoordinates: CLLocationCoordinate2D!
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: [String:Any]!
    
    var overviewPolyline: [String:Any]!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    
    var totalDistanceInMeters: UInt = 0
    
    var totalDistance: String!
    
    var totalDurationInSeconds: UInt = 0
    
    var totalDuration: String!
    
    
    override init() {
        super.init()
    }
    
    
    func geocodeAddress(_ address: String!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        if let lookupAddress = address {
            let geocodeURLString = baseURLGeocode + "address=" + lookupAddress
            let geocodeURL = URL(string: geocodeURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            
            DispatchQueue.main.async(execute: { () -> Void in
                let geocodingResultsData = try? Data(contentsOf: geocodeURL!)
                
                do {
                    if let dictionary  = try JSONSerialization.jsonObject(with: geocodingResultsData!, options: .allowFragments) as? [String: Any]{
                        // Get the response status.
                        if let status = dictionary["status"] as? String {
                            if status == "OK" {
                                if let allResults = dictionary["results"] as? [[String:Any]]{
                                    self.lookupAddressResults = allResults.first
                                    
                                    // Keep the most important values.
                                    self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
                                    let geometry = self.lookupAddressResults["geometry"] as! [String:Any]
                                    let location = geometry["location"] as! [String:Double]
                                    self.fetchedAddressLongitude = location["lng"]
                                    self.fetchedAddressLatitude = location["lat"]
                                    self.fetchedAddressCoordinates = CLLocationCoordinate2D(latitude: self.fetchedAddressLatitude, longitude: self.fetchedAddressLongitude)
                                }
                                completionHandler(status, true)
                            }
                            else {
                                completionHandler(status, false)
                            }
                        }
                    }
                    else {
                        completionHandler("", false)
                    }
                } catch {
                    print("error in JSONSerialization")
                    completionHandler("", false)
                }
            })
        }
        else {
            completionHandler("No valid address.", false)
        }
    }
    
    
    func getDirections(_ originLat: Double!, originLong: Double!, destinationLat: Double!, destinationLong: Double!, travelMode: TravelMode.Modes!, completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        
        if let originLatitude = originLat {
            if let originLongitude = originLong {
            if let destinationLatitude = destinationLat {
                if let destinationLongitude = destinationLong {
                var directionsURLString = baseURLDirections + "origin=" + "\(originLatitude)" + "," + "\(originLongitude)" + "&destination=" + "\(destinationLatitude)" + "," + "\(destinationLongitude)"
                
                //let urlString = "http://maps.google.com/?saddr=\(sourceLocation.latitude),\(sourceLocation.longitude)&daddr=\(destinationLocation.latitude),\(destinationLocation.longitude)&directionsmode=driving"
              
                    /*
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                */
                if (travelMode) != nil {
                    var travelModeString = ""
                    
                    switch travelMode.rawValue {
                    case TravelMode.Modes.walking.rawValue:
                        travelModeString = "walking"
                        
                    case TravelMode.Modes.bicycling.rawValue:
                        travelModeString = "bicycling"
                        
                    default:
                        travelModeString = "walking"
                    }
                    
                    
                    directionsURLString += "&mode=" + travelModeString
                }
                
                
                //directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                
                let directionsURL = URL(string: directionsURLString)
                
                
                DispatchQueue.main.async(execute: { () -> Void in
                    do {
                        let directionsData = try? Data(contentsOf: directionsURL!)
                        
                        if let dictionary = try JSONSerialization.jsonObject(with: directionsData!, options: .allowFragments) as? [String: Any]{
                            // Get the response status.
                            if let status = dictionary["status"] as? String {
                                if status == "OK" {
                                    if let routes = dictionary["routes"] as? [[String:Any]]{
                                        self.selectedRoute = routes.first
                                        self.overviewPolyline = self.selectedRoute["overview_polyline"] as! [String:String]
                                        let legs = self.selectedRoute["legs"] as! [[String:Any]]
                                        let startLocationDictionary = legs.first?["start_location"] as! [String:Double]
                                        self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"]!, startLocationDictionary["lng"]!)
                                        let endLocationDictionary = legs[legs.count - 1]["end_location"] as! [String:Double]
                                        self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"]!, endLocationDictionary["lng"]!)
                                        self.originAddress = legs.first?["start_address"] as! String
                                        self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                                        self.calculateTotalDistanceAndDuration()
                                    }
                                    completionHandler(status, true)
                                }
                                else {
                                    completionHandler(status, false)
                                }
                            }
                        }
                        else{
                            completionHandler("", false)
                        }
                    }catch{
                        print("error in JSONSerialization")
                        completionHandler("", false)
                    }
                })
            }
            else {
                completionHandler("Destination is nil.", false)
            }
        }
    }
}
        else {
            completionHandler("Origin is nil", false)
        }
    }
    
    
    
    func retry(numberOfTimes: Int, task: (_ success: (Void) -> Void, _ failure: (NSError) -> Void) -> Void, success: (Void) -> Void, failure: (NSError) -> Void) {
        task(success,
             { error in
                // do we have retries left? if yes, call retry again
                // if not, report error
                if numberOfTimes > 1 {
                    sleep(2)
                    retry(numberOfTimes: numberOfTimes - 1, task: task, success: success, failure: failure)
                } else {
                    failure(error)
                }
        })
    }
    
    
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as! [[String:Any]]
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            let distance = leg["distance"] as! [String:Any]
            let duration = leg["duration"] as! [String:Any]
            totalDistanceInMeters += distance["value"] as! UInt
            totalDurationInSeconds += duration["value"] as! UInt
        }
        
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }
    
    
}