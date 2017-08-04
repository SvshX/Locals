//
//  LoadingIndicatorView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 23/03/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


class ProgressOverlay {
    
    static var currentOverlay : UIView?
    static var currentOverlayTarget : UIView?
    static var currentLoadingText: String?
    static var progressCircle: CircularLoaderView!
    static var percentageLabel: UILabel!
    
    
    static func show() {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow)
    }
    
    static func show(_ loadingText: String) {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow, loadingText: loadingText)
    }
    
    static func show(_ overlayTarget : UIView) {
        show(overlayTarget, loadingText: nil)
    }
    
    static func show(_ overlayTarget : UIView, loadingText: String?) {
        // Clear it first in case it was already shown
        hide()
        
        // register device orientation notification
        NotificationCenter.default.addObserver(
            self, selector:
            #selector(ProgressOverlay.rotated),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil)
        
        // Create the overlay
        let overlay = UIView(frame: overlayTarget.frame)
        overlay.center = overlayTarget.center
        overlay.alpha = 0
        overlay.backgroundColor = UIColor.black
        overlayTarget.addSubview(overlay)
        overlayTarget.bringSubview(toFront: overlay)
        
        
        progressCircle = CircularLoaderView()
        progressCircle.center = overlay.center
        // Create and animate the activity indicator
      //  let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
      //  indicator.center = overlay.center
      //  indicator.startAnimating()
        overlay.addSubview(progressCircle)
    //    overlay.addSubview(indicator)
        
        
        // Create label
        if let textString = loadingText {
            percentageLabel = UILabel(frame: CGRect(0, 0, 80, 30))
            percentageLabel.text = textString
            percentageLabel.textColor = UIColor.smokeWhite()
            percentageLabel.font = UIFont.boldSystemFont(ofSize: 17)
            percentageLabel.textAlignment = .center
            percentageLabel.center = CGPoint(x: progressCircle.center.x, y: progressCircle.center.y)
            overlay.addSubview(percentageLabel)
        }
        
        // Animate the overlay to show
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        overlay.alpha = overlay.alpha > 0 ? 0 : 0.7
        UIView.commitAnimations()
        
        currentOverlay = overlay
        currentOverlayTarget = overlayTarget
        currentLoadingText = loadingText
    }
    
    static func hide() {
        if currentOverlay != nil {
            
            // unregister device orientation notification
            NotificationCenter.default.removeObserver(self,                                                      name: NSNotification.Name.UIDeviceOrientationDidChange,                                                      object: nil)
            
            currentOverlay?.removeFromSuperview()
            currentOverlay =  nil
            currentLoadingText = nil
            currentOverlayTarget = nil
        }
    }
    
    static func updateProgress(receivedSize: Int64, totalSize: Int64, percentageComplete: Double) {
        progressCircle.progress = CGFloat(receivedSize)/CGFloat(totalSize)
        percentageLabel.text = "\(Int(percentageComplete))%"
        
        
    
    }
    
    @objc private static func rotated() {
        // handle device orientation change by reactivating the loading indicator
        if currentOverlay != nil {
            show(currentOverlayTarget!, loadingText: currentLoadingText)
        }
    }
}
