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
    @IBOutlet weak var walkingDistance: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var tipDescription: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var walkingIcon: UIImageView!
    @IBOutlet weak var likesIcon: UIImageView!
    
  
    func setTipImage(urlString: String, placeholder: UIImage?, completion: @escaping (Bool) -> ()) {
        self.tipImage.loadImage(urlString: urlString, placeholder: placeholder) { (success) in
            
            if (success) {
                completion(true)
            }
        }


}
}
