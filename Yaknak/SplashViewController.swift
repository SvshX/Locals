//
//  SplashViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController, CAAnimationDelegate {
    
    private var loadingMask: CALayer?
    private var windowColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor.white
        let maskImage: UIImage = UIImage(named: "splashIcon")!
        
        loadingAnimationMaskCreate(transparent: false, backgroundColor: color, maskImage: maskImage)
        
        let label = UILabel()
        label.text = "Hang on"
        view.addSubview(label)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLoadingMask()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if self.loadingMask != nil {
            self.view.layer.mask = nil
            self.loadingMask?.superlayer?.removeFromSuperlayer()
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.authenticateUser()
            if let windowColor = self.windowColor {
                appDelegate.window!.backgroundColor = windowColor
                
            }
            self.loadingMask = nil
        }
    }
    
    // MARK: Private methods
    
    /**
     Create a loading mask.
     */
    private func loadingAnimationMaskCreate(transparent: Bool, backgroundColor: UIColor, maskImage: UIImage) {
        
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        let maskSize = CGSize(80, 80)
        
        self.windowColor = appDelegate.window?.backgroundColor
        appDelegate.window!.backgroundColor = backgroundColor
        
        //    UIApplication.sharedApplication().keyWindow?.backgroundColor = backgroundColor
        //    appDelegate.window?.tintColor = UIColor.blueColor()
        
        let screenBounds = UIScreen.main.bounds
        
        let mask = CALayer()
        mask.contents = maskImage.cgImage
        mask.contentsGravity = kCAGravityResizeAspect
        mask.bounds = CGRect(x: 0, y: 0, width: maskSize.width, height: maskSize.height)
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mask.position = CGPoint(x: screenBounds.width/2, y: screenBounds.height/2)
        self.loadingMask = mask
        
        if transparent {
            self.view.layer.mask = mask
        }
        else {
            let backgroundMask = CALayer()
            backgroundMask.frame = self.view.frame
            backgroundMask.backgroundColor = backgroundColor.cgColor
            
            self.view.layer.addSublayer(backgroundMask)
            backgroundMask.addSublayer(mask)
        }
    }
    
    
    // animate the loading mask
    private func animateLoadingMask() {
        if self.loadingMask != nil {
            let keyFrameAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            keyFrameAnimation.delegate = self
            keyFrameAnimation.duration = 4.0
            keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
            keyFrameAnimation.values = [1.0, 0.9, 1.0, 0.9, 1.0, 0.9, 1.0, 0.9] //scale percentages 1.0 = original size
            keyFrameAnimation.keyTimes = [0, 0.6, 1.2, 1.8, 2.4, 3.0, 3.6, 4.0]
            keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
            self.loadingMask!.add(keyFrameAnimation, forKey: "transform.scale")
        }
    }
    
    
}
