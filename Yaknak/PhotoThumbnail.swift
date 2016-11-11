//
//  PhotoThumbnail.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class PhotoThumbnail: UICollectionViewCell {
        
    
    @IBOutlet weak var thumbNail: UIImageView!
    
    
    func setThumbnailImage(thumbNailImage: UIImage) {
        self.thumbNail.image = thumbNailImage
    }
    
}
