//
//  RoundedShadowButton.swift
//  Yaknak
//
//  Created by Sascha Melcher on 16/08/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {
  
  var shadowLayer: CAShapeLayer!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if shadowLayer == nil {
      shadowLayer = CAShapeLayer()
      shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
      shadowLayer.fillColor = UIColor.clear.cgColor
      
      shadowLayer.shadowColor = UIColor.darkGray.cgColor
      shadowLayer.shadowPath = shadowLayer.path
      shadowLayer.shadowOffset = CGSize(width: 1.0, height: 1.0)
      shadowLayer.shadowOpacity = 0.7
      shadowLayer.shadowRadius = 1
      
      layer.insertSublayer(shadowLayer, at: 0)
      //layer.insertSublayer(shadowLayer, below: nil) // also works
    }
  }
  
}
