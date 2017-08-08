//
//  GeoTasks.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/03/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import CoreLocation
import GeoFire
import GooglePlaces


class GeoTasks: NSObject {
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    var lookupAddressResults: [String:Any]!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    var fetchedPlaceId: String!
    
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
                                    self.fetchedPlaceId = self.lookupAddressResults["place_id"] as! String
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
    
    
    func getDirections(_ originLat: Double!, originLong: Double!, destinationLat: Double!, destinationLong: Double!, travelMode: TravelMode.Modes!, completion: @escaping ((_ status: String, _ success: Bool) -> Void)) {
      
      guard let originLat = originLat, let originLong = originLong, let destLat = destinationLat, let destLong = destinationLong else {return}
      
                var directionsURLString = baseURLDirections + "origin=" + "\(originLat)" + "," + "\(originLong)" + "&destination=" + "\(destLat)" + "," + "\(destLong)"
      
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
                
                
                
                //directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                
                let directionsURL = URL(string: directionsURLString)
                
                
                DispatchQueue.main.async(execute: { () -> Void in
                    do {
                        guard let directionsData = try? Data(contentsOf: directionsURL!) else {return}
                        
                        if let dictionary = try JSONSerialization.jsonObject(with: directionsData, options: .allowFragments) as? [String: Any] {
                            // Get the response status.
                            if let status = dictionary["status"] as? String {
                                if status == "OK" {
                                    if let routes = dictionary["routes"] as? [[String:Any]] {
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
                                    completion(status, true)
                                }
                                else {
                                    completion(status, false)
                                }
                            }
                        }
                        else{
                            completion("", false)
                        }
                    }catch{
                        print("error in JSONSerialization")
                        completion("", false)
                    }
                })
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
    
    
    
    func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping ((_ place: String?, _ success: Bool) -> Void)) {
        
        if let url = URL(string: "\(Constants.Config.GeoCodeString)latlng=\(latitude),\(longitude)") {
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if let error = error {
                
                print(error.localizedDescription)
                completion(nil, false)
                
            } else {
                
                let kStatus = "status"
                let kOK = "ok"
                let kZeroResults = "ZERO_RESULTS"
                let kAPILimit = "OVER_QUERY_LIMIT"
                let kRequestDenied = "REQUEST_DENIED"
                let kInvalidRequest = "INVALID_REQUEST"
                let kInvalidInput =  "Invalid Input"
                
                //let dataAsString: NSString? = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                
                let jsonResult: NSDictionary = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                
                var status = jsonResult.value(forKey: kStatus) as! NSString
                status = status.lowercased as NSString
                
                if(status.isEqual(to: kOK)) {
                    
                    let address = AddressParser()
                    
                    address.parseGoogleLocationData(jsonResult)
                    
                    let addressDict = address.getAddressDictionary()
                    //     let placemark:CLPlacemark = address.getPlacemark()
                    
                    
                    
                    if let placeId = addressDict["placeId"] as? String {
                        
                        DispatchQueue.main.async {
                            
                            GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (place, err) -> Void in
                                if let error = error {
                                    print("lookup place id query error: \(error.localizedDescription)")
                                    completion(nil, false)
                                    return
                                }
                                
                                if let place = place {
                                    
                                    
                                    if !place.name.isEmpty {
                                        completion(place.name, true)
                                    }
                                    else {
                                        if let address = addressDict["formattedAddess"] as? String {
                                            completion(address, true)
                                        }
                                    }
                                    
                                    
                                } else {
                                    print("No place details for \(placeId)")
                                    if let address = addressDict["formattedAddess"] as? String {
                                        completion(address, true)
                                    }
                                }
                            })
                            
                        }
                    }
                    
                }
                else if(!status.isEqual(to: kZeroResults) && !status.isEqual(to: kAPILimit) && !status.isEqual(to: kRequestDenied) && !status.isEqual(to: kInvalidRequest)) {
                    
                    completion(status as String, false)
                }
                    
                else {
                    completion(status as String, false)
                }
            }
            
        })
        task.resume()
        }
    }
    
    
    
    func getCoordinatesFromPlaceId(_ placeId: String, completionHandler: @escaping ((_ coordinates: CLLocationCoordinate2D?, _ success: Bool, _ error: Error?) -> Void)) {
        
        DispatchQueue.main.async {
            
            GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (place, error) -> Void in
                if let error = error {
                    completionHandler(nil, false, error)
                }
                
                if let place = place {
                    
                    completionHandler(place.coordinate, true, error)
                    
                } else {
                    print("No place details for \(placeId)")
                    completionHandler(nil, false, error)
                }
            })
            
        }
    }
    
    
    
     func getAddressFromPlaceId(_ placeId: String, completionHandler: @escaping ((_ address: String?, _ success: Bool, _ error: Error?) -> Void)) {
        
        DispatchQueue.main.async {
            
            GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (place, error) -> Void in
                if let error = error {
                    completionHandler(nil, false, error)
                }
                
                if let place = place {
                    
                    if !place.name.isEmpty {
                        completionHandler(place.name, true, error)
                    }
                    else {
                        completionHandler(place.formattedAddress, true, error)
                    }
                    
                } else {
                    completionHandler(nil, false, error)
                }
            })
            
        }
    }

    
    
    private class AddressParser: NSObject {
        
        fileprivate var latitude = NSString()
        fileprivate var longitude  = NSString()
        fileprivate var streetNumber = NSString()
        fileprivate var route = NSString()
        fileprivate var locality = NSString()
        fileprivate var subLocality = NSString()
        fileprivate var formattedAddress = NSString()
        fileprivate var administrativeArea = NSString()
        fileprivate var administrativeAreaCode = NSString()
        fileprivate var subAdministrativeArea = NSString()
        fileprivate var postalCode = NSString()
        fileprivate var country = NSString()
        fileprivate var subThoroughfare = NSString()
        fileprivate var thoroughfare = NSString()
        fileprivate var ISOcountryCode = NSString()
        fileprivate var state = NSString()
        fileprivate var placeId = NSString()
        
        
        override init() {
            super.init()
        }
        
        fileprivate func getAddressDictionary()-> NSDictionary {
            
            let addressDict = NSMutableDictionary()
            
            addressDict.setValue(latitude, forKey: "latitude")
            addressDict.setValue(longitude, forKey: "longitude")
            addressDict.setValue(streetNumber, forKey: "streetNumber")
            addressDict.setValue(locality, forKey: "locality")
            addressDict.setValue(subLocality, forKey: "subLocality")
            addressDict.setValue(administrativeArea, forKey: "administrativeArea")
            addressDict.setValue(postalCode, forKey: "postalCode")
            addressDict.setValue(country, forKey: "country")
            addressDict.setValue(formattedAddress, forKey: "formattedAddress")
            addressDict.setValue(placeId, forKey: "placeId")
            
            return addressDict
        }
        
        
        
        
        fileprivate func parseGoogleLocationData(_ resultDict:NSDictionary) {
            
            let locationDict = (resultDict.value(forKey: "results") as! NSArray).firstObject as! NSDictionary
            
            let formattedAddrs = locationDict.object(forKey: "formatted_address") as! NSString
            
            let geometry = locationDict.object(forKey: "geometry") as! NSDictionary
            let location = geometry.object(forKey: "location") as! NSDictionary
            let lat = location.object(forKey: "lat") as! Double
            let lng = location.object(forKey: "lng") as! Double
            let placeId = locationDict.object(forKey: "place_id") as! NSString
            
            self.latitude = lat.description as NSString
            self.longitude = lng.description as NSString
            self.placeId = placeId
            
            let addressComponents = locationDict.object(forKey: "address_components") as! NSArray
            
            self.subThoroughfare = component("street_number", inArray: addressComponents, ofType: "long_name")
            self.thoroughfare = component("route", inArray: addressComponents, ofType: "long_name")
            self.streetNumber = self.subThoroughfare
            self.locality = component("locality", inArray: addressComponents, ofType: "long_name")
            self.postalCode = component("postal_code", inArray: addressComponents, ofType: "long_name")
            self.route = component("route", inArray: addressComponents, ofType: "long_name")
            self.subLocality = component("subLocality", inArray: addressComponents, ofType: "long_name")
            self.administrativeArea = component("administrative_area_level_1", inArray: addressComponents, ofType: "long_name")
            self.administrativeAreaCode = component("administrative_area_level_1", inArray: addressComponents, ofType: "short_name")
            self.subAdministrativeArea = component("administrative_area_level_2", inArray: addressComponents, ofType: "long_name")
            self.country =  component("country", inArray: addressComponents, ofType: "long_name")
            self.ISOcountryCode =  component("country", inArray: addressComponents, ofType: "short_name")
            
            
            self.formattedAddress = formattedAddrs
            
        }
        
        fileprivate func component(_ component:NSString,inArray:NSArray,ofType:NSString) -> NSString {
            let index = inArray.indexOfObject(passingTest:) {obj, idx, stop in
                
                let objDict:NSDictionary = obj as! NSDictionary
                let types:NSArray = objDict.object(forKey: "types") as! NSArray
                let type = types.firstObject as! NSString
                return type.isEqual(to: component as String)
            }
            
            if (index == NSNotFound){
                
                return ""
            }
            
            if (index >= inArray.count){
                return ""
            }
            
            let type = ((inArray.object(at: index) as! NSDictionary).value(forKey: ofType as String)!) as! NSString
            
            if (type.length > 0) {
                
                return type
            }
            return ""
            
        }
        
        fileprivate func getPlacemark() -> CLPlacemark {
            
            var addressDict = [String : AnyObject]()
            
            let formattedAddressArray = self.formattedAddress.components(separatedBy: ", ") as Array
            
            let kSubAdministrativeArea = "SubAdministrativeArea"
            let kSubLocality           = "SubLocality"
            let kState                 = "State"
            let kStreet                = "Street"
            let kThoroughfare          = "Thoroughfare"
            let kFormattedAddressLines = "FormattedAddressLines"
            let kSubThoroughfare       = "SubThoroughfare"
            let kPostCodeExtension     = "PostCodeExtension"
            let kCity                  = "City"
            let kZIP                   = "ZIP"
            let kCountry               = "Country"
            let kCountryCode           = "CountryCode"
            let kPlaceId               = "PlaceId"
            
            addressDict[kSubAdministrativeArea] = self.subAdministrativeArea
            addressDict[kSubLocality] = self.subLocality as NSString
            addressDict[kState] = self.administrativeAreaCode
            
            addressDict[kStreet] = formattedAddressArray.first! as NSString
            addressDict[kThoroughfare] = self.thoroughfare
            addressDict[kFormattedAddressLines] = formattedAddressArray as AnyObject?
            addressDict[kSubThoroughfare] = self.subThoroughfare
            addressDict[kPostCodeExtension] = "" as AnyObject?
            addressDict[kCity] = self.locality
            
            addressDict[kZIP] = self.postalCode
            addressDict[kCountry] = self.country
            addressDict[kCountryCode] = self.ISOcountryCode
            addressDict[kPlaceId] = self.placeId
            
            let lat = self.latitude.doubleValue
            let lng = self.longitude.doubleValue
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict as [String : AnyObject]?)
            
            return (placemark as CLPlacemark)
            
        }
    }
    
}
