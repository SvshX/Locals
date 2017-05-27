//
//  ProfileHeaderView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 25/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

class ProfileHeaderView: UICollectionReusableView {
    
    
    @IBOutlet weak var userProfileImage: ZoomingImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var tips: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
