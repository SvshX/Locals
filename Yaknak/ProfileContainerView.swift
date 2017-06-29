//
//  ProfileContainerView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 24/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

class ProfileContainerView: UICollectionReusableView {
    
    
    @IBOutlet weak var userProfileImage: ZoomingImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tips: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
