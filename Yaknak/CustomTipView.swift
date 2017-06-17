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
    @IBOutlet weak var tipDescription: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var walkingDistance: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var placeName: UILabel!
    var label = UILabel()
    var toolTip = ToolTip()
    
   
        
    
    /*
    func setPlaceHolderImage(placeholder: UIImage) {
    self.tipImage.image = placeholder
    }
    
    
    func setTipImage(urlString: String, placeholder: UIImage?, completion: @escaping (Bool) -> ()) {
        self.tipImage.loadImage(urlString: urlString, placeholder: placeholder) { (success) in
            
            if (success) {
            completion(true)
            }
        }
        
        
  //  self.tipImage.loadImageUsingCacheWithUrlString(urlString: urlString, placeholder: placeholder)
}
    
    func setUserImage(urlString: String, placeholder: UIImage?, completion: @escaping (Bool) -> ()) {
        self.userImage.loadImage(urlString: urlString, placeholder: placeholder) { (success) in
            
            if (success) {
                completion(true)
            }
            else {
                if let placeHolder = UIImage(named: "AppIcon") {
            self.setPlaceHolderImage(placeholder: placeHolder)
                }
            }

    }
   
}
    
    */
    
    func showToolTip() {
        self.toolTip.bubbleColor = UIColor.white
        toolTip.edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        toolTip.actionAnimation = .bounce(3)
        let attributes: [String: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.primaryTextColor()]
        let attributedText = NSMutableAttributedString(string: "👈 " + "Swipe left to pass, " + "👉 " + "swipe right for directions", attributes: attributes)
        self.toolTip.show(attributedText: attributedText, direction: .none, maxWidth: 250.0, in: self, from: self.frame, duration: 5)
    }
 
 

}
