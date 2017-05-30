//
//  MyTipsViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 25/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import MBProgressHUD
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher


class MyTipsViewController: UIViewController, UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZoomImageDelegate, UIViewControllerTransitioningDelegate {

    
    let cellId = "cellId"
    let fbCellId = "fbCelId"
    let headerId = "headerId"
    
    let dataService = DataService()
    var tips = [Tip]()
    var user: User!
    var tipRef: FIRDatabaseReference!
    var currentUserRef: FIRDatabaseReference!
    var tabBarVC: TabBarController!
    var headerView = ProfileHeaderView()
    var emptyView: UIView!
    var didLoadView: Bool!
    let tapRec = UITapGestureRecognizer()
    
    
    @IBOutlet weak var collectionView: UICollectionView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureNavBar()
        setData()
        didLoadView = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateProfile),
                                               name: NSNotification.Name(rawValue: "updateProfile"),
                                               object: nil)
        
        tapRec.addTarget(self, action: #selector(redirectToAdd))
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
    }
    
    
    private func setupView() {
        
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: "ProfileHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.register(UINib(nibName: "ProfileGridCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
            collectionView.isPrefetchingEnabled = true
        }
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


    
    func didTapEdit() {
        self.openImagePicker()
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
                    
                    if let userId = FIRAuth.auth()?.currentUser?.uid {
                        //Create Path for the User Image
                        let imagePath = "\(userId)/userPic.jpg"
                        
                        // Create image Reference
                        
                        let imageRef = dataService.STORAGE_PROFILE_IMAGE_REF.child(imagePath)
                        
                        // Create Metadata for the image
                        
                        let metaData = FIRStorageMetadata()
                        metaData.contentType = "image/jpeg"
                        
                        // Save the user Image in the Firebase Storage File
                        
                        let uploadTask = imageRef.put(data as Data, metadata: metaData) { (metaData, error) in
                            if error == nil {
                                
                                if let photoUrl = metaData?.downloadURL()?.absoluteString {
                                    self.dataService.CURRENT_USER_REF.updateChildValues(["photoUrl": photoUrl], withCompletionBlock: { (error, ref) in
                                        
                                        if error == nil {
                                            self.updateTips(userId, photoUrl: photoUrl)
                                        }
                                        else {
                                            print("Updating profile pic failed...")
                                        }
                                    })
                                    
                                }
                                
                            }
                            
                        }
                        uploadTask.observe(.progress) { snapshot in
                            print(snapshot.progress) // NSProgress object
                        }
                        
                        uploadTask.observe(.success) { snapshot in
                            DispatchQueue.main.async {
                                self.headerView.userProfileImage.image = resizedImage
                                loadingNotification.hide(animated: true)
                                
                                let alertController = UIAlertController()
                                alertController.defaultAlert(nil, Constants.Notifications.ProfileUpdateSuccess)
                            }
                        }
                        
                        
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func updateTips(_ userId: String, photoUrl: String) {
        
        self.dataService.TIP_REF.queryOrdered(byChild: "addedByUser").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            print("User tip count: \(snapshot.childrenCount)")
            for tip in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                self.dataService.TIP_REF.observeSingleEvent(of: .value, with: { (tipSnap) in
                    
                    if tipSnap.hasChild(tip.key) {
                        
                        self.dataService.USER_TIP_REF.child(userId).observeSingleEvent(of: .value, with: { (userSnap) in
                            
                            if userSnap.hasChild(tip.key) {
                                
                                if let category = (tip.value as! NSDictionary)["category"] as? String {
                                    
                                    self.dataService.CATEGORY_REF.child(category).observeSingleEvent(of: .value, with: { (catSnap) in
                                        
                                        if catSnap.hasChild(tip.key) {
                                            
                                            
                                            let updateObject = ["tips/\(tip.key)/userPicUrl" : photoUrl, "userTips/\(userId)/\(tip.key)/userPicUrl" : photoUrl, "categories/\(category)/\(tip.key)/userPicUrl" : photoUrl]
                                            
                                            self.dataService.BASE_REF.updateChildValues(updateObject, withCompletionBlock: { (error, ref) in
                                                
                                                
                                                if error == nil {
                                                    print("Successfully updated the tip...")
                                                }
                                                else {
                                                    print("Updating failed...")
                                                }
                                            })
                                        }
                                        
                                    })
                                }
                            }
                            
                        })
                    }
                })
            }
        })
        
    }
    
    
    func updateProfile() {
        
        self.user = nil
        self.tips.removeAll()
        
        if let tabVC = self.tabBarVC {
            self.user = tabVC.user
            self.tips = tabVC.tips
        }
        
       setLoadingOverlay()
        reloadTipGrid()
    }
    
    
    func popUpPrompt() {
        let alertController = UIAlertController()
        alertController.networkAlert(Constants.NetworkConnection.NetworkPromptMessage)
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


    // MARK: UICollectionViewDataSource

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if self.tips.count > 0
        {
            collectionView.backgroundView = nil
        }
        else
        {
            let noDataLabel = UILabel()
            noDataLabel.text = "No tips? Add one!"
            noDataLabel.textColor = UIColor.secondaryTextColor()
            noDataLabel.font = UIFont.systemFont(ofSize: 20)
            noDataLabel.textAlignment = .center
            collectionView.backgroundView  = noDataLabel
            collectionView.backgroundColor = UIColor.smokeWhiteColor()
            noDataLabel.addGestureRecognizer(tapRec)
            noDataLabel.isUserInteractionEnabled = true
            noDataLabel.anchorCenterSuperview()
            headerView.addBottomBorder(color: UIColor.tertiaryColor(), width: 3)
            }
        
        return 1
    }

    
     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let url = URL(string: self.tips[indexPath.row].tipImageUrl)
        let processor = ResizingImageProcessor(targetSize: CGSize(width: 250, height: 250), contentMode: .aspectFill)
        let _ = (cell as! ProfileGridCell).tipImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
            print("\(indexPath.row): \(receivedSize)/\(totalSize)")
            
        }) { (image, error, cacheType, imageUrl) in
            
            print("\(indexPath.row): \(cacheType)")
        }
    }
    
    
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       /*
        if headerView.fbCollectionView != nil && collectionView == headerView.fbCollectionView {
            let friendsCell = collectionView.dequeueReusableCell(withReuseIdentifier: fbCellId, for: indexPath as IndexPath) as! FBFriendsCell
        return friendsCell
            
        }
        else {
 */
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! ProfileGridCell
        
        cell.tipImage.backgroundColor = UIColor.tertiaryColor()
        cell.tipImage.tag = 15
        
        return cell
     //   }
    }
    
    
     func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ProfileGridCell).tipImage.kf.cancelDownloadTask()
    }
    
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        let singleTipViewController = SingleTipViewController()
        singleTipViewController.tip = self.tips[indexPath.row]
        singleTipViewController.delegate = self
        let view: UIImageView = cell?.viewWithTag(15) as! UIImageView
        singleTipViewController.tipImage = view.image
        singleTipViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        singleTipViewController.transitioningDelegate = self
        self.present(singleTipViewController, animated: true, completion: {})
        
        /*
        self.addChildViewController(singleTipViewController)
        if let navVC = self.navigationController {
        singleTipViewController.view.frame = navVC.view.frame
        self.view.addSubview(singleTipViewController.view)
        singleTipViewController.didMove(toParentViewController: self)
        }
 */
        
    }
    

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if headerView.fbCollectionView != nil && collectionView == headerView.fbCollectionView {
        return 8
        }
        else {
        return self.tips.count
        }
    }
    
    
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
    
    
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! ProfileHeaderView
            
            headerView.fbCollectionView.backgroundColor = .white
            headerView.fbCollectionView.register(UINib(nibName: "FBFriendsCell", bundle: nil), forCellWithReuseIdentifier: fbCellId)
            headerView.fbCollectionView.delegate = self
            headerView.fbCollectionView.dataSource = self
            
            
            let url = URL(string: self.user.photoUrl)
            
            headerView.userProfileImage.layer.cornerRadius = headerView.userProfileImage.frame.size.width / 2
            headerView.userProfileImage.delegate = self
            headerView.userProfileImage.kf.indicatorType = .activity
            let processor = ResizingImageProcessor(targetSize: CGSize(width: 400, height: 400), contentMode: .aspectFill)
            headerView.userProfileImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                print("\(receivedSize)/\(totalSize)")
            }) { (image, error, cacheType, imageUrl) in
                
                if (image == nil) {
                    self.headerView.userProfileImage.image = UIImage(named: Constants.Images.ProfilePlaceHolder)
                }
                
                self.headerView.nameLabel.text = self.user.name
                
                if let likes = self.user.totalLikes {
                    self.headerView.likes.text = "\(likes)"
                    
                    if (likes == 1) {
                        self.headerView.likesLabel.text = "Like"
                    }
                    else {
                        self.headerView.likesLabel.text = "Likes"
                    }
                }
                
                if let tips = self.user.totalTips {
                    self.headerView.tips.text = "\(tips)"
                    
                    if (tips == 1) {
                        self.headerView.tipsLabel.text = "Tip"
                    }
                    else {
                        self.headerView.tipsLabel.text = "Tips"
                    }
                }
             
            }
            
            return headerView
            
            
        default:  fatalError("Unexpected element kind")
        }
 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 180)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }

}


extension MyTipsViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap {
            
            URL(string: self.tips[$0.row].tipImageUrl)
        }
        
        ImagePrefetcher(urls: urls).start()
    }
}


extension MyTipsViewController: TipEditDelegate {

    func editTip(_ tip: Tip) {
            tabBarController!.selectedIndex = 4
            NotificationCenter.default.post(name: Notification.Name(rawValue: "editTip"), object: nil, userInfo: ["tip": tip])
        
    }
}

