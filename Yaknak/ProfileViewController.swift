//
//  ProfileViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import MBProgressHUD
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher



class ProfileViewController: UIViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UIImagePickerControllerDelegate {
    
    let dataService = DataService()
    var tips = [Tip]()
    var user: User!
    var friends = [Friend]()
    var tipRef: FIRDatabaseReference!
    var currentUserRef: FIRDatabaseReference!
    var tabBarVC: TabBarController!
    var headerView = ProfileHeaderView()
    var emptyView: UIView!
    var didLoadView: Bool!
    let tapRec = UITapGestureRecognizer()
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    let cellId = "cellId"
    let friendsCellId = "friendsCellId"
    
    var childScrollView: UIScrollView {
        return collectionView
    }
    
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userProfileImage: ZoomingImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var totalLikes: UILabel!
    @IBOutlet weak var totalTips: UILabel!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var friendslabel: UILabel!
    @IBOutlet weak var stickyContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var stickyContainer: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var gridHeight: NSLayoutConstraint!
 
    
    
    
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
            if self.friends.count <= 0 {
                self.stickyContainerHeight.constant = 0
                self.gridHeight.constant = -navBarHeight - 120 - statusBarHeight
            }
            else {
                gridHeight.constant = -navBarHeight - 60 - statusBarHeight
            }
            
        }
        }
    
    
    private func setupView() {
        
        parentScrollView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        friendsCollectionView.delegate = self
        friendsCollectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
            collectionView.isPrefetchingEnabled = true
            friendsCollectionView.prefetchDataSource = self
            friendsCollectionView.isPrefetchingEnabled = true
        }
        self.userProfileImage.delegate = self
        collectionView.register(UINib(nibName: "ProfileGridCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        friendsCollectionView.register(FriendCell.self, forCellWithReuseIdentifier: friendsCellId)
        parentScrollView.contentSize.height = 1200
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
                strongSelf.friendsCollectionView.reloadData()
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
            completion(true)
        })
    }
    
    
    
    private func setProfilePic(completion: @escaping (Void) -> Void) {
        
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == friendsCollectionView {
            return CGSize(width: 40, height: 40)
        }
        else {
        let width = (collectionView.bounds.size.width - 2) / 3
        return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(_ collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == friendsCollectionView {
            return 1.0
        }
        else {
            return 1.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == friendsCollectionView {
            return 20.0
        }
        else {
            return 1.0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == friendsCollectionView {
        
            if let url = URL(string: self.friends[indexPath.row].imageUrl) {
            let processor = ResizingImageProcessor(targetSize: CGSize(width: 250, height: 250), contentMode: .aspectFill)
            let _ = (cell as! FriendCell).imageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                print("\(indexPath.row): \(receivedSize)/\(totalSize)")
                
            }) { (image, error, cacheType, imageUrl) in
                
                print("\(indexPath.row): \(cacheType)")
            }
            }

        }
        else {
        
        let url = URL(string: self.tips[indexPath.row].tipImageUrl)
        let processor = ResizingImageProcessor(targetSize: CGSize(width: 250, height: 250), contentMode: .aspectFill)
        let _ = (cell as! ProfileGridCell).tipImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
            print("\(indexPath.row): \(receivedSize)/\(totalSize)")
            
        }) { (image, error, cacheType, imageUrl) in
            
            print("\(indexPath.row): \(cacheType)")
        }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == friendsCollectionView {
            
        }
        else {
        (cell as! ProfileGridCell).tipImage.kf.cancelDownloadTask()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == friendsCollectionView {
            
        }
        else {
        let cell = collectionView.cellForItem(at: indexPath)
        
        let singleTipViewController = SingleTipViewController()
        singleTipViewController.tip = self.tips[indexPath.row]
        singleTipViewController.delegate = self
        let view: UIImageView = cell?.viewWithTag(15) as! UIImageView
        singleTipViewController.tipImage = view.image
        singleTipViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        singleTipViewController.transitioningDelegate = self
        self.present(singleTipViewController, animated: true, completion: {})
        }
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // determining whether scrollview is scrolling up or down
        goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        
        // maximum contentOffset y that parent scrollView can have
        let parentViewMaxContentYOffset = parentScrollView.contentSize.height - parentScrollView.frame.height
        
        // if scrollView is going upwards
        if goingUp! {
            // if scrollView is a child scrollView
            
            if scrollView == childScrollView {
                // if parent scroll view is't scrolled maximum (i.e. menu isn't sticked on top yet)
                if parentScrollView.contentOffset.y < parentViewMaxContentYOffset && !childScrollingDownDueToParent {
                    
                    // change parent scrollView contentOffset y which is equal to minimum between maximum y offset that parent scrollView can have and sum of parentScrollView's content's y offset and child's y content offset. Because, we don't want parent scrollView go above sticked menu.
                    // Scroll parent scrollview upwards as much as child scrollView is scrolled
                    // Sometimes parent scrollView goes in the middle of screen and stucks there so max is used.
                    parentScrollView.contentOffset.y = max(min(parentScrollView.contentOffset.y + childScrollView.contentOffset.y, parentViewMaxContentYOffset), 0)
                    
                    // change child scrollView's content's y offset to 0 because we are scrolling parent scrollView instead with same content offset change.
                    childScrollView.contentOffset.y = 0
                }
            }
        }
            // Scrollview is going downwards
        else {
            
            if scrollView == childScrollView {
                // when child view scrolls down. if childScrollView is scrolled to y offset 0 (child scrollView is completely scrolled down) then scroll parent scrollview instead
                // if childScrollView's content's y offset is less than 0 and parent's content's y offset is greater than 0
                if childScrollView.contentOffset.y < 0 && parentScrollView.contentOffset.y > 0 {
                    
                    // set parent scrollView's content's y offset to be the maximum between 0 and difference of parentScrollView's content's y offset and absolute value of childScrollView's content's y offset
                    // we don't want parent to scroll more that 0 i.e. more downwards so we use max of 0.
                    parentScrollView.contentOffset.y = max(parentScrollView.contentOffset.y - abs(childScrollView.contentOffset.y), 0)
                }
            }
            
            // if downward scrolling view is parent scrollView
            if scrollView == parentScrollView {
                // if child scrollView's content's y offset is greater than 0. i.e. child is scrolled up and content is hiding up
                // and parent scrollView's content's y offset is less than parentView's maximum y offset
                // i.e. if child view's content is hiding up and parent scrollView is scrolled down than we need to scroll content of childScrollView first
                if childScrollView.contentOffset.y > 0 && parentScrollView.contentOffset.y < parentViewMaxContentYOffset {
                    // set if scrolling is due to parent scrolled
                    childScrollingDownDueToParent = true
                    // assign the scrolled offset of parent to child not exceding the offset 0 for child scroll view
                    childScrollView.contentOffset.y = max(childScrollView.contentOffset.y - (parentViewMaxContentYOffset - parentScrollView.contentOffset.y), 0)
                    // stick parent view to top coz it's scrolled offset is assigned to child
                    parentScrollView.contentOffset.y = parentViewMaxContentYOffset
                    childScrollingDownDueToParent = false
                }
            }
        }
        
    }
    
    
}


extension ProfileViewController: UICollectionViewDataSource {

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
        //    collectionView.backgroundView  = noDataLabel
            collectionView.backgroundColor = UIColor.smokeWhiteColor()
            noDataLabel.addGestureRecognizer(tapRec)
            noDataLabel.isUserInteractionEnabled = true
            childScrollView.addSubview(noDataLabel)
            noDataLabel.anchorCenterSuperview()
            if self.friends.count > 0 {
            self.stickyContainer.addBottomBorder(color: UIColor.tertiaryColor(), width: 3)
            }
            else {
            self.headerContainer.addBottomBorder(color: UIColor.tertiaryColor(), width: 3)
            }
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == friendsCollectionView {
        return self.friends.count
        }
        else {
        return self.tips.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == friendsCollectionView {
            let friendsCell = self.friendsCollectionView.dequeueReusableCell(withReuseIdentifier: friendsCellId, for: indexPath as IndexPath) as! FriendCell
            
          //  friendsCell.imageView.profileID = self.friends[indexPath.row].id
         //   friendsCell.imageView.profileID = "4"
            
            return friendsCell
        }
        else {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! ProfileGridCell
        
        cell.tipImage.backgroundColor = UIColor.tertiaryColor()
        cell.tipImage.tag = 15
        
        return cell
        }
    }

}



extension ProfileViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        if collectionView == friendsCollectionView {
            let urls = indexPaths.flatMap {
                URL(string: self.friends[$0.row].imageUrl)
            }
            ImagePrefetcher(urls: urls).start()
        }
        else {
        let urls = indexPaths.flatMap {
                    URL(string: self.tips[$0.row].tipImageUrl)
        }
        ImagePrefetcher(urls: urls).start()
        }
    }
}



extension ProfileViewController: TipEditDelegate {

    func editTip(_ tip: Tip) {
        tabBarController!.selectedIndex = 4
        NotificationCenter.default.post(name: Notification.Name(rawValue: "editTip"), object: nil, userInfo: ["tip": tip])
        
    }

}


extension ProfileViewController: ZoomImageDelegate {

    func didTapEdit() {
        self.openImagePicker()
    }
}
