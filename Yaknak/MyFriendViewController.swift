//
//  MyFriendViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 27/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import Kingfisher


class MyFriendViewController: UIViewController {
    
    var user: MyUser!
    let dataService = DataService()
    var tips: [Tip] = []
    var friends: [MyUser] = []
    var showTips = true
    var tabBarVC: TabBarController!
    var emptyView: UIView!
    var dataProvider : UICollectionViewDataSource!
    var storedOffsets: [Int: CGFloat] = [:]
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        setLoadingOverlay()
        setData()
        reloadTipGrid()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private func setData() {
      self.collectionView.dataSource = dataProvider
    }

  

    private func setupView() {
      guard let layout = collectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout else {return}
        layout.sectionHeadersPinToVisibleBounds = true
        layout.horizontalAlignment = .left
        layout.minimumInteritemSpacing = 1
        layout.estimatedItemSize = CGSize(120, 120)
        collectionView.register(ProfileGridCell.self, forCellWithReuseIdentifier: reuseGridViewCellIdentifier)
        collectionView.register(UINib(nibName: "ProfileContainerView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseProfileViewIdentifier)
        self.emptyView = UIView(frame: CGRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.emptyView.backgroundColor = UIColor.white
        self.toggleUI(false)
    }
    
    
    private func setFloatingButton() {
        if let image = UIImage(named: "cancel_button") {
        let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            button.setImage(image, for: .normal)
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        self.view.addSubview(button)
            
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.anchorCenterXToSuperview()
            NSLayoutConstraint(item: self.view,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: button,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 50.0).isActive = true
            
            NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40).isActive = true
            
            NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40).isActive = true
            
        }
    }
    
    private func setLoadingOverlay() {
        LoadingOverlay.shared.showOverlay(view: self.view)
    }
    
    
    func toggleUI(_ show: Bool) {
        
        if show {
            self.emptyView.isHidden = true
            self.emptyView.removeFromSuperview()
        }
        else {
            self.emptyView.isHidden = false
            self.view.addSubview(emptyView)
            self.view.bringSubview(toFront: emptyView)
        }
        
    }
    
    private func reloadTipGrid() {
        
        UIView.animate(withDuration: 0.0, animations: { [weak self] in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.collectionView.reloadData()
            }
            
            }, completion: { [weak self] (finished) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.setFloatingButton()
                    strongSelf.toggleUI(true)
                    LoadingOverlay.shared.hideOverlayView()
                }
        })
    }
    
    func dismissView() {
    dismiss(animated: false, completion: nil)
    }

}


extension MyFriendViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            if friends.count > 0 {
                return CGSize(self.view.frame.size.width, 63)
            }
            else {
                return CGSize.zero
            }
        }
        else {
            let width = (view.bounds.size.width - 2) / 3
            return CGSize(width: width, height: width)
        }
        
    }
    
    
    func collectionView(_ collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 8.0
        }
        else {
            return 1.0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize(width: 0, height: 0)
        }
        else {
            return CGSize(width: collectionView.frame.width, height: 112)
        }
        
    }
    
}

extension MyFriendViewController: UICollectionViewDelegate {
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewCell = cell as? FriendViewCell else { return }
        
      //  collectionViewCell.delegate = self
        
        let dataProvider = ChildCollectionViewDataSource()
        dataProvider.friends = friends
        
        let delegate = ChildCollectionViewDelegate()
      //  delegate.friendDelegate = self
        delegate.friends = self.friends
        
        collectionViewCell.initializeCollectionViewWithDataSource(dataSource: dataProvider, delegate: delegate, forRow: indexPath.row)
        
        collectionViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewCell = cell as? FriendViewCell else { return }
        storedOffsets[indexPath.row] = collectionViewCell.collectionViewOffset
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            if indexPath.section == 1 {
                let cell = collectionView.cellForItem(at: indexPath)
                let singleTipViewController = SingleTipViewController()
                singleTipViewController.tip = self.tips[indexPath.row]
                singleTipViewController.isFriend = true
           //     singleTipViewController.delegate = self
                let view: UIImageView = cell?.viewWithTag(15) as! UIImageView
                singleTipViewController.tipImage = view.image
                singleTipViewController.modalPresentationStyle = .fullScreen
           //     singleTipViewController.transitioningDelegate = self
                self.present(singleTipViewController, animated: true, completion: {})
            }
            
        }
        //  else {
        //      self.openFriendsProfile(self.friends[indexPath.row])
        //  }
    }
    
}
