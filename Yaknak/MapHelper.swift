//
//  MapHelper.swift
//  Yaknak
//
//  Created by Sascha Melcher on 09/08/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation



class MapHelper {
  
  static let shared = MapHelper()
  let dataService: DataService!

  private init() {
  dataService = DataService()
  }
  
  

}
