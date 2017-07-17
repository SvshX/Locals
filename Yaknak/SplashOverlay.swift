//
//  SplashOverlay.swift
//  Yaknak
//
//  Created by Sascha Melcher on 16/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import UIKit


class SplashOverlay: NSObject, CAAnimationDelegate {

    static var currentOverlay : UIView?
    static var currentOverlayTarget : UIView?
    static var currentLabelText: String?
    static var noConnectionLabel: UILabel!
    static var ellipsisTimer: Timer?
    static var splashView: SplashView!
    
    
    static func show() {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow)
    }
  /*
    static func show(_ labelText: String) {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow, labelText: labelText)
    }
 
    
    static func show(_ overlayTarget : UIView) {
        show(overlayTarget)
    }
 */
    
    static func show(_ overlayTarget : UIView) {
        // Clear it first in case it was already shown
        hide()
        
        
        let labelText: String? = "Splash Overlay"
        
        
        // Create the overlay
        let overlay = UIView(frame: overlayTarget.frame)
        overlay.center = overlayTarget.center
        overlay.alpha = 1
        overlay.backgroundColor = UIColor.white
        overlayTarget.addSubview(overlay)
        overlayTarget.bringSubview(toFront: overlay)
        
        
        /*
        // Create image animation
        
        splashView = Bundle.main.loadNibNamed("SplashView", owner: self, options: nil)![0] as? SplashView
        overlay.addSubview(self.splashView)
        
        splashView.translatesAutoresizingMaskIntoConstraints = false
        overlay.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":splashView]))
        overlay.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":splashView]))
        
        
        var imageNames = ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg", "8.jpg", "9.jpg", "10.jpg", "11.jpg", "11.jpg", "11.jpg", "11.jpg", "11.jpg", "11.jpg"]
        
        
        var images = [CGImage]()
        
        for i in 0..<imageNames.count {
            images.append(UIImage(named: imageNames[i])!.cgImage!)
        }
        
        
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "contents")
      //  keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 3.0
        keyFrameAnimation.calculationMode = kCAAnimationDiscrete
        keyFrameAnimation.isRemovedOnCompletion = false
        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        //   keyFrameAnimation.values = [1.0, 0.9, 1.0, 0.9, 1.0, 0.9, 1.0, 0.9]
        keyFrameAnimation.values = images
        keyFrameAnimation.repeatCount = .infinity
        keyFrameAnimation.fillMode = kCAFillModeForwards
        keyFrameAnimation.keyTimes = [0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2, 0.22, 0.6, 0.7, 0.8, 0.9, 1.0]
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        self.splashView.animatingImageview.layer.add(keyFrameAnimation, forKey: "contents")
        
        
        ellipsisTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateLabelEllipsis(_:)), userInfo: nil, repeats: true)
        
        */
      
        // Create label
        if let textString = labelText {
            noConnectionLabel = UILabel(frame: CGRect(0, 0, 200, 30))
            noConnectionLabel.text = textString
            noConnectionLabel.textColor = UIColor.primaryTextColor()
            noConnectionLabel.font = UIFont.systemFont(ofSize: 20)
            noConnectionLabel.textAlignment = .center
            noConnectionLabel.center = overlay.center
            overlay.addSubview(noConnectionLabel)
        }
 
        
        // Animate the overlay to show
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.0)
        overlay.alpha = overlay.alpha > 0 ? 0 : 1.0
        UIView.commitAnimations()
        
        currentOverlay = overlay
        currentOverlayTarget = overlayTarget
        currentLabelText = labelText
    }
    
    
    func animationDidStart(_ anim: CAAnimation) {}
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
       // let appDelegate  = UIApplication.shared.delegate as! AppDelegate
       // self.dismiss(animated: true, completion: nil)
        SplashOverlay.ellipsisTimer?.invalidate()
        SplashOverlay.ellipsisTimer = nil
        // TODO
        //   appDelegate.authenticateUser()
    }
    
    
    static func updateLabelEllipsis(_ timer: Timer) {
        let messageText: String = SplashOverlay.splashView.dotLabel.text!
        let dotCount: Int = (SplashOverlay.splashView.dotLabel.text?.characters.count)! - messageText.replacingOccurrences(of: ".", with: "").characters.count + 1
        SplashOverlay.splashView.dotLabel.text = "  Finding tips"
        var addOn: String = "."
        if dotCount < 4 {
            addOn = "".padding(toLength: dotCount, withPad: ".", startingAt: 0)
        }
        else {
            
        }
        SplashOverlay.splashView.dotLabel.text = SplashOverlay.splashView.dotLabel.text!.appending(addOn)
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
