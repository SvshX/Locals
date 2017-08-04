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
    var tips: [Tip] = []
    var user: MyUser!
    var friends: [MyUser] = []
    var emptyView: UIView!
    var didLoadView: Bool!
    let tapRec = UITapGestureRecognizer()
    var dataProvider: MainCollectionViewDataSource!
    var storedOffsets: [Int : CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        tapRec.addTarget(self, action: #selector(redirectToAdd))
        guard let tabC = self.tabBarController as? TabBarController else {return}
        setData(tabC.user, tabC.friends, tabC.tips)
        
        tabC.onReloadProfile = { [weak self] (user, friends, tips) in
          
          guard let strongSelf = self else {return}
            strongSelf.setData(user, friends, tips)
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func setData(_ user: MyUser, _ friends: [MyUser], _ tips: [Tip]) {
        
        clearData()
        self.user = user
        self.friends = friends
        self.tips = tips
        dataProvider = MainCollectionViewDataSource()
        dataProvider.friends = self.friends
        dataProvider.tips = self.tips
        dataProvider.user = self.user
        dataProvider.isFriend = false
        dataProvider.showTips = true
        dataProvider.delegate = self
        collectionView.dataSource = dataProvider
        reloadProfile()
    }
    
    func clearData() {
        user = nil
        friends.removeAll()
        tips.removeAll()
    }
  
  
    
    private func setupView() {
    
      guard let layout = collectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout else {return}
      layout.horizontalAlignment = .left
      layout.minimumInteritemSpacing = 1
        layout.sectionHeadersPinToVisibleBounds = true
        let cellWidth = (view.bounds.size.width - 2) / 3
        layout.estimatedItemSize = CGSize(cellWidth, cellWidth)
        layout.scrollDirection = .vertical
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
            collectionView.isPrefetchingEnabled = true
        }
        collectionView.register(ProfileGridCell.self, forCellWithReuseIdentifier: reuseGridViewCellIdentifier)
        collectionView.register(UINib(nibName: "ProfileContainerView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseProfileViewIdentifier)
     //   collectionView.register(UINib(nibName: "ProfileGridCell", bundle: nil), forCellWithReuseIdentifier: gridViewCellIdentifier)
     //   collectionView.register(UINib(nibName: "FriendsView", bundle: nil), forCellWithReuseIdentifier: friendsViewIdentifier)
     //   self.userProfileImage.delegate = self
        emptyView = UIView(frame: CGRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        emptyView.backgroundColor = UIColor.white
        toggleUI(false)
    }
    
    
    func toggleUI(_ show: Bool) {
        
        if show {
            emptyView.isHidden = true
            emptyView.removeFromSuperview()
            LoadingOverlay.shared.hideOverlayView()
        }
        else {
            emptyView.isHidden = false
            view.addSubview(emptyView)
            view.bringSubview(toFront: emptyView)
            LoadingOverlay.shared.showOverlay(view: self.view)
        }
        
    }
    
    private func reloadProfile() {
        
        UIView.animate(withDuration: 0.0, animations: { [weak self] in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.collectionView.reloadData()
            }
            
            }, completion: { [weak self] (finished) in
                guard let strongSelf = self else { return }
              Utils.delay(withSeconds: 2.0, completion: {
                DispatchQueue.main.async {
                  strongSelf.toggleUI(true)
                }
              })
        })
    }
    
    
    func redirectToAdd() {
        guard let tabVC = tabBarController else {return}
            tabVC.selectedIndex = 4
    }
    
    
    func openFriendsProfile(from user: MyUser) {
        
        guard let vc = UIStoryboard(name: Constants.NibNames.MainStoryboard, bundle:nil).instantiateViewController(withIdentifier: "MyFriendViewController") as? MyFriendViewController else {
            print("Could not instantiate view controller with identifier of type MyFriendViewController")
            return
        }
        toggleUI(false)
        let dataProvider = MainCollectionViewDataSource()
        
        guard let key = user.key else {return}
      
            dataService.getFriendsProfile(key, completion: { (success, tips, friends, isShown) in
                
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
                    dataProvider.showTips = isShown
                    vc.dataProvider = dataProvider
                    self.present(vc, animated: true, completion: nil)
                    self.toggleUI(true)
                }
                else {
                    self.toggleUI(true)
                }
            })
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
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0)
  }
  
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
      if section == 0 {
      return 0
      }
      else {
       return 1.0
      }
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
            return CGSize.zero
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
        delegate.friends = friends
        
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
            singleTipViewController.tip = tips[indexPath.row]
            singleTipViewController.isFriend = false
            singleTipViewController.delegate = self
            let view: UIImageView = cell?.viewWithTag(15) as! UIImageView
            singleTipViewController.tipImage = view.image
            singleTipViewController.modalPresentationStyle = .fullScreen
            singleTipViewController.transitioningDelegate = self
            self.present(singleTipViewController, animated: true, completion: nil)
            }
           
        }
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
      guard let tabC = tabBarController else {return}
        tabC.selectedIndex = 4
        NotificationCenter.default.post(name: Notification.Name(rawValue: "editTip"), object: nil, userInfo: ["tip": tip])
        
    }
    
}


extension MyProfileViewController: TapFriendDelegate {

    func openProfile(from user: MyUser) {
    openFriendsProfile(from: user)
    }

}


extension MyProfileViewController: PickerDelegate {

    func openPicker() {
    openImagePicker()
    }
}
