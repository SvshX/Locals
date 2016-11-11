//
//  HelpPopUpViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class HelpPopUpViewController: UIViewController {

    
 //   @IBOutlet weak var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        showAnimate()
        self.popUpView.layer.cornerRadius = 10
        /*
         let maskPath = UIBezierPath(roundedRect: self.popUpView.bounds,byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: 10.0, height: 10.0))
         let maskLayer = CAShapeLayer(layer: maskPath)
         maskLayer.frame = self.popUpView.bounds
         maskLayer.path = maskPath.CGPath
         self.popUpView.layer.mask = maskLayer
         */
        
    }
    
    
    @IBAction func closePopUp(sender: AnyObject) {
        self.removeAnimate()
    }
    
    
    func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
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


}
