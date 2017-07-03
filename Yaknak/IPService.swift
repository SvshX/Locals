//
//  IPService.swift
//  Yaknak
//
//  Created by Sascha Melcher on 01/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

public struct IPService: CustomStringConvertible {
    
    public typealias IPServiceSuccessCallback = ((CLLocation) -> (Void))
    public typealias IPServiceFailureCallback = ((Error?) -> (Void))
    
    /// Service used for IP Scan
    public var service: IPService.Name
    
    /// Timeout of the operation
    public var timeout: TimeInterval
    
    /// Name of the service
    public enum Name: CustomStringConvertible {
        case freeGeoIP
        case petabyet
        case smartIP
        case telize
        
        public var description: String {
            switch self {
            case .freeGeoIP:	return "FreeGeoIP"
            case .petabyet:		return "Petabyet"
            case .smartIP:		return "SmartIP"
            case .telize:		return "Telize"
            }
        }
        
    }
    
    /// Initialize a new `IPService` with given service
    ///
    /// - Parameter service: service
    /// - Parameter timeout: timeout of the operation
    public init(_ service: Name, timeout: TimeInterval = 15) {
        self.service = service
        self.timeout = timeout
    }
    
    
    /// Description of the IP Service
    public var description: String {
        get { return self.service.description }
    }
    
    
    /// Create a request for given service query
    private var request: NSURLRequest {
        var url: String = ""
        switch self.service {
        case .freeGeoIP:	url = "http://freegeoip.net/json/"
        case .petabyet:		url = "http://api.petabyet.com/geoip/"
        case .smartIP:		url = "http://smart-ip.net/geoip-json/"
        case .telize:		url = "http://www.telize.com/geoip/"
        }
        let request = NSMutableURLRequest(url: URL(string: url)!,
                                          cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData,
                                          timeoutInterval: self.timeout)
        return request
    }
    
    
    /// Get location from current IP address
    ///
    /// - Parameters:
    ///   - success: callback for success
    ///   - fail: callback for fails
    public func getLocationFromIP(success: @escaping IPServiceSuccessCallback, fail: @escaping IPServiceFailureCallback)  {
        self.execute(request: self.request, success, fail)
    }
    
    
    /// All these queries share the same output so we can group them in a single call
    ///
    /// - Parameters:
    ///   - request: request to url
    ///   - success: success callback
    ///   - fail: fail callback
    private func execute(request: NSURLRequest,
                         _ success: @escaping IPServiceSuccessCallback, _ fail: @escaping IPServiceFailureCallback) {
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            do {
                guard let data = data else { // something went wrong
                    fail(error)
                    return
                }
                // fail to deserialize JSON output
                let opts = JSONSerialization.ReadingOptions.init(rawValue: 0)
                guard let json = try JSONSerialization.jsonObject(with: data, options: opts) as? NSDictionary else {
                    fail(LocationError.noData)
                    return
                }
                // failed to get latitude and longitude keys
                guard	let latitude = json.value(forKey: "latitude") as? CLLocationDegrees,
                    let longitude = json.value(forKey: "longitude") as? CLLocationDegrees else {
                        fail(LocationError.noData)
                        return
                }
                let loc = CLLocation(latitude: latitude, longitude: longitude)
                success(loc)
            } catch {
                fail(LocationError.invalidData)
            }
        }
        task.resume()
    }
    
}
