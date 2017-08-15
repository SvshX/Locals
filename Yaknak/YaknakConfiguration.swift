//
//  YaknakConfiguration.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation

public struct YaknakConfiguration {
  var frequency: YaknakPermissionFrequency = .OnceADay
  var presentInitialPopup: Bool = true
  var presentReEnablePopup: Bool = true
  
  private let week = 60.0*60.0*24.0*7.0
  private let hour = 60.0*60.0
  
  public init(frequency: YaknakPermissionFrequency, presentInitialPopup: Bool, presentReEnablePopup: Bool) {
    self.frequency = frequency
    self.presentInitialPopup = presentInitialPopup
    self.presentReEnablePopup = presentReEnablePopup
  }
  
  func reEnablePopupPresented(permission: YaknakPermissionProtocol) {
    UserDefaults.standard.set(Date(), forKey: permission.identifier)
    UserDefaults.standard.synchronize()
  }
  
  func canPresentReEnablePopup(permission: YaknakPermissionProtocol) -> Bool {
    if !self.presentReEnablePopup {
      return false
    }
    
    switch self.frequency {
    case .OnceADay:
      guard let lastDate = self.lastDateForPermission(identifier: permission.identifier) else {
        return false
      }
      
      return !Calendar.current.isDateInToday(lastDate)
    case .EveryHour:
      guard let lastDate = self.lastDateForPermission(identifier: permission.identifier) else {
        return false
      }
      
      return Calendar.current.compare(lastDate, to: Date(), toGranularity: .hour) == ComparisonResult.orderedDescending
    case .JustOnce:
      guard let _ = self.lastDateForPermission(identifier: permission.identifier) else {
        return true
      }
      
      return false
    case .OnceAWeek:
      guard let lastDate = self.lastDateForPermission(identifier: permission.identifier) else {
        return false
      }
      
      let ti = TimeInterval(week)
      let lastDateInAWeek = lastDate.addingTimeInterval(ti)
      
      return Calendar.current.compare(lastDateInAWeek, to: Date(), toGranularity: .day) == ComparisonResult.orderedDescending
    case .Always:
      return true
    }
  }
  
  private func lastDateForPermission(identifier: String) -> Date? {
    return UserDefaults.standard.object(forKey: identifier) as! Date?
  }
}
