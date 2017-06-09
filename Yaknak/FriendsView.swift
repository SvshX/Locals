//
//  FriendsView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 07/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

class FriendsView: UICollectionReusableView {

    
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var leftLine: LineView!
    @IBOutlet weak var rightLine: LineView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
