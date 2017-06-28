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


let reuseMainCollectionViewCellIdentifier = "MainCollectionViewCellIdentifier"
let reuseGridViewCellIdentifier = "GridViewCellIdentifier"
let reuseChildCollectionViewCellIdentifier = "ChildCollectionViewCellIdentifier"
let reuseProfileViewIdentifier = "ProfileViewIdentifier"



class MyProfileViewController: UIViewController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataService = DataService()
    var tips = [Tip]()
    var user: MyUser!
    var friends = [MyUser]()
    var tabBarVC: TabBarController!
    var emptyView: UIView!
    var didLoadView: Bool!
    let tapRec = UITapGestureRecognizer()
    var dataProvider : MainCollectionViewDataSource!
    var storedOffsets = [Int: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setData()
        
     //   self.configureNavBar()
        self.setupView()
        didLoadView = false
        
        tapRec.addTarget(self, action: #selector(redirectToAdd))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateProfile),
                                               name: NSNotification.Name(rawValue: "updateProfile"),
                                               object: nil)
       
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
    
/*
    func configureNavBar() {
        
        let navLabel = UILabel()
        navLabel.contentMode = .scaleAspectFill
        navLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 70)
        if let name = user.name {
            let firstName = name.components(separatedBy: " ")
            navLabel.text = firstName[0]
            navLabel.textColor = UIColor.secondaryTextColor()
            navLabel.font = UIFont.boldSystemFont(ofSize: 17)
        }
        self.navigationItem.titleView = navLabel
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    */
    
    
    
    func setData() {
        self.tabBarVC = self.tabBarController as? TabBarController
        self.user = self.tabBarVC.user
        self.tips = self.tabBarVC.tips
        self.friends = self.tabBarVC.friends
        
        dataProvider = MainCollectionViewDataSource()
        dataProvider.friends = self.friends
        dataProvider.tips = self.tips
        dataProvider.user = self.user
        dataProvider.isFriend = false
        dataProvider.hideTips = false
        dataProvider.delegate = self
        collectionView.dataSource = dataProvider
        
    }
    
    
    private func setupView() {
        
     //   collectionView.dataSource = self as! UICollectionViewDataSource
     //   collectionView.delegate = self
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
            collectionView.isPrefetchingEnabled = true
        }
        collectionView.register(ProfileGridCell.self, forCellWithReuseIdentifier: reuseGridViewCellIdentifier)
        collectionView.register(UINib(nibName: "ProfileContainerView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseProfileViewIdentifier)
     //   collectionView.register(UINib(nibName: "ProfileGridCell", bundle: nil), forCellWithReuseIdentifier: gridViewCellIdentifier)
     //   collectionView.register(UINib(nibName: "FriendsView", bundle: nil), forCellWithReuseIdentifier: friendsViewIdentifier)
     //   self.userProfileImage.delegate = self
        self.emptyView = UIView(frame: CGRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.emptyView.backgroundColor = UIColor.white
        self.toggleUI(false)
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
                    strongSelf.toggleUI(true)
                    LoadingOverlay.shared.hideOverlayView()
                }
                
        })
    }
    
    
    func redirectToAdd() {
        if let tabVC = self.tabBarController {
            tabVC.selectedIndex = 4
        }
    }
    
    
    func openFriendsProfile(_ user: MyUser) {
        
        guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MyFriendViewController") as? MyFriendViewController else {
            print("Could not instantiate view controller with identifier of type MyFriendViewController")
            return
        }
        let dataProvider = MainCollectionViewDataSource()
        
        if let key = user.key {
            self.dataService.getFriendsProfile(key, completion: { (success, tips, friends, isHidden) in
                
                if success {
                    dataProvider.user = user
                    dataProvider.tips = tips
                    vc.tips = tips
                    vc.user = user
                    if let friends = friends {
                        dataProvider.friends = friends
                        vc.friends = friends
                    }
                    dataProvider.isFriend = true
                    dataProvider.hideTips = isHidden
                  //  self.hideTips = isHidden
                    vc.dataProvider = dataProvider
                //    vc.delegate = delegate
                  //  vc.user = user
                //    if let navC = self.navigationController {
                //        navC.pushViewController(vc, animated: true)
                //    }
                    self.present(vc, animated: true, completion: nil)
                   
                    
                }
                else {
                  //  self.toggleUI(true)
                  //  LoadingOverlay.shared.hideOverlayView()
                }
            })
        }
        
        
     //   let vc = UIStoryboard(name: "Friend", bundle: nil).instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
     //   vc.user = user
     //   self.present(vc, animated: true, completion: nil)
        /*
         if let navC = self.navigationController {
        navC.pushViewController(vc, animated: true)
        }
 */
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
                            print("Profile pic updated...")
                            DispatchQueue.main.async {
                             //   self.userProfileImage.image = resizedImage
                              //  self.updateProfile()
                                 NotificationCenter.default.post(name: Notification.Name(rawValue: "tipsUpdated"), object: nil)
                                
                                let alertController = UIAlertController()
                                alertController.defaultAlert(nil, Constants.Notifications.ProfileUpdateSuccess)
                            }
                        }
                        else {
                            print("Upload failed...")
                        }
                        loadingNotification.hide(animated: true)
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
        self.reloadTipGrid()
        /*
        self.setupUser { (success) in
            
            if success {
                self.reloadTipGrid()
            }
        }
 */
        
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
        
        if indexPath.section == 0 {
            if friends.count > 0 {
        return CGSize(self.view.frame.size.width, 60)
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

extension MyProfileViewController: UICollectionViewDelegate {
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewCell = cell as? FriendViewCell else { return }
        
        collectionViewCell.delegate = self
        
        let dataProvider = ChildCollectionViewDataSource()
        dataProvider.friends = friends
        
        let delegate = ChildCollectionViewDelegate()
        delegate.friendDelegate = self
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
            singleTipViewController.isFriend = false
            singleTipViewController.delegate = self
            let view: UIImageView = cell?.viewWithTag(15) as! UIImageView
            singleTipViewController.tipImage = view.image
            singleTipViewController.modalPresentationStyle = .fullScreen
            singleTipViewController.transitioningDelegate = self
            self.present(singleTipViewController, animated: true, completion: {})
            }
           
        }
      //  else {
      //      self.openFriendsProfile(self.friends[indexPath.row])
      //  }
    }

}



extension MyProfileViewController: UICollectionViewDataSourcePrefetching {
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


extension MyProfileViewController : CollectionViewSelectedProtocol {
    
    // MARK: - CollectionViewSelectedProtocol
    
    func collectionViewSelected(collectionViewItem: Int) {
        
     //   let dataProvider = ChildCollectionViewDataSource() // You can choose to create a new data source and feed it the same data
     //   dataProvider.friends = friends
        
     //   let delegate = ChildCollectionViewDelegate() // You can choose to create a new CollectionViewDelegate for detailViewController
        /*
        let detailVC = UIStoryboard(name: "DetailView", bundle: nil).instantiateViewControllerWithIdentifier("DetailView") as! DetailViewController
        detailVC.dataSource = dataProvider
        detailVC.delegate = delegate
        
        navigationController?.pushViewController(detailVC, animated: true)
 */
    }
    
}




extension MyProfileViewController: TipEditDelegate {
    
    func editTip(_ tip: Tip) {
        tabBarController!.selectedIndex = 4
        NotificationCenter.default.post(name: Notification.Name(rawValue: "editTip"), object: nil, userInfo: ["tip": tip])
        
    }
    
}


extension MyProfileViewController: TapFriendDelegate {

    func openProfile(_ friend: MyUser) {
    self.openFriendsProfile(friend)
    }

}


extension MyProfileViewController: PickerDelegate {

    func openPicker() {
    self.openImagePicker()
    }
}
