//
//  FriendViewCell.swift
//  Yaknak
//
//  Created by Sascha Melcher on 24/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

protocol CollectionViewSelectedProtocol {
    
    func collectionViewSelected(collectionViewItem : Int)
    
}

class FriendViewCell: UICollectionViewCell {
    
    var collectionViewDataSource : UICollectionViewDataSource!
    
    var collectionViewDelegate : UICollectionViewDelegate!
    
    var collectionView : UICollectionView!
    
    var delegate : CollectionViewSelectedProtocol!
    
    var collectionViewOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }
        
        get {
            return collectionView.contentOffset.x
        }
    }
    
    func initializeCollectionViewWithDataSource<D: UICollectionViewDataSource,E: UICollectionViewDelegate>(dataSource: D, delegate :E, forRow row: Int) {
        
        self.collectionViewDataSource = dataSource
        
        self.collectionViewDelegate = delegate
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
     //   let width = 40.0
     //   let height = width + (width / (1.0/3.5))
        flowLayout.itemSize = CGSize(width: 40, height: 63)
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.register(FriendCell.self, forCellWithReuseIdentifier: reuseChildCollectionViewCellIdentifier)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self.collectionViewDataSource
        collectionView.delegate = self.collectionViewDelegate
        collectionView.tag = row
        collectionView.contentInset = UIEdgeInsetsMake(0, 16, 0, 16)
        
        self.addSubview(collectionView)
        
        self.collectionView = collectionView
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
       
        
        NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
 
 
        collectionView.reloadData()
    }
    
}
