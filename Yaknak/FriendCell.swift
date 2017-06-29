//
//  FriendCell.swift
//  Yaknak
//
//  Created by Sascha Melcher on 30/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

class FriendCell: UICollectionViewCell {
    
    
    var imageView: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
