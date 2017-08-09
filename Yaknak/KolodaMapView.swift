//
//  KolodaMapView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 07/08/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit


class KolodaMapView: OverlayView {
  
  @IBOutlet weak var userPic: UIImageView!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var duration: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var likes: UILabel!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var mapView: GMSMapView!
  

  override func draw(_ rect: CGRect) {
    userPic.layer.cornerRadius = self.userPic.frame.size.width / 2
    userPic.clipsToBounds = true
  }
  
  
  func setCameraPosition(atLocation currentLocation: CLLocation) {
    mapView.camera = GMSCameraPosition(target: currentLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
  }  

}
