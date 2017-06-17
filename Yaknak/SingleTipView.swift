//
//  SingleTipView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class SingleTipView: UIView {
  
    @IBOutlet weak var tipImage: UIImageView!
    @IBOutlet weak var tipDescription: UITextView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var walkingIcon: UIImageView!
    @IBOutlet weak var walkingDistance: UILabel!
    @IBOutlet weak var walkingLabel: UILabel!
    @IBOutlet weak var likeIcon: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var likeIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var walkingLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tipImageHeightConstraint: NSLayoutConstraint!
    
  
    /*
    func setTipImage(urlString: String, placeholder: UIImage?, completion: @escaping (Bool) -> ()) {
        self.tipImage.loadImage(urlString: urlString, placeholder: placeholder) { (success) in
            
            if (success) {
                completion(true)
            }
        }

}
 */
}
