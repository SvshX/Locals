//
//  MapView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 07/12/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import GoogleMaps

class MapView: UIView {

  
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var unlikeButton: UIButton!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var durationNumber: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var likeNumber: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    
    
    override func draw(_ rect: CGRect) {
        self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
        self.userProfileImage.clipsToBounds = true

    }
    
    
    func setCameraPosition(currentLocation: CLLocation) {
    self.mapView.camera = GMSCameraPosition(target: currentLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    }

}
