//
//  LocationService.swift
//  Yaknak
//
//  Created by Sascha Melcher on 01/12/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import CoreLocation

/*
protocol LocationServiceDelegate {
    func tracingLocation(_ currentLocation: CLLocation)
    func tracingLocationDidFailWithError(_ error: NSError)
    func permissionReceived(_ received: Bool)
}
 */

class LocationService: NSObject, CLLocationManagerDelegate {
    static let sharedInstance: LocationService = {
        let instance = LocationService()
        return instance
    }()
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
 //   var delegate: LocationServiceDelegate?

    
    var onLocationTracingEnabled: ((_ enabled: Bool)->())?
    var onTracingLocation: ((_ currentLocation: CLLocation)->())?
    var onTracingLocationDidFailWithError: ((_ error: NSError)->())?
    var onSettingsPrompt: (()->())?
    
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
      
        /*
        if CLLocationManager.authorizationStatus() == .notDetermined {

            // 1. requestAlwaysAuthorization
            // 2. requestWhenInUseAuthorization
            locationManager.requestWhenInUseAuthorization()
        }
      */
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
        locationManager.distanceFilter = 10 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    
    func minutesFromTimeInterval(interval: TimeInterval) -> Int {
        let ti = NSInteger(interval)
        let m = Int(ti) / 60
        return m
    }
    
    
    func geocodeAddressString(address:String, completion:@escaping (_ placemark:CLPlacemark?, _ error:NSError?)->Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) -> Void in
            if error == nil{
                if (placemarks?.count)! > 0{
                    completion((placemarks?[0]), error as NSError?)
                }
            }
            else{
                completion(nil, error as NSError?)
            }
        })
    }
    
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last(current) location
        currentLocation = location
        
        // use for real time update location
    //    updateLocation(location)
        onTracingLocation?(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // do on error
        onTracingLocationDidFailWithError?(error as NSError)

      //  updateLocationDidFailWithError(error as NSError)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
   //     guard let delegate = self.delegate else {
   //         return
   //     }
        
        switch status {
            
        case .notDetermined:
             locationManager?.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            if (!UserDefaults.standard.bool(forKey: "isTracingLocationEnabled")) {
                UserDefaults.standard.set(true, forKey: "isTracingLocationEnabled")
            }
            onLocationTracingEnabled?(true)
         //   delegate.permissionReceived(locationAuthorised())
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            if (UserDefaults.standard.bool(forKey: "isTracingLocationEnabled")) {
                UserDefaults.standard.removeObject(forKey: "isTracingLocationEnabled")
            }
            
            if (UserDefaults.standard.bool(forKey: "askForSettings_location")) {
                onSettingsPrompt?()
                UserDefaults.standard.removeObject(forKey: "askForSettings_location")
            }
            else {
                onLocationTracingEnabled?(false)
                UserDefaults.standard.set(true, forKey: "askForSettings_location")
            }
        
            break
            
        default:
            break
            
        }
        
        
       /*
        if (status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.notDetermined) {
            // The user denied authorization
            self.locationIsEnabled = false
        } else if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            // The user accepted authorization
            self.locationIsEnabled = true
            delegate.permissionReceived(locationAuthorised())
        }
        */
        
    }
 /*
    // Private function
    fileprivate func updateLocation(_ currentLocation: CLLocation) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation(currentLocation)
    }
    
    fileprivate func updateLocationDidFailWithError(_ error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error)
    }
    */
}
