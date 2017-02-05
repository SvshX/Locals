//
//  NoDistanceTipView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/02/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

class NoDistanceTipView: UIView {

    @IBOutlet weak var tipImage: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesNumber: UILabel!
    @IBOutlet weak var tipDescription: UITextView!
    
    
    func setTipImage(urlString: String, placeholder: UIImage?, completion: @escaping (Bool) -> ()) {
        self.tipImage.loadImage(urlString: urlString, placeholder: placeholder) { (success) in
            
            if (success) {
                completion(true)
            }
        }
        
    }

}
