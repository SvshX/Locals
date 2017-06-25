//
//  ChildCollectionViewDelegate.swift
//  Yaknak
//
//  Created by Sascha Melcher on 24/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit


class ChildCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell no: \(indexPath.row) of collection view: \(collectionView.tag)")
    }
    
}
