//
//  CLLocationManager.swift
//  Yaknak
//
//  Created by Sascha Melcher on 01/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

extension CLLocationManager {
    
    /// Stop monitoring all regions
    public func stopMonitoringAllRegions() {
        self.monitoredRegions.forEach { self.stopMonitoring(for: $0) }
    }
    
    public class func getLocation(accuracy: Accuracy, frequency: Frequency, timeout: TimeInterval? = nil, success: @escaping LocObserver.onSuccess, error: @escaping LocObserver.onError) -> LocationRequest {
        return Location.getLocation(accuracy: accuracy, frequency: frequency, timeout: timeout, success: success, error: error)
    }
    
    public func stopAllLocationServices() {
        self.stopUpdatingLocation()
        self.stopMonitoringSignificantLocationChanges()
        self.disallowDeferredLocationUpdates()
    }
    
}
