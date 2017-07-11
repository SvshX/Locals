//
//  Observer.swift
//  Yaknak
//
//  Created by Sascha Melcher on 09/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


var MyObservationContext = 0

class Observer: NSObject {
    
    func startObservingKeys(geofence: GeofenceModel) {
        let options = NSKeyValueObservingOptions([.new, .old])
        geofence.addObserver(self, forKeyPath: "keys", options: options, context: &MyObservationContext)
    }
    
    func stopObservingPerson(geofence: GeofenceModel) {
        geofence.removeObserver(self, forKeyPath: "keys", context: &MyObservationContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard keyPath != nil else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if context == &MyObservationContext {
        print("Keys changed: \(String(describing: change))")
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
      
        /*
        switch (keyPath!, context) {
        case("keys", MyObservationContext):
            print("First name changed: \(change)")
            
        case(_, MyObservationContext):
            assert(false, "unknown key path")
            
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
 */
        
    }
    
}
