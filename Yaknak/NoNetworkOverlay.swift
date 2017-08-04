//
//  NoNetworkView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 04/04/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation

class NoNetworkOverlay {

    static var currentOverlay : UIView?
    static var currentOverlayTarget : UIView?
    static var currentLabelText: String?
    static var noConnectionLabel: UILabel!
    
    
    static func show() {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow)
    }
    
    static func show(_ labelText: String) {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow, labelText: labelText)
    }
    
    static func show(_ overlayTarget : UIView) {
        show(overlayTarget, labelText: nil)
    }
    
    static func show(_ overlayTarget : UIView, labelText: String?) {
        // Clear it first in case it was already shown
        hide()
        
      
        
        // Create the overlay
        let overlay = UIView(frame: overlayTarget.frame)
        overlay.center = overlayTarget.center
        overlay.alpha = 0
        overlay.backgroundColor = UIColor.white
        overlayTarget.addSubview(overlay)
        overlayTarget.bringSubview(toFront: overlay)
        
        
        
        // Create label
        if let textString = labelText {
            noConnectionLabel = UILabel(frame: CGRect(0, 0, 200, 30))
            noConnectionLabel.text = textString
            noConnectionLabel.textColor = UIColor.primaryText()
            noConnectionLabel.font = UIFont.systemFont(ofSize: 20)
            noConnectionLabel.textAlignment = .center
            noConnectionLabel.center = overlay.center
            overlay.addSubview(noConnectionLabel)
        }
        
        // Animate the overlay to show
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        overlay.alpha = overlay.alpha > 0 ? 0 : 1.0
        UIView.commitAnimations()
        
        currentOverlay = overlay
        currentOverlayTarget = overlayTarget
        currentLabelText = labelText
    }
    
    
    static func hide() {
        if currentOverlay != nil {
            
            currentOverlay?.removeFromSuperview()
            currentOverlay =  nil
            currentLabelText = nil
            currentOverlayTarget = nil
        }
    }

}
