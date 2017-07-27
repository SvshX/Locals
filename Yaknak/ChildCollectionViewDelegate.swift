//
//  ChildCollectionViewDelegate.swift
//  Yaknak
//
//  Created by Sascha Melcher on 24/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

protocol TapFriendDelegate: class {
    func openProfile(from user: MyUser)
}

class ChildCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    
    var friends: [MyUser]!
    weak var friendDelegate: TapFriendDelegate?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell no: \(indexPath.row) of collection view: \(collectionView.tag)")
        friendDelegate?.openProfile(from: friends[indexPath.row])
    }
    
}
