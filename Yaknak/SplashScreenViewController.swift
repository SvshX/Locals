//
//  SplashViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit


class SplashScreenViewController: UIViewController, CAAnimationDelegate {
    
 
    var ellipsisTimer: Timer?
    var splashView: SplashView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splashView = Bundle.main.loadNibNamed("SplashView", owner: self, options: nil)![0] as? SplashView
        self.view.addSubview(self.splashView)
        self.splashView.fillSuperview()
        
        var imageNames = ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg", "8.jpg", "9.jpg", "10.jpg", "11.jpg", "11.jpg", "11.jpg", "11.jpg", "11.jpg", "11.jpg"]
        
 
        var images = [CGImage]()
        
        for i in 0..<imageNames.count {
            images.append(UIImage(named: imageNames[i])!.cgImage!)
        }
        
       
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "contents")
        keyFrameAnimation.delegate = self
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
        
         ellipsisTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SplashScreenViewController.updateLabelEllipsis(_:)), userInfo: nil, repeats: true)
    }
    
    
    func animationDidStart(_ anim: CAAnimation) {}
   
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.dismiss(animated: true, completion: nil)
        ellipsisTimer?.invalidate()
        ellipsisTimer = nil
    }
    
    
    func updateLabelEllipsis(_ timer: Timer) {
        let messageText: String = self.splashView.dotLabel.text!
        let dotCount: Int = (self.splashView.dotLabel.text?.characters.count)! - messageText.replacingOccurrences(of: ".", with: "").characters.count + 1
        self.splashView.dotLabel.text = "  Finding tips"
        var addOn: String = "."
        if dotCount < 4 {
            addOn = "".padding(toLength: dotCount, withPad: ".", startingAt: 0)
        }
        splashView.dotLabel.text = self.splashView.dotLabel.text!.appending(addOn)
    }
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}
