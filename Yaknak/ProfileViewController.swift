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



class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ZoomImageDelegate {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let tapRec = UITapGestureRecognizer()
    var changeProfilePicture: UIImageView!
    let dataService = DataService()
    var collectionView : UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())   // Initialization
    var tips = [Tip]()
    var user: User!
    var handle: UInt!
    var tipRef: FIRDatabaseReference!
    var currentUserRef: FIRDatabaseReference!
    var tabBarVC: TabBarController!
    
    
    @IBOutlet weak var userProfileImage: ZoomingImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var totalTipsLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var tipsContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavBar()
        self.tipRef = dataService.TIP_REF
        self.currentUserRef = dataService.CURRENT_USER_REF
        self.setData()
        self.toggleUI(false)
        self.userProfileImage.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ProfileViewController.updateProfile),
                                               name: NSNotification.Name(rawValue: "updateProfile"),
                                               object: nil)
        
        
        tapRec.addTarget(self, action: #selector(ProfileViewController.changeProfileViewTapped))
        
        self.setupDetails(completion: { success in
        
            if success {
                
                if (self.tips.count > 0) {
                    
                    self.setupGrid()
                    self.reloadTipGrid()
                }
                else {
                    self.toggleUI(true)
                }
            }
        })
    }
    
    func setData() {
        self.tabBarVC = self.tabBarController as? TabBarController
        self.user = self.tabBarVC.user
        self.tips = self.tabBarVC.tips
    }
    
    
    func toggleUI(_ show: Bool) {
    
        if show {
            self.containerView.isHidden = false
            self.tipsContainer.isHidden = false
            self.userProfileImage.isHidden = false
            self.firstNameLabel.isHidden = false
            self.totalLikesLabel.isHidden = false
            self.totalTipsLabel.isHidden = false
            self.tipsLabel.isHidden = false
            self.likesLabel.isHidden = false
            self.firstNameLabel.textColor = UIColor.primaryTextColor()
            self.totalLikesLabel.textColor = UIColor.primaryTextColor()
            self.totalTipsLabel.textColor = UIColor.primaryTextColor()
            self.tipsLabel.textColor = UIColor.secondaryTextColor()
            self.likesLabel.textColor = UIColor.secondaryTextColor()
            self.tipsContainer.layer.borderColor = UIColor.tertiaryColor().cgColor
            self.tipsContainer.layer.borderWidth = 0.5
            self.containerView.layer.addBorder(edge: .bottom, color: UIColor.secondaryTextColor(), thickness: 0.5)
            self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
            self.setupEditIcon()
            LoadingOverlay.shared.hideOverlayView()
        }
        else {
            self.containerView.isHidden = true
            self.tipsContainer.isHidden = true
            self.userProfileImage.isHidden = true
            self.firstNameLabel.isHidden = true
            self.totalLikesLabel.isHidden = true
            self.totalTipsLabel.isHidden = true
            self.tipsLabel.isHidden = true
            self.likesLabel.isHidden = true
            
            if let navView = self.navigationController?.view {
                if let navBarHeight = self.navigationController?.navigationBar.frame.height {
            LoadingOverlay.shared.setSize(width: navView.frame.width, height: navView.frame.height)
            LoadingOverlay.shared.reCenterIndicator(view: navView, navBarHeight: navBarHeight)
            LoadingOverlay.shared.showOverlay(view: navView)
            }
            }
        }
    
    
    }
    
    func setupDetails(completion: @escaping (Bool) -> ()) {
        
        self.setProfilePic(completion: { (Void) in
            
            self.firstNameLabel.text = self.user.name
            
            if let likes = self.user.totalLikes {
                self.totalLikesLabel.text = "\(likes)"
                
                if (likes == 1) {
                    self.likesLabel.text = "Like"
                }
                else {
                    self.likesLabel.text = "Likes"
                }
            }
            
            if let tips = self.user.totalTips {
                self.totalTipsLabel.text = "\(tips)"
                
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
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let handle = handle {
            self.tipRef.removeObserver(withHandle: handle)
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
    
    
    func updateProfile() {
        
        self.user = nil
        self.tips.removeAll()

        if let tabVC = self.tabBarVC {
        self.user = tabVC.user
        self.tips = tabVC.tips
        }
        
        self.toggleUI(false)
        
        self.setupDetails(completion: { success in
            
            if success {
                
                if (self.tips.count > 0) {
                    
                    self.setupGrid()
                    self.reloadTipGrid()
                }
                else {
                    self.collectionView.isHidden = true
                    self.toggleUI(true)
                }
            }
        })
    }
    
    
    func popUpPrompt() {
        let alertController = UIAlertController()
        alertController.networkAlert(Constants.NetworkConnection.NetworkPromptMessage)
    }
    
    // MARK: - Action
    
    
    
    func didTapEdit() {
        self.openImagePicker()
    }
    
    
    func changeProfileViewTapped() {
        self.openImagePicker()
    }
    
    
    @IBAction func addATip(_ sender: AnyObject) {
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
        if let resizedImage = img?.resizeImageAspectFill(newSize: CGSize(150, 150)) {
            
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
                        self.userProfileImage.image = resizedImage
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
    
    
    private func setProfilePic(completion: @escaping (Void) -> Void) {
        
        let url = URL(string: self.user.photoUrl)
        
        self.userProfileImage.kf.indicatorType = .activity
     //   let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill)
        let processor = ResizingImageProcessor(targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill)
        self.userProfileImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
            print("\(receivedSize)/\(totalSize)")
        }) { (image, error, cacheType, imageUrl) in
            
            if (image == nil) {
                self.userProfileImage.image = UIImage(named: Constants.Images.ProfilePlaceHolder)
            }
            
            completion()
        }
    }
    
    
    
    private func reloadTipGrid() {
        
        UIView.animate(withDuration: 0.0, animations: { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.collectionView.reloadData()
            
            }, completion: { [weak self] (finished) in
                guard let strongSelf = self else { return }
                
                // Do whatever is needed, reload is finished here
                // e.g. scrollToItemAtIndexPath
                strongSelf.toggleUI(true)
                strongSelf.collectionView.isHidden = false
        })
    }
    
    
    private func setupEditIcon() {
        
        self.changeProfilePicture = UIImageView()
        self.changeProfilePicture.image = UIImage(named: "change-profile")
        self.changeProfilePicture.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(changeProfilePicture)
        
        self.changeProfilePicture.addGestureRecognizer(tapRec)
        self.changeProfilePicture.isUserInteractionEnabled = true
        
        let profileWidthConstraint = NSLayoutConstraint(item: changeProfilePicture, attribute: .width, relatedBy: .equal,
                                                        toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 28)
        
        let profileHeightConstraint = NSLayoutConstraint(item: changeProfilePicture, attribute: .height, relatedBy: .equal,
                                                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 28)
        
        let profileBottomConstraint = NSLayoutConstraint(item: userProfileImage, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: changeProfilePicture, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
        
        let profileTrailingConstraint = NSLayoutConstraint(item: userProfileImage, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: changeProfilePicture, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: -2.0)
        
        
        self.view.addConstraints([profileWidthConstraint, profileHeightConstraint, profileBottomConstraint, profileTrailingConstraint])
                
    }
    
    
    
    override func viewDidLayoutSubviews() {
        let frame = self.tipsContainer.frame
        self.collectionView.frame = CGRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
    }
    
    
    private func setupGrid() {
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "ProfileGridCell", bundle: nil), forCellWithReuseIdentifier: "ProfileGridCell")
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
            collectionView.isPrefetchingEnabled = true
        }
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        self.collectionView.isHidden = true
        self.collectionView.clipsToBounds = true
        
        let gridWidthConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .width, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.tipsContainer.frame.width)
        
        let gridBottomConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
        
        let gridTopConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 5.0)
        
        let gridTrailingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0)
        
        let gridLeadingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0)
        
        
        self.view.addConstraints([gridWidthConstraint, gridBottomConstraint, gridTopConstraint, gridTrailingConstraint, gridLeadingConstraint])
        
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
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.tips.count
        
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
        
         let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileGridCell", for: indexPath as IndexPath) as! ProfileGridCell
        
        cell.tipImage.backgroundColor = UIColor.tertiaryColor()
        cell.tipImage.tag = 15
        
        return cell
        }
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ProfileGridCell).tipImage.kf.cancelDownloadTask()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        let singleTipViewController = SingleTipViewController()
        singleTipViewController.tip = self.tips[indexPath.row]
        let view: UIImageView = cell?.viewWithTag(15) as! UIImageView
        singleTipViewController.tipImage = view.image
        self.addChildViewController(singleTipViewController)
        singleTipViewController.view.frame = self.view.frame
        self.view.addSubview(singleTipViewController.view)
        singleTipViewController.didMove(toParentViewController: self)
        
    }
    
}


extension ProfileViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap {
            
                    URL(string: self.tips[$0.row].tipImageUrl)
        }
        
        ImagePrefetcher(urls: urls).start()
    }
}
