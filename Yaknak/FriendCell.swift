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
    var nameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 0, y: 8, width: frame.width, height: 40))
        self.addSubview(imageView)
        nameLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.size.height + 8, width: frame.size.width, height: 15))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 11)
        nameLabel.textColor = UIColor.primaryText()
        contentView.addSubview(nameLabel)
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.layer.cornerRadius = CGFloat(roundf(Float(self.imageView.frame.size.width/2.0)))
        self.imageView.layer.masksToBounds = true
        self.imageView.clipsToBounds = true
    }
}
