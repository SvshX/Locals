//
//  PhotoThumbnail.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Photos

class PhotoThumbnail: UICollectionViewCell {
        
    var imageManager: PHImageManager?
    
    var imageAsset: PHAsset? {
        didSet {
            self.imageManager?.requestImage(for: imageAsset!, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil) { image, info in
                self.thumbNail.image = image
            }
        }
    }
    
    
    
    @IBOutlet weak var thumbNail: UIImageView!
    
    
    func setThumbnailImage(thumbNailImage: UIImage) {
        self.thumbNail.image = thumbNailImage
    }
    
}
