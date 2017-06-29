//
//  ChildCollectionViewDataSource.swift
//  Yaknak
//
//  Created by Sascha Melcher on 24/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import Kingfisher

class ChildCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    
    var friends : [MyUser]!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseChildCollectionViewCellIdentifier, for: indexPath) as! FriendCell
        
        if let url = URL(string: self.friends[indexPath.row].photoUrl) {
            cell.imageView.kf.indicatorType = .activity
            let processor = ResizingImageProcessor(referenceSize: CGSize(width: 250, height: 250), mode: .aspectFill)
            cell.imageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                print("\(indexPath.row): \(receivedSize)/\(totalSize)")
                
            }) { (image, error, cacheType, imageUrl) in
                
                print("\(indexPath.row): \(cacheType)")
            }
        }
        
        return cell
    }
    
}
