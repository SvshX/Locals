//
//  PinMapView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/04/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import GoogleMaps

class PinMapView: UIView {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
   /*
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var unlikeButton: UIButton!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var durationNumber: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var likeNumber: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
  */
    
    override func draw(_ rect: CGRect) {
    //    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
    //    self.userProfileImage.clipsToBounds = true
        
    }
    
    
    func setCameraPosition(_ currentLocation: CLLocationCoordinate2D) {
        self.mapView.camera = GMSCameraPosition(target: currentLocation, zoom: 18, bearing: 0, viewingAngle: 0)
    }
    
}

