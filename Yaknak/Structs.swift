//
//  Structs.swift
//  Yaknak
//
//  Created by Sascha Melcher on 01/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

public struct TrackerSettings: CustomStringConvertible, Equatable {
    /// Accuracy set
    var accuracy: Accuracy
    
    /// Frequency set
    var frequency: Frequency
    
    /// The type of user activity associated with the location updates.
    /// The location manager uses the information in this property as a cue to determine when location
    /// updates may be automatically paused
    var activity: CLActivityType
    
    /// Distance filter
    /// The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
    var distanceFilter: CLLocationDistance
    
    /// Description of the settings
    public var description: String {
        var desc = "\n\t- Accuracy: '\(accuracy)'"
        desc += "\n\t - Frequency: '\(frequency)'"
        desc += "\n\t - Activity: '\(activity)'"
        desc += "\n\t - Distance filter: '\(distanceFilter)'"
        return desc
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: TrackerSettings, rhs: TrackerSettings) -> Bool {
        return (lhs.accuracy.orderValue == rhs.accuracy.orderValue && lhs.frequency == rhs.frequency && lhs.activity == rhs.activity)
    }
}

public struct LastLocation {
    /// This is the best accurated measured location (may be old, check the `timestamp`)
    private(set) var bestAccurated: CLLocation?
    /// This represent the last measured location by timestamp (may be innacurate, check `accuracy`)
    private(set) var last: CLLocation?
    
    /// Store last value
    ///
    /// - Parameter location: location to set
    mutating internal func set(location: CLLocation) {
        if bestAccurated == nil {
            self.bestAccurated = location
        } else if location.horizontalAccuracy > self.bestAccurated!.horizontalAccuracy {
            self.bestAccurated = location
        }
        if last == nil {
            self.last = location
        } else if location.timestamp > self.last!.timestamp {
            self.last = location
        }
    }
}

extension CLAuthorizationStatus: CustomStringConvertible {
    
    /// Description of the authorization status
    public var description: String {
        switch self {
        case .authorizedAlways:		return "Authorized Always"
        case .authorizedWhenInUse:	return "Authorized When In Use"
        case .denied:				return "Denied"
        case .notDetermined:		return "Not Determined"
        case .restricted:			return "Restricted"
        }
    }
    
}
