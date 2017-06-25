//
//  FriendViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 09/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import Kingfisher



class FriendViewController: UIViewController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {

    var user: MyUser!
    let dataService = DataService()
    var tips = [Tip]()
    var friends = [MyUser]()
    var hideTips = false
    var tabBarVC: TabBarController!
    var emptyView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavBar()
    //    self.setupView()
        setLoadingOverlay()
        if let key = self.user.key {
        self.dataService.getFriendsProfile(key, completion: { (success, tips, friends, isHidden) in
            
            if success {
                self.tips = tips
                if let friends = friends {
                self.friends = friends
                }
                self.hideTips = isHidden
                self.reloadTipGrid()
            }
            else {
                self.toggleUI(true)
                LoadingOverlay.shared.hideOverlayView()
            }
        })
    }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavBar() {
        
        let navLabel = UILabel()
        navLabel.contentMode = .scaleAspectFill
        navLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 70)
        if let name = user.name {
        let firstName = name.components(separatedBy: " ")
        navLabel.text = firstName[0]
        navLabel.textColor = UIColor.secondaryTextColor()
            navLabel.font = UIFont.boldSystemFont(ofSize: 17)
            self.navigationItem.titleView = navLabel
            self.navigationItem.setHidesBackButton(false, animated: false)
            let backImage = UIImage(named: Constants.Images.BackButton)
            let newBackButton = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.goBack))
            newBackButton.tintColor = UIColor.primaryColor()
            navigationItem.leftBarButtonItem = newBackButton
    }
    }
    
    func goBack() {
        if let navC = self.navigationController {
        navC.popToRootViewController(animated: true)
        }
    }
    
  /*
    private func setupView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = false
        
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
            collectionView.isPrefetchingEnabled = true
        }
        collectionView.register(UINib(nibName: "ProfileGridCell", bundle: nil), forCellWithReuseIdentifier: gridViewCellIdentifier)
        collectionView.register(UINib(nibName: "FriendViewCell", bundle: nil), forCellWithReuseIdentifier: friendsViewIdentifier)
        self.emptyView = UIView(frame: CGRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.emptyView.backgroundColor = UIColor.white
        self.toggleUI(false)

}
    
    */
    private func setLoadingOverlay() {
        
        if let navVC = self.navigationController {
            LoadingOverlay.shared.setSize(width: navVC.view.frame.width, height: navVC.view.frame.height)
            let navBarHeight = navVC.navigationBar.frame.height
            LoadingOverlay.shared.reCenterIndicator(view: navVC.view, navBarHeight: navBarHeight)
            LoadingOverlay.shared.showOverlay(view: navVC.view)
        }
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
                    strongSelf.toggleUI(true)
                    LoadingOverlay.shared.hideOverlayView()
                }
                
        })
    }
    
}


extension FriendViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionView {
            if indexPath.section == 0 {
                return CGSize(width: self.view.frame.size.width, height: 60)
            }
            else {
                let width = (collectionView.bounds.size.width - 2) / 3
                return CGSize(width: width, height: width)
            }
        }
        else {
            return CGSize(width: 50, height: 50)
        }
    }
    
    func collectionView(_ collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.collectionView {
            return 1.0
        }
        else {
            return 8.0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView != self.collectionView {
            if section == 0 {
                return UIEdgeInsetsMake(0, 20, 0, 0)
            }
        }
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            if indexPath.section == 0 {
                (cell as! FriendCell).imageView.kf.cancelDownloadTask()
                // (cell as! FriendViewCell).userProfileImage.kf.cancelDownloadTask()
            }
            else {
                (cell as! ProfileGridCell).imageView.kf.cancelDownloadTask()
            }
        }
        else {
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            let cell = collectionView.cellForItem(at: indexPath)
            let singleTipViewController = SingleTipViewController()
            singleTipViewController.tip = self.tips[indexPath.row]
            singleTipViewController.isFriend = true
            let view: UIImageView = cell?.viewWithTag(15) as! UIImageView
            singleTipViewController.tipImage = view.image
            singleTipViewController.modalPresentationStyle = .fullScreen
            singleTipViewController.transitioningDelegate = self
            self.present(singleTipViewController, animated: true, completion: {})
            
        }
        
    }
    
    
}

/*
extension FriendViewController: UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if collectionView == self.collectionView {
            
            let noDataLabel = UILabel()
            
            noDataLabel.textColor = UIColor.secondaryTextColor()
            noDataLabel.font = UIFont.systemFont(ofSize: 20)
            noDataLabel.textAlignment = .center
            
            
            if self.tips.count > 0 {
                collectionView.backgroundView = nil
                
                if self.hideTips {
                    noDataLabel.text = "Tips are private"
                    collectionView.backgroundColor = UIColor.smokeWhiteColor()
                    collectionView.backgroundView = noDataLabel
                    noDataLabel.isUserInteractionEnabled = true
                    noDataLabel.anchorCenterSuperview()
                }
            }
            else
            {
                noDataLabel.text = "No tips yet"
                collectionView.backgroundColor = UIColor.smokeWhiteColor()
                collectionView.backgroundView = noDataLabel
                noDataLabel.isUserInteractionEnabled = true
                noDataLabel.anchorCenterSuperview()
            }
            
            return 2
        }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collectionView {
            if section == 0 {
                return 1
            } else {
                //Below friendsView
                if !self.hideTips {
                return self.tips.count
                }
                else {
                return 0
                }
            }
        }
        else {
            return self.friends.count
        }
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseMainCollectionViewCellIdentifier, for: indexPath)
        return cell
    }
   */
    /*
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: friendsViewIdentifier, for: indexPath) as! FriendViewCell
                
                cell.friendsCollectionView.delegate = self
                cell.friendsCollectionView.dataSource = self
                
                cell.friendsCollectionView.register(FriendCell.self, forCellWithReuseIdentifier: friendViewCellIdentifier)
                cell.friendsCollectionView.showsHorizontalScrollIndicator = false
                
                return cell
                
            } else {
                // below friendsView
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridViewCellIdentifier, for: indexPath) as! ProfileGridCell
                
                cell.tipImage.backgroundColor = UIColor.tertiaryColor()
                cell.tipImage.tag = 15
                let url = URL(string: self.tips[indexPath.row].tipImageUrl)
                let processor = ResizingImageProcessor(referenceSize: CGSize(width: 250, height: 250), mode: .aspectFill)
                cell.tipImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                    print("\(indexPath.row): \(receivedSize)/\(totalSize)")
                    
                }) { (image, error, cacheType, imageUrl) in
                    
                    print("\(indexPath.row): \(cacheType)")
                }
                
                return cell
            }
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: friendViewCellIdentifier, for: indexPath) as! FriendCell
            
            cell.isUserInteractionEnabled = false
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
 
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView? = nil
        
        if kind == UICollectionElementKindSectionHeader {
            let profileView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: profileViewIdentifier, for: indexPath) as! ProfileView
            
            let url = URL(string: self.user.photoUrl)
            
            profileView.userProfileImage.kf.indicatorType = .activity
            let processor = ResizingImageProcessor(referenceSize: CGSize(width: 500, height: 500), mode: .aspectFill)
            profileView.userProfileImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                print("\(receivedSize)/\(totalSize)")
            }) { (image, error, cacheType, imageUrl) in
                
                profileView.userProfileImage.layer.cornerRadius = profileView.userProfileImage.frame.size.width / 2
                if (image == nil) {
                    profileView.userProfileImage.image = UIImage(named: Constants.Images.ProfilePlaceHolder)
                }
                
                profileView.nameLabel.text = self.user.name
                
                if let likes = self.user.totalLikes {
                    profileView.likes.text = "\(likes)"
                    
                    if (likes == 1) {
                        profileView.likesLabel.text = "like"
                    }
                    else {
                        profileView.likesLabel.text = "likes"
                    }
                }
                
                if let tips = self.user.totalTips {
                    profileView.tips.text = "\(tips)"
                    
                    if (tips == 1) {
                        profileView.tipsLabel.text = "tip"
                    }
                    else {
                        profileView.tipsLabel.text = "tips"
                    }
                }
                
            }
            
            reusableView = profileView
            
        }
        return reusableView!
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // if section is above friendsView we need to make its height 0
        if section == 0 {
            return CGSize(width: 0, height: 0)
        }
        // for section header i.e. actual firendsView
        if self.friends.count > 0 {
            return CGSize(width: collectionView.frame.width, height: 54)
        }
        else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    
}
*/


extension FriendViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        if collectionView == self.collectionView {
            let urls = indexPaths.flatMap {
                URL(string: self.tips[$0.row].tipImageUrl)
            }
            ImagePrefetcher(urls: urls).start()
        }
        else {
            
            let urls = indexPaths.flatMap {
                URL(string: self.friends[$0.row].photoUrl)
            }
            ImagePrefetcher(urls: urls).start()
        }
        
    }
}



