//
//  FriendCell.swift
//  Yaknak
//
//  Created by Sascha Melcher on 30/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class FriendCell: UICollectionViewCell {
    
    
    var imageView: FBSDKProfilePictureView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = FBSDKProfilePictureView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        contentView.addSubview(imageView)
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
