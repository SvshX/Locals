//
//  PinMapViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/04/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftLocation

protocol PinLocationDelegate: class {
    func didSelectLocation(_ lat: CLLocationDegrees, _ long: CLLocationDegrees)
    func didClosePinMap(withDone done: Bool)
}

class PinMapViewController: UIViewController {
    
    var pinMapView: PinMapView!
    private var marker: GMSMarker!
    let geoTask = GeoTasks()
    weak var delegate: PinLocationDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initPinMap()
        showAnimate()
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
  
  
  private func initPinMap() {
  
    pinMapView = Bundle.main.loadNibNamed("PinMapView", owner: self, options: nil)![0] as? PinMapView
    pinMapView.mapView.delegate = self
    pinMapView.mapView.isMyLocationEnabled = true
    pinMapView.mapView.settings.myLocationButton = true
    pinMapView.mapView.settings.compassButton = false
  }
  
  
    func setCurrentLocation() {
        guard let coordinates = Location.lastLocation.last?.coordinate else {return}
            pinMapView.setCameraPosition(coordinates)
            pinMapView.doneButton.layer.cornerRadius = 2
            pinMapView.doneButton.isHidden = true
    }
    
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        closeMap(withDone: false)
    }
    
    
    @IBAction func doneTapped(_ sender: Any) {
        closeMap(withDone: true)
    }
  
  
  private func closeMap(withDone done: Bool) {
    delegate?.didClosePinMap(withDone: done)
    removeAnimate()
  }


}



// MARK: - GMSMapViewDelegate

extension PinMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        // reverseGeocodeCoordinate(position.target)
    NSLog("Latitude: " + "\(position.target.latitude), Longitude: \(position.target.longitude)")
        
         self.geoTask.getAddressFromCoordinates(latitude: position.target.latitude, longitude: position.target.longitude) { (address, success) in
            
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
