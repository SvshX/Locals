//
//  TipBuilder.swift
//  Yaknak
//
//  Created by Sascha Melcher on 18/08/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import GooglePlaces
import SwiftLocation


private class TipBuilderHelper {
  
  var tip: Tip?
  var mode: TravelMode.Modes?
  var index: Int?
}

class TipBuilder {

  static let shared = TipBuilder()
  private static let setup = TipBuilderHelper()
  let dataService: DataService!
  var view: CustomTipView!
  var placesClient: GMSPlacesClient?
  var geoTask: GeoTasks!
  var tipData: [Int : TipData]!
		
  
  class func setup(tip: Tip, mode: TravelMode.Modes, index: Int) {
    
    TipBuilder.setup.tip = tip
    TipBuilder.setup.mode = mode
    TipBuilder.setup.index = index
  }
  
  private init() {
    let tip = TipBuilder.setup.tip
    let mode = TipBuilder.setup.mode
    let index = TipBuilder.setup.index
    
    guard tip != nil, mode != nil, index != nil else {
      fatalError("Error - you must call setup before accessing TipBuilder.shared")
    }
    dataService = DataService()
    view = CustomTipView()
    placesClient = GMSPlacesClient.shared()
    geoTask = GeoTasks()
    tipData = [:]
  }
  
  
  
  func buildTip(completion: @escaping (_ tipView: TipData?, _ index: Int?, _ error: Error?) -> Void) {
    
      guard let tip = TipBuilder.setup.tip, let placeId = tip.placeId, let index = TipBuilder.setup.index else {return}
      
      if !placeId.isEmpty {
        
       lookupPlace(placeId, completion: { (place, error) in
        
        guard let place = place else {return}
        if !place.name.isEmpty {
          
          guard let currLat = Location.lastLocation.last?.coordinate.latitude, let currLong = Location.lastLocation.last?.coordinate.longitude else {return}
          
          self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: place.coordinate.latitude, destinationLong: place.coordinate.longitude, travelMode: TipBuilder.setup.mode, completion: { (status, success) in
            
            if success {
              
              let minutes = self.geoTask.totalDurationInSeconds / 60
              let meters = self.geoTask.totalDistanceInMeters
              guard let route = self.geoTask.overviewPolyline["points"] as? String else {return}
              let tipData = TipData(tip: tip, placeName: place.name, minutes: minutes, meters: meters, markerPosition: place.coordinate, route: route)
              
              self.tipData[index] = tipData
              completion(tipData, index, error)
            }
            else {
              
              if status == "OVER_QUERY_LIMIT" {
                sleep(2)
                self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: place.coordinate.latitude, destinationLong: place.coordinate.longitude, travelMode: TipBuilder.setup.mode, completion: { (status, success) in
                  
                  if success {
                    
                    let minutes = self.geoTask.totalDurationInSeconds / 60
                    let meters = self.geoTask.totalDistanceInMeters
                    guard let route = self.geoTask.overviewPolyline["points"] as? String else {return}
                    let tipData = TipData(tip: tip, placeName: place.name, minutes: minutes, meters: meters, markerPosition: place.coordinate, route: route)
                    
                    self.tipData[index] = tipData
                    completion(tipData, index, error)
                  }
                  
                })
              }
              else {
                completion(nil, index, error)
              }
              
            }
            
          })
        }
        
       })
    }
      else {
        guard let key = tip.key else {return}
        
        self.dataService.getTipLocation(key, completion: { (location, error) in
          
          if let error = error {
            print(error.localizedDescription)
          }
          else {
            
            guard let lat = location?.coordinate.latitude, let long = location?.coordinate.longitude, let currLat = Location.lastLocation.last?.coordinate.latitude, let currLong = Location.lastLocation.last?.coordinate.longitude else {return}
            
            self.geoTask.getAddressFromCoordinates(latitude: lat, longitude: long, completion: { (placeName, success) in
              
              if success {
                
                self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: lat, destinationLong: long, travelMode: TipBuilder.setup.mode, completion: { (status, success) in
                  
                  if success {
                    
                    let minutes = self.geoTask.totalDurationInSeconds / 60
                    let meters = self.geoTask.totalDistanceInMeters
                    guard let position = location?.coordinate, let route = self.geoTask.overviewPolyline["points"] as? String else {return}
                    let tipData = TipData(tip: tip, placeName: placeName, minutes: minutes, meters: meters, markerPosition: position, route: route)
                   
                    self.tipData[index] = tipData
                    completion(tipData, index, error)
                  }
                  else {
                    
                    if status == "OVER_QUERY_LIMIT" {
                      sleep(2)
                      self.geoTask.getDirections(lat, originLong: long, destinationLat: Location.lastLocation.last?.coordinate.latitude, destinationLong: Location.lastLocation.last?.coordinate.longitude, travelMode: TipBuilder.setup.mode, completion: { (status, success) in
                        
                        if success {
                          
                          let minutes = self.geoTask.totalDurationInSeconds / 60
                          let meters = self.geoTask.totalDistanceInMeters
                          guard let position = location?.coordinate, let route = self.geoTask.overviewPolyline["points"] as? String else {return}
                          let tipData = TipData(tip: tip, placeName: placeName, minutes: minutes, meters: meters, markerPosition: position, route: route)
                          
                          self.tipData[index] = tipData
                          completion(tipData, index, error)
                        }
                        
                      })
                    }
                    else {
                    completion(nil, index, error)
                    }
                  }
                  
                })
                
              }
              
            })
          }
        })
      }
    }

  
  
  func setupView(for view: CustomTipView) -> CustomTipView {
  
    guard let tip = TipBuilder.setup.tip, let placeId = tip.placeId else {return view}
    
      if !placeId.isEmpty {
        
    lookupPlace(placeId) { (place, error) in
      }
    }
      else {
     // getAddress
    }
   
    
    return view
  }
  
  
  func lookupPlace(_ placeId: String, completion: @escaping ((_ place: GMSPlace?, _ error: Error?) -> ())) {
  
    DispatchQueue.main.async {
      
      self.placesClient?.lookUpPlaceID(placeId, callback: { (place, error) -> Void in
        if let error = error {
          print("lookup place id query error: \(error.localizedDescription)")
          completion(nil, error)
        }
        else {
          guard let place = place else {return}
          completion(place, error)
        }
        
      })
    }

  
  }
  

}
