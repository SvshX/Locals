//
//  ProfileViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import MBProgressHUD
import ReachabilitySwift
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var reachability: Reachability?
    let tapRec = UITapGestureRecognizer()
    var changeProfilePicture: UIImageView!
    var initialImage: UIImage!
    let dataService = DataService()
    var collectionView: UICollectionView!
    var tips = [Tip]()
    var handle: UInt!
    var tipRef: FIRDatabaseReference!
    var currentUserRef: FIRDatabaseReference!
    
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var totalTipsLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var tipsContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapRec.addTarget(self, action: #selector(ProfileViewController.changeProfileViewTapped))
        self.configureNavBar()
        self.tipRef = dataService.TIP_REF
        self.currentUserRef = dataService.CURRENT_USER_REF
        setupReachability(nil, useClosures: true)
        startNotifier()
        self.setupUI()
        self.setUpProfileDetails()
        
        self.tipsContainer.layer.addBorder(edge: .top, color: UIColor.secondaryTextColor(), thickness: 1.0)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tipRef.removeObserver(withHandle: handle)
        self.currentUserRef.removeObserver(withHandle: handle)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reachability!.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configureNavBar() {
        
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        navLogo.contentMode = .scaleAspectFit
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        self.navigationItem.titleView = navLogo
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        
        let reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        self.reachability = reachability
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                print(Constants.Notifications.WiFi)
                
            }
            reachability?.whenUnreachable = { reachability in
                DispatchQueue.main.async {
                    print(Constants.Notifications.NotReachable)
                    self.popUpPrompt()
                }
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            print(Constants.Notifications.NoNotifier)
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            print(Constants.Notifications.WiFi)
        } else {
            print(Constants.Notifications.NotReachable)
            self.popUpPrompt()
        }
    }
    
    deinit {
        stopNotifier()
    }
    
    
    func popUpPrompt() {
        AlertViewHelper.promptNetworkFail()
    }
    
    // MARK: - Action
    
    
    func changeProfileViewTapped() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addATip(_ sender: AnyObject) {
        tabBarController!.selectedIndex = 4
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        let window: UIWindow = UIApplication.shared.keyWindow!
        let loadingNotification = MBProgressHUD.showAdded(to: window, animated: true)
        loadingNotification.label.text = Constants.Notifications.LoadingNotificationText
        
        self.userProfileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if let resizedImage = self.userProfileImage.image?.resizedImage(newSize: CGSize(250, 250)) {
        
        let profileImageData = UIImageJPEGRepresentation(resizedImage, 1)
        
        if let data = profileImageData {
            
            let currentUser = FIRAuth.auth()?.currentUser
            if let userId = currentUser?.uid {
                //Create Path for the User Image
                let imagePath = "profileImage\(userId)/userPic.jpg"
                
                
                // Create image Reference
                
                let imageRef = dataService.STORAGE_REF.child(imagePath)
                
                // Create Metadata for the image
                
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                
                // Save the user Image in the Firebase Storage File
                
                let uploadTask = imageRef.put(data as Data, metadata: metaData) { (metaData, error) in
                    if error == nil {
                        
                        if let photoUrl = metaData?.downloadURL()?.absoluteString {
                            self.dataService.CURRENT_USER_REF.updateChildValues(["photoUrl": photoUrl])
                            loadingNotification.hide(animated: true)
                            
                            AlertViewHelper.promptDefaultAlert(title: Constants.Notifications.ProfileUpdateTitle, message: Constants.Notifications.ProfileUpdateSuccess)
                            
                        }
                        
                    }
                    
                }
                uploadTask.observe(.progress) { snapshot in
                    print(snapshot.progress) // NSProgress object
                }

                
            }
        }
    }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func setUpProfileDetails() {
        
        
        self.handle = self.currentUserRef.observe( .value, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String : Any] {
                
                if let name = dictionary["name"] as? String {
                    DispatchQueue.main.async() {
                        self.firstNameLabel.text = name
                    }
             //   }
                
                if let likes = dictionary["totalLikes"] as? Int {
                    DispatchQueue.main.async() {
                            self.totalLikesLabel.text = String(likes)
                    }
                    
                }
                
                if let tips = dictionary["totalTips"] as? Int {
                   
                        self.totalTipsLabel.text = String(tips)
                
                
                    
                    if tips > 0 {
                    
                    
                    // get user's tips
                        
                  //      if let id = dictionary["uid"] as? String {
                            
                            DispatchQueue.main.async {
                            self.setUpGrid()
                            }
                        
                         self.handle = self.tipRef.queryOrdered(byChild: "userName").queryEqual(toValue: name).observe( .value, with: { (snapshot) in
                            
                            
                            if (snapshot.value as? [String : Any]) != nil {
                                
                                var newTips = [Tip]()
                                for tip in snapshot.children {
                                    print(snapshot.childrenCount)
                                    let tipObject = Tip(snapshot: tip as! FIRDataSnapshot)
                                    newTips.append(tipObject)
                                }
                                
                            self.tips = newTips
                                DispatchQueue.main.async {
                                    self.collectionView.isHidden = false
                                    self.tipsContainer.backgroundColor = UIColor.white
                                    self.collectionView.reloadData()
                                }
                            
                            
                            }
                            else {
                            self.tipsContainer.backgroundColor = UIColor.smokeWhiteColor()
                            self.collectionView.isHidden = true
                            }
                         })
                        
                  //      }
                        }
                    
                    }
                }
                
                if let photoUrl = dictionary["photoUrl"] as? String {
                    
                    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
                    self.userProfileImage.clipsToBounds = true
                    self.userProfileImage.contentMode = .scaleAspectFill
                    self.userProfileImage.loadImageUsingCacheWithUrlString(urlString: photoUrl)
                    
                }
                
            }
            
        })
        
    }
    
    
    func setupUI() {
        
        self.firstNameLabel.textColor = UIColor.primaryTextColor()
        self.totalLikesLabel.textColor = UIColor.primaryTextColor()
        self.totalTipsLabel.textColor = UIColor.primaryTextColor()
        
        self.changeProfilePicture = UIImageView()
        changeProfilePicture.image = UIImage(named: "change-profile")
        changeProfilePicture.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(changeProfilePicture)
        
        changeProfilePicture.addGestureRecognizer(tapRec)
        changeProfilePicture.isUserInteractionEnabled = true
        
    //    self.likesContainer.layer.borderColor = UIColor.tertiaryColor().cgColor
    //    self.likesContainer.layer.borderWidth = 0.5
        self.tipsContainer.layer.borderColor = UIColor.tertiaryColor().cgColor
        self.tipsContainer.layer.borderWidth = 0.5
        
        let profileWidthConstraint = NSLayoutConstraint(item: changeProfilePicture, attribute: .width, relatedBy: .equal,
                                                        toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 28)
        
        let profileHeightConstraint = NSLayoutConstraint(item: changeProfilePicture, attribute: .height, relatedBy: .equal,
                                                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 28)
        
        let profileBottomConstraint = NSLayoutConstraint(item: userProfileImage, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: changeProfilePicture, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
        
        let profileTrailingConstraint = NSLayoutConstraint(item: userProfileImage, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: changeProfilePicture, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: -2.0)
        
        
        self.view.addConstraints([profileWidthConstraint, profileHeightConstraint, profileBottomConstraint, profileTrailingConstraint])
        
        
    }
    
    
    private func setUpGrid() {
    
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        let width = (view.frame.width - 2) / 3
        layout.itemSize = CGSize(width: width, height: width)
      //  collectionView = UICollectionView()
        let frame = CGRect(x: self.view.frame.origin.x + 5, y: self.view.frame.origin.y + 5, width: self.view.frame.width - 10, height: self.view.frame.height - 10)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView!.register(UINib(nibName: "ProfileGridCell", bundle: nil), forCellWithReuseIdentifier: "ProfileGridCell")
        collectionView.backgroundColor = UIColor.white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        collectionView.isHidden = true
        
        let gridWidthConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .width, relatedBy: .equal,
                                                        toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.width - 10)
        
  //      let gridHeightConstraint = NSLayoutConstraint(item: changeProfilePicture, attribute: .height, relatedBy: .equal,
   //                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
        
        let gridBottomConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 5.0)
        
        let gridTopConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 5.0)
        
        let gridTrailingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 5.0)
        
        let gridLeadingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 5.0)
        
        
         self.view.addConstraints([gridWidthConstraint, gridBottomConstraint, gridTopConstraint, gridTrailingConstraint, gridLeadingConstraint])
    
    }
    
    
    private func gridCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: ProfileGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileGridCell", for: indexPath as IndexPath) as! ProfileGridCell
        
        
        // fill imageArray before populating cells
        cell.tipImage.loadImageUsingCacheWithUrlString(urlString: self.tips[indexPath.row].tipImageUrl)
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tips.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   //     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath)
   //     cell.backgroundColor = UIColor.orange
        
        return  self.gridCellForIndexPath(indexPath: indexPath as NSIndexPath)
    }
 /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 2) / 3
        //    let width = collectionView.frame.width / 3 - 1
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
  */  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let singleTipViewController = SingleTipViewController()
        singleTipViewController.tip = self.tips[indexPath.row]
        self.addChildViewController(singleTipViewController)
        singleTipViewController.view.frame = self.view.frame
        self.view.addSubview(singleTipViewController.view)
        singleTipViewController.didMove(toParentViewController: self)
        
    }
    
    
}
