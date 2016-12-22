//
//  ProfileGridCell.swift
//  Yaknak
//
//  Created by Sascha Melcher on 20/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class ProfileGridCell: UICollectionViewCell {
    
    
    @IBOutlet weak var tipImage: UIImageView!
    
    
    func setTipImage(tipImage: UIImage) {
        self.tipImage.image = tipImage
        self.tipImage.contentMode = .scaleAspectFill
    }
    
  /*
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   */ 
    
}
