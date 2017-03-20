//
//  ProgressOverlay.swift
//  Yaknak
//
//  Created by Sascha Melcher on 19/03/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import UIKit

class ProgressOverlay {

    var overlayView : UIView!
    let percentage : UILabel!
 //   var activityIndicator : UIActivityIndicatorView!
    let progressIndicatorView = CircularLoaderView(frame: CGRect.zero)
    
    class var shared: ProgressOverlay {
        struct Static {
            static let instance: ProgressOverlay = ProgressOverlay()
        }
        return Static.instance
    }
    
    init() {
        self.overlayView = UIView()
        self.percentage = UILabel()
   //     self.activityIndicator = UIActivityIndicatorView()
        
        overlayView.frame = CGRect(0, 0, 50, 50)
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        overlayView.clipsToBounds = true
        overlayView.layer.zPosition = 1
        
   //     activityIndicator.frame = CGRect(0, 0, 40, 40)
   //     activityIndicator.center = CGPoint(overlayView.bounds.width / 2, overlayView.bounds.height / 2)
   //     activityIndicator.activityIndicatorViewStyle = .whiteLarge
   //     activityIndicator.color = UIColor.primaryColor()
        progressIndicatorView.frame = overlayView.bounds
        progressIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.addSubview(progressIndicatorView)
    }
    
    
    public func setSize(width: CGFloat, height: CGFloat) {
        
        overlayView.frame = CGRect(0, 0, width, height)
    }

    /*
    public func reCenterIndicator(view: UIView, navBarHeight: CGFloat) {
        activityIndicator.center = CGPoint(view.bounds.width / 2, view.bounds.height / 2 - navBarHeight)
    }
 
 */
    public func showOverlay(view: UIView) {
        overlayView.center = view.center
        view.addSubview(overlayView)
     //   activityIndicator.startAnimating()
    }
    
    public func hideOverlayView() {
     //   activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
    
    
    public func updateProgress(receivedSize: Int64, totalSize: Int64, percentComplete: Double) {
     progressIndicatorView.progress = CGFloat(receivedSize)/CGFloat(totalSize)
        
        // TODO: update percentage label
    }
    
}
