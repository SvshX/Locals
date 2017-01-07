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
    @IBOutlet weak var by: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    
    func setPlaceHolderImage(placeholder: UIImage) {
    self.tipImage.image = placeholder
    }
    
    
    func setTipImage(urlString: String, placeholder: UIImage?, completion: @escaping (Bool) -> ()) {
        self.tipImage.loadTipImage(urlString: urlString, placeholder: placeholder) { (success) in
            
            if (success) {
            completion(true)
            }
        }
        
        
  //  self.tipImage.loadImageUsingCacheWithUrlString(urlString: urlString, placeholder: placeholder)
}
    
    func setUserImage(urlString: String) {
        self.userImage.loadImageUsingCacheWithUrlString(urlString: urlString, placeholder: nil)
    }
    
    
   
}
