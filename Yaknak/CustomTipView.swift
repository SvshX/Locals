//
//  CustomTipView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class CustomTipView: UIView {

    @IBOutlet weak var tipImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var distanceImage: UIImageView!
    @IBOutlet weak var walkingDistance: UILabel!
    @IBOutlet weak var tipDescription: UITextView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var tipViewHeightConstraint: NSLayoutConstraint!
    
    
    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.tipImage.bounds
        gradient.colors = [UIColor.clear.withAlphaComponent(0.5), UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black
            .withAlphaComponent(0.9).cgColor, UIColor.black.cgColor]
        gradient.locations = [0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8]
        self.tipImage.layer.insertSublayer(gradient, at: 0)
        
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.clipsToBounds = true
        self.userImage.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
        self.userImage.layer.borderWidth = 0.8
    }
    
    func setTipImage(urlString: String) {
    self.tipImage.loadImageUsingCacheWithUrlString(urlString: urlString)
    }
    
    func setUserImage(urlString: String) {
        self.userImage.loadImageUsingCacheWithUrlString(urlString: urlString)
    }
    
    
   
}
