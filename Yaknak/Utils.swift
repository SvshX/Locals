//
//  Utils.swift
//  Yaknak
//
//  Created by Sascha Melcher on 13/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


class Utils {

    static func containSameElements<T: Comparable>(_ array1: [T], _ array2: [T]) -> Bool {
        guard array1.count == array2.count else {
            return false // No need to sort if they already have different counts
        }
        
        return array1.sorted() == array2.sorted()
    }
    
    
    // Helper methods to determine radius
    static func determineRadius() -> Double? {
        return milesToKm(Double(SettingsManager.shared.defaultWalkingDuration) * 0.035)
    }
    
    
    static func milesToKm(_ miles: Double) -> Double {
        if miles > 0 {
            return miles * 1609.344 / 1000
        }
        else {
            return 0
        }
    }
    
    
    static func delay(withSeconds seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
  
  
  static func screenHeight() -> CGFloat {
    return UIScreen.main.bounds.height
  }
  
    // Redirect to enable location tracking in settings
    static func redirectToSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(settingsUrl as URL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            if let settingsURL = URL(string: UIApplicationOpenSettingsURLString + Bundle.main.bundleIdentifier!) {
                UIApplication.shared.openURL(settingsURL as URL)
            }
        }
    }
  
  
  static func openMailClient() {
    let mailURL = URL(string: "message://")!
    if UIApplication.shared.canOpenURL(mailURL) {
      UIApplication.shared.openURL(mailURL)
    }
  }

}
