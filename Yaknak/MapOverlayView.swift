//
//  MapOverlayView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 19/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import Koloda

class MapOverlayView: OverlayView {

    
     @IBOutlet weak var overlayImageView: UIImageView!
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = nil
              //  overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                overlayImageView.image = UIImage(named: Constants.Images.TipImagePlaceHolder)
            default:
                overlayImageView.image = nil
            }
            
        }
    }

}
