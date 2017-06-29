//
//  ProfileGridCell.swift
//  Yaknak
//
//  Created by Sascha Melcher on 20/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit



class ProfileGridCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
