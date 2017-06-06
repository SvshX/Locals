//
//  MyProfileViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import MBProgressHUD
import Kingfisher

class MyProfileViewController: UIViewController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataService = DataService()
    var tips = [Tip]()
    var user: User!
    var friends = [Friend]()
    var tabBarVC: TabBarController!
    var emptyView: UIView!
    var didLoadView: Bool!
    let tapRec = UITapGestureRecognizer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureNavBar()
        self.setData()
        self.setupView()
        didLoadView = false
        
        tapRec.addTarget(self, action: #selector(redirectToAdd))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateProfile),
                                               name: NSNotification.Name(rawValue: "updateProfile"),
                                               object: nil)
        
        self.setupUser { (success) in
            if success {
                print("User loaded...")
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !didLoadView {
            setLoadingOverlay()
            reloadTipGrid()
            didLoadView = true
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func configureNavBar() {
        
        let navLabel = UILabel()
        navLabel.contentMode = .scaleAspectFill
        navLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 70)
        navLabel.text = "My tips"
        navLabel.textColor = UIColor.secondaryTextColor()
        self.navigationItem.titleView = navLabel
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    
    func setData() {
        self.tabBarVC = self.tabBarController as? TabBarController
        self.user = self.tabBarVC.user
        self.tips = self.tabBarVC.tips
        self.friends = self.tabBarVC.friends
        
        if let navVC = self.navigationController {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let navBarHeight = navVC.navigationBar.intrinsicContentSize.height
        }
    }
    
    
    private func setupView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
            collectionView.isPrefetchingEnabled = true
        }
        collectionView.register(UINib(nibName: "ProfileGridCell", bundle: nil), forCellWithReuseIdentifier: "gridView")
     //   self.userProfileImage.delegate = self
        self.emptyView = UIView(frame: CGRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.emptyView.backgroundColor = UIColor.white
        self.toggleUI(false)
    }
    
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
    
    
    func setupUser(completion: @escaping (Bool) -> ()) {
        
        self.setProfilePic(completion: { (Void) in
            /*
            self.nameLabel.text = self.user.name
            
            if let likes = self.user.totalLikes {
                self.totalLikes.text = "\(likes)"
                
                if (likes == 1) {
                    self.likesLabel.text = "Like"
                }
                else {
                    self.likesLabel.text = "Likes"
                }
            }
            
            if let tips = self.user.totalTips {
                self.totalTips.text = "\(tips)"
                
                if (tips == 1) {
                    self.tipsLabel.text = "Tip"
                }
                else {
                    self.tipsLabel.text = "Tips"
                }
            }
            */
            completion(true)
        })
    }
    
    
    
    private func setProfilePic(completion: @escaping (Void) -> Void) {
        /*
        let url = URL(string: self.user.photoUrl)
        
        self.userProfileImage.kf.indicatorType = .activity
        let processor = ResizingImageProcessor(targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill)
        self.userProfileImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
            print("\(receivedSize)/\(totalSize)")
        }) { (image, error, cacheType, imageUrl) in
            
            self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
            if (image == nil) {
                self.userProfileImage.image = UIImage(named: Constants.Images.ProfilePlaceHolder)
            }
            completion()
        }
        */
        completion()
    }
    
    
    
    func redirectToAdd() {
        if let tabVC = self.tabBarController {
            tabVC.selectedIndex = 4
        }
    }
    
    
    func openImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        if let window = UIApplication.shared.keyWindow {
            let loadingNotification = MBProgressHUD.showAdded(to: window, animated: true)
            loadingNotification.label.text = Constants.Notifications.LoadingNotificationText
            
            let img = info[UIImagePickerControllerOriginalImage] as? UIImage
            if let resizedImage = img?.resizeImageAspectFill(newSize: CGSize(400, 400)) {
                
                let profileImageData = UIImageJPEGRepresentation(resizedImage, 1)
                
                if let data = profileImageData {
                    
                    self.dataService.uploadProfilePic(data, completion: { (success) in
                        
                        if success {
                            DispatchQueue.main.async {
                            //    self.userProfileImage.image = resizedImage
                                loadingNotification.hide(animated: true)
                                
                                let alertController = UIAlertController()
                                alertController.defaultAlert(nil, Constants.Notifications.ProfileUpdateSuccess)
                            }
                        }
                        else {
                            print("Upload failed...")
                        }
                    })
                    
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func updateProfile() {
        
        self.user = nil
        self.friends.removeAll()
        self.tips.removeAll()
        
        if let tabVC = self.tabBarVC {
            self.user = tabVC.user
            self.tips = tabVC.tips
            self.friends = tabVC.friends
        }
        
        setLoadingOverlay()
        self.setupUser { (success) in
            
            if success {
                self.reloadTipGrid()
            }
        }
        
    }
    
    
    private func updateTips(_ userId: String, photoUrl: String) {
        
        self.dataService.updateUsersTips(userId, photoUrl) { (success) in
            
            if success {
                print("Successfully updated the tip...")
            }
            else {
                print("Updating failed...")
            }
        }
        
    }
    
    
    
    func imageView(for cell: UICollectionViewCell) -> UIImageView {
        var imageView = cell.viewWithTag(15) as? UIImageView
        if imageView == nil {
            imageView = UIImageView(frame: cell.bounds)
            imageView!.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
            imageView!.tag = 15
            imageView!.contentMode = .scaleAspectFill
            imageView!.clipsToBounds = true
            cell.addSubview(imageView!)
        }
        return imageView!
    }

}


extension MyProfileViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            let width = (collectionView.bounds.size.width - 2) / 3
            return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
     //   (cell as! ProfileGridCell).tipImage.kf.cancelDownloadTask()
    }

}


extension MyProfileViewController: UICollectionViewDataSource {


    func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            //Below friendsView
            return self.tips.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            // above firendsView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileView", for: indexPath)
            return cell
        } else {
            // below firendsView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridView", for: indexPath) as! ProfileGridCell
            
            let url = URL(string: self.tips[indexPath.row].tipImageUrl)
            let processor = ResizingImageProcessor(targetSize: CGSize(width: 250, height: 250), contentMode: .aspectFill)
            cell.tipImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                print("\(indexPath.row): \(receivedSize)/\(totalSize)")
                
            }) { (image, error, cacheType, imageUrl) in
                
                print("\(indexPath.row): \(cacheType)")
            }

            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // returning the search bar for header
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "friendsView", for: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // if section is above friendsView we need to make its height 0
        if section == 0 {
            return CGSize(width: 0, height: 0)
        }
        // for section header i.e. actual firendsView
        return CGSize(width: collectionView.frame.width, height: 120)
    }
    
    
}



extension MyProfileViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
            let urls = indexPaths.flatMap {
                URL(string: self.tips[$0.row].tipImageUrl)
            }
            ImagePrefetcher(urls: urls).start()
    }
}


extension MyProfileViewController: TipEditDelegate {
    
    func editTip(_ tip: Tip) {
        tabBarController!.selectedIndex = 4
        NotificationCenter.default.post(name: Notification.Name(rawValue: "editTip"), object: nil, userInfo: ["tip": tip])
        
    }
    
}


extension MyProfileViewController: ZoomImageDelegate {
    
    func didTapEdit() {
        self.openImagePicker()
    }
}
