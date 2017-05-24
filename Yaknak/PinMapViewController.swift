//
//  PinMapViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/04/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import GoogleMaps

protocol PinLocationProtocol: class {
    func didSelectLocation(_ lat: CLLocationDegrees, _ long: CLLocationDegrees)
    func didClosePinMap(_ done: Bool)
}

class PinMapViewController: UIViewController {
    
    var pinMapView: PinMapView!
    var marker: GMSMarker!
    let geoTask = GeoTasks()
    
    weak var delegate: PinLocationProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pinMapView = Bundle.main.loadNibNamed("PinMapView", owner: self, options: nil)![0] as? PinMapView
        self.pinMapView.mapView.delegate = self
        self.pinMapView.mapView.isMyLocationEnabled = true
        self.pinMapView.mapView.settings.myLocationButton = true
        self.pinMapView.mapView.settings.compassButton = false
        self.showAnimate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.setCurrentLocation()
           
        })
    }
    
    func removeAnimate() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        }
    }
    
       
    func setCurrentLocation() {
        if let coordinates = LocationService.sharedInstance.currentLocation?.coordinate {
            self.pinMapView.setCameraPosition(coordinates)
            self.pinMapView.doneButton.layer.cornerRadius = 2
            self.pinMapView.doneButton.isHidden = true
        }
    }
    
    

     func getAddressFromCoordinates(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, completionHandler: @escaping ((_ address: String, _ success: Bool) -> Void)) {
        let url = URL(string: "\(Constants.Config.GeoCodeString)latlng=\(latitude),\(longitude)")
        
        let request: URLRequest = URLRequest(url:url!)
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if(error != nil) {
                
                print(error?.localizedDescription)
                completionHandler("", false)
                
            } else {
                
                let kStatus = "status"
                let kOK = "ok"
                let kZeroResults = "ZERO_RESULTS"
                let kAPILimit = "OVER_QUERY_LIMIT"
                let kRequestDenied = "REQUEST_DENIED"
                let kInvalidRequest = "INVALID_REQUEST"
                let kInvalidInput =  "Invalid Input"
                
                
                
                let jsonResult: NSDictionary = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                
                var status = jsonResult.value(forKey: kStatus) as! NSString
                status = status.lowercased as NSString
                
                if(status.isEqual(to: kOK)) {
                    
                    let locationDict = (jsonResult.value(forKey: "results") as! NSArray).firstObject as! NSDictionary
                    
                    let formattedAddress = locationDict.object(forKey: "formatted_address") as! NSString
                    
                    let geometry = locationDict.object(forKey: "geometry") as! NSDictionary
                    let location = geometry.object(forKey: "location") as! NSDictionary
                    _ = location.object(forKey: "lat") as! Double
                    _ = location.object(forKey: "lng") as! Double
                    _ = locationDict.object(forKey: "place_id") as! NSString
                    
               //     self.addPlaceCoordinates(CLLocationCoordinate2D(latitude: lat, longitude: lng), placeId as String)
                    completionHandler(formattedAddress as String, true)
                    
                }
                else if(!status.isEqual(to: kZeroResults) && !status.isEqual(to: kAPILimit) && !status.isEqual(to: kRequestDenied) && !status.isEqual(to: kInvalidRequest)) {
                    
                    completionHandler(status as String, false)
                    
                }
                    
                else {
                    
                    completionHandler(status as String, false)
                    
                }
                
            }
            
        })
        
        task.resume()
        
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.delegate?.didClosePinMap(false)
        self.removeAnimate()
    }
    
    
    @IBAction func doneTapped(_ sender: Any) {
        self.delegate?.didClosePinMap(true)
        self.removeAnimate()
    }
    


}



// MARK: - GMSMapViewDelegate

extension PinMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        // reverseGeocodeCoordinate(position.target)
    NSLog("Latitude: " + "\(position.target.latitude), Longitude: \(position.target.longitude)")
        
         self.getAddressFromCoordinates(position.target.latitude, position.target.longitude) { (address, success) in
            
            if success {
                DispatchQueue.main.async {
                    self.pinMapView.doneButton.isHidden = false
            self.pinMapView.addressLabel.text = address
            }
                self.delegate?.didSelectLocation(position.target.latitude, position.target.longitude)
            
            }
    
}
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        self.setCurrentLocation()
      //  self.marker.position = mapView.camera.target
        return false
    }
    
 
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        //  addressLabel.lock()
         DispatchQueue.main.async {
        self.pinMapView.addressLabel.text = "Loading..."
        self.pinMapView.doneButton.isHidden = true
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
         DispatchQueue.main.async {
        self.pinMapView.addressLabel.text = "Loading..."
        self.pinMapView.doneButton.isHidden = true
        }
    }


}
