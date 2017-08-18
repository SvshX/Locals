//
//  TipView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 18/08/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


struct TipView {

   var placeName: String?
   var minutes: UInt?
   var meters: UInt?
   var description: String?
   var userName: String?
   var likes: Int?
   var markerPosition: CLLocationCoordinate2D?
   var route: String?
  
  
  public init(placeName: String? = nil, minutes: UInt? = nil, meters: UInt? = nil, description: String? = nil, userName: String? = nil, likes: Int? = nil, markerPosition: CLLocationCoordinate2D? = nil, route: String? = nil) {
  
    self.placeName = placeName
    self.minutes = minutes
    self.meters = meters
    self.description = description
    self.userName = userName
    self.likes = likes
    self.markerPosition = markerPosition
    self.route = route
  }
}
