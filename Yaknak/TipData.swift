//
//  TipView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 18/08/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


struct TipData {

   var tip: Tip?
   var placeName: String?
   var minutes: UInt?
   var meters: UInt?
   var markerPosition: CLLocationCoordinate2D?
   var route: String?
  
  
  public init(tip: Tip? = nil, placeName: String? = nil, minutes: UInt? = nil, meters: UInt? = nil, markerPosition: CLLocationCoordinate2D? = nil, route: String? = nil) {
  
    self.tip = tip
    self.placeName = placeName
    self.minutes = minutes
    self.meters = meters
    self.markerPosition = markerPosition
    self.route = route
  }
}
