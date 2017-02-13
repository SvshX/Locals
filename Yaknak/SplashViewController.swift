//
//  SplashViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit


class SplashScreenViewController: UIViewController, CAAnimationDelegate {
    
 //   private var loadingMask: CALayer?
 //   private var windowColor: UIColor?
    private var ellipsisTimer: Timer?
    var splashView: SplashView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //    let color = UIColor.white
    //    let maskImage: UIImage = UIImage(named: "splashIcon")!
        
        self.splashView = Bundle.main.loadNibNamed("SplashView", owner: self, options: nil)![0] as? SplashView
     //   self.splashView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.splashView)
        
        self.splashView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":self.splashView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":self.splashView]))
    
        
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
        keyFrameAnimation.repeatCount = 1
        keyFrameAnimation.fillMode = kCAFillModeForwards
        keyFrameAnimation.keyTimes = [0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2, 0.22, 0.6, 0.7, 0.8, 0.9, 1.0]
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        self.splashView.animatingImageview.layer.add(keyFrameAnimation, forKey: "contents")
        

         ellipsisTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SplashScreenViewController.updateLabelEllipsis(_:)), userInfo: nil, repeats: true)
    }
    
    
    func animationDidStart(_ anim: CAAnimation) {}
   
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: true, completion: nil)
        ellipsisTimer?.invalidate()
        ellipsisTimer = nil
        appDelegate.authenticateUser()
    }
    
    
    func updateLabelEllipsis(_ timer: Timer) {
        let messageText: String = self.splashView.dotLabel.text!
        let dotCount: Int = (self.splashView.dotLabel.text?.characters.count)! - messageText.replacingOccurrences(of: ".", with: "").characters.count + 1
        self.splashView.dotLabel.text = "  Finding tips"
        var addOn: String = "."
        if dotCount < 4 {
            addOn = "".padding(toLength: dotCount, withPad: ".", startingAt: 0)
        }
        else {
       //
       //     let appDelegate  = UIAppliself.dismiss(animated: true, completion: nil)
       //     ellipsisTimer?.invalidate()
       //     ellipsisTimer = nilcation.shared.delegate as! AppDelegate
       //     appDelegate.authenticateUser()
        }
        splashView.dotLabel.text = self.splashView.dotLabel.text!.appending(addOn)
    }
    
    
    private func setupLabelConstraints(label: UILabel) {
        
        
        let widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.size.width)
        
        let heightConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20)
        
        let centerXConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let centerYConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 70)
        
        self.view.addConstraints([centerXConstraint, centerYConstraint, widthConstraint, heightConstraint])
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     //   animateLoadingMask()
    }
    
    /*
    
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
 
 */
    
    // MARK: Private methods
    
    /**
     Create a loading mask.
     */
  /*
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
            keyFrameAnimation.isRemovedOnCompletion = true
            keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
            keyFrameAnimation.values = [1.0, 0.9, 1.0, 0.9, 1.0, 0.9, 1.0, 0.9] //scale percentages 1.0 = original size
            keyFrameAnimation.keyTimes = [0, 0.6, 1.2, 1.8, 2.4, 3.0, 3.6, 4.0]
            keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
            self.loadingMask!.add(keyFrameAnimation, forKey: "transform.scale")
        }
    }
    */
    
}
