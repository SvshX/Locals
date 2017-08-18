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


private class SingletonSetupHelper {
  
  var tip: Tip?
  var mode: TravelMode.Modes?
}

class TipBuilder {

  static let shared = TipBuilder()
  private static let setup = SingletonSetupHelper()
  let dataService: DataService!
  var tipView: TipView!
  var placesClient: GMSPlacesClient?
  var geoTask: GeoTasks!
		
  
  class func setup(tip: Tip, mode: TravelMode.Modes) {
    
    TipBuilder.setup.tip = tip
    TipBuilder.setup.mode = mode
  }
  
  private init() {
    let tip = TipBuilder.setup.tip
    let mode = TipBuilder.setup.mode
    
    guard tip != nil, mode != nil else {
      fatalError("Error - you must call setup before accessing TipBuilder.shared")
    }
    dataService = DataService()
    tipView = TipView()
    placesClient = GMSPlacesClient.shared()
    geoTask = GeoTasks()
  }
  
  
  
  func buildTip(completion: @escaping (_ tipView: TipView?, _ error: Error?) -> Void) {
    
      guard let tip = TipBuilder.setup.tip, let placeId = tip.placeId else {return}
      
      if !placeId.isEmpty {
        
        DispatchQueue.main.async {
          
          self.placesClient?.lookUpPlaceID(placeId, callback: { (place, error) -> Void in
            if let error = error {
              print("lookup place id query error: \(error.localizedDescription)")
              completion(nil, error)
            }
            
            guard let place = place else {return}
            
            if !place.name.isEmpty {
              
              guard let currLat = Location.lastLocation.last?.coordinate.latitude, let currLong = Location.lastLocation.last?.coordinate.longitude else {return}
              
              self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: place.coordinate.latitude, destinationLong: place.coordinate.longitude, travelMode: TipBuilder.setup.mode, completion: { (status, success) in
                
                if success {
                  
                  let minutes = self.geoTask.totalDurationInSeconds / 60
                  let meters = self.geoTask.totalDistanceInMeters
                  guard let position = self.geoTask.originCoordinate, let route = self.geoTask.overviewPolyline["points"] as? String else {return}
                  let tipView = TipView(placeName: place.name, minutes: minutes, meters: meters, description: tip.description, userName: tip.userName, likes: tip.likes, markerPosition: position, route: route)
                  
                  
                  /*
                  view.walkingDistance.text = "\(minutes)"
                  
                  
                  if minutes == 1 {
                    view.distanceLabel.text = "min"
                  }
                  else {
                    view.distanceLabel.text = "mins"
                  }
                  */
                  
                  completion(tipView, error)
                }
                else {
                  
                  if status == "OVER_QUERY_LIMIT" {
                    sleep(2)
                    self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: place.coordinate.latitude, destinationLong: place.coordinate.longitude, travelMode: TipBuilder.setup.mode, completion: { (status, success) in
                      
                      if success {
                        
                        let minutes = self.geoTask.totalDurationInSeconds / 60
                        let meters = self.geoTask.totalDistanceInMeters
                        guard let position = self.geoTask.originCoordinate, let route = self.geoTask.overviewPolyline["points"] as? String else {return}
                        let tipView = TipView(placeName: place.name, minutes: minutes, meters: meters, description: tip.description, userName: tip.userName, likes: tip.likes, markerPosition: position, route: route)
                        /*
                        let minutes = self.geoTask.totalDurationInSeconds / 60
                        let meters = self.geoTask.totalDistanceInMeters
                        view.walkingDistance.text = "\(minutes)"
                        
                        if minutes == 1 {
                          view.distanceLabel.text = "min"
                        }
                        else {
                          view.distanceLabel.text = "mins"
                        }
                        */
                        
                        completion(tipView, error)
                        
                      }
                      
                    })
                  }
                  else {
                    completion(nil, error)
                  }
                  
                }
                
              })
            }
            
          })
          
        }
        
        
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
             //   view.placeName.text = placeName
                
                self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: lat, destinationLong: long, travelMode: TipBuilder.setup.mode, completion: { (status, success) in
                  
                  if success {
                    
                    let minutes = self.geoTask.totalDurationInSeconds / 60
                    let meters = self.geoTask.totalDistanceInMeters
                    guard let position = self.geoTask.originCoordinate, let route = self.geoTask.overviewPolyline["points"] as? String else {return}
                    let tipView = TipView(placeName: placeName, minutes: minutes, meters: meters, description: tip.description, userName: tip.userName, likes: tip.likes, markerPosition: position, route: route)
                    /*
                    
                    let minutes = self.geoTask.totalDurationInSeconds / 60
                    view.walkingDistance.text = "\(minutes)"
                    let meters = self.geoTask.totalDistanceInMeters
                    
                    if minutes == 1 {
                      view.distanceLabel.text = "min"
                    }
                    else {
                      view.distanceLabel.text = "mins"
                    }
                    */
                    completion(tipView, error)
                  }
                  else {
                    
                    if status == "OVER_QUERY_LIMIT" {
                      sleep(2)
                      self.geoTask.getDirections(lat, originLong: long, destinationLat: Location.lastLocation.last?.coordinate.latitude, destinationLong: Location.lastLocation.last?.coordinate.longitude, travelMode: TipBuilder.setup.mode, completion: { (status, success) in
                        
                        if success {
                          
                          let minutes = self.geoTask.totalDurationInSeconds / 60
                          let meters = self.geoTask.totalDistanceInMeters
                          guard let position = self.geoTask.originCoordinate, let route = self.geoTask.overviewPolyline["points"] as? String else {return}
                          let tipView = TipView(placeName: placeName, minutes: minutes, meters: meters, description: tip.description, userName: tip.userName, likes: tip.likes, markerPosition: position, route: route)
                          
                          /*
                          let minutes = self.geoTask.totalDurationInSeconds / 60
                          let meters = self.geoTask.totalDistanceInMeters
                          view.walkingDistance.text = "\(minutes)"
                          
                          if minutes == 1 {
                            view.distanceLabel.text = "min"
                          }
                          else {
                            view.distanceLabel.text = "mins"
                          }
                          */
                          completion(tipView, error)
                        }
                        
                      })
                    }
                    else {
                    completion(nil, error)
                    }
                  }
                  
                })
                
              }
              
            })
          }
        })
      }
    }
    

  

}
