//
//  NoLocationOverlay.swift
//  Yaknak
//
//  Created by Sascha Melcher on 02/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


protocol EnableLocationDelegate: class {
    
    func onButtonTapped()
}

class NoLocationOverlay {

    static var currentOverlay : UIView?
    static var currentOverlayTarget : UIView?
    static var image: UIImageView!
    static var title: UILabel!
    static var message: UILabel!
    static var enableButton: UIButton!
    static weak var delegate: EnableLocationDelegate?
    
    
    static func show() {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow)
    }
    
    
    static func show(_ overlayTarget : UIView) {
        // Clear it first in case it was already shown
        hide()
        
        // Create the overlay
        
        let gradientOverlay = GradientView(frame: overlayTarget.frame)
        gradientOverlay.gradientLayer.colors = [UIColor(red: 255/255, green: 85/255, blue: 29/255, alpha: 1).cgColor, UIColor(red: 254/255, green: 12/255, blue: 149/255, alpha: 1).cgColor]
        gradientOverlay.gradientLayer.gradient = GradientPoint.topLeftBottomRight.draw()
        gradientOverlay.center = overlayTarget.center
        gradientOverlay.alpha = 0
        overlayTarget.addSubview(gradientOverlay)
        overlayTarget.bringSubview(toFront: gradientOverlay)
        
        
        // Create image
        
        image = UIImageView()
        if let img = UIImage(named: "oh-emoji") {
        image.image = img
            overlayTarget.addSubview(image)
        }
        
        
        // Create labels
        
            title = UILabel()
            title.text = "Your location is disabled"
            title.textColor = UIColor.smokeWhiteColor()
            title.font = UIFont.boldSystemFont(ofSize: 26)
            title.textAlignment = .center
            title.numberOfLines = 2
            gradientOverlay.addSubview(title)
        
        message = UILabel()
        message.numberOfLines = 2
        message.text = "We need access to your location to make Yaknak work."
        message.textColor = UIColor.smokeWhiteColor()
        message.font = UIFont.systemFont(ofSize: 17)
        message.textAlignment = .center
        gradientOverlay.addSubview(message)
        
        enableButton = RoundRectButton()
        enableButton.setTitle("enable location", for: .normal)
        enableButton.setTitleColor(UIColor.primaryTextColor(), for: .normal)
        enableButton.layer.cornerRadius = 10
        enableButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        gradientOverlay.addSubview(enableButton)
        
        
        image.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        message.translatesAutoresizingMaskIntoConstraints = false
        enableButton.translatesAutoresizingMaskIntoConstraints = false
        
        title.centerXAnchor.constraint(equalTo: overlayTarget.centerXAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: overlayTarget.centerYAnchor).isActive = true
        title.widthAnchor.constraint(equalToConstant: 280).isActive = true
        image.centerXAnchor.constraint(equalTo: overlayTarget.centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: overlayTarget.centerYAnchor, constant: -120).isActive = true
        message.centerXAnchor.constraint(equalTo: overlayTarget.centerXAnchor).isActive = true
        message.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16).isActive = true
        message.widthAnchor.constraint(equalToConstant: 260).isActive = true
        enableButton.centerXAnchor.constraint(equalTo: overlayTarget.centerXAnchor).isActive = true
        enableButton.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 32).isActive = true
        enableButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
        enableButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
        // Animate the overlay to show
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        gradientOverlay.alpha = gradientOverlay.alpha > 0 ? 0 : 1.0
        UIView.commitAnimations()
        
        currentOverlay = gradientOverlay
        currentOverlayTarget = overlayTarget
    }
    
    
    static func hide() {
        if currentOverlay != nil {
            
            image.removeFromSuperview()
            currentOverlay?.removeFromSuperview()
            currentOverlay =  nil
            currentOverlayTarget = nil
        }
    }
    
    @objc static func didTapButton(_ sender: UIButton) {
        NoLocationOverlay.delegate?.onButtonTapped()
    }

}
