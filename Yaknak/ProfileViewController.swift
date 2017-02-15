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
import Kingfisher


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var reachability: Reachability?
    let tapRec = UITapGestureRecognizer()
    var changeProfilePicture: UIImageView!
    var initialImage: UIImage!
    let dataService = DataService()
    private var collectionView : UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())   // Initialization
    var tips = [Tip]()
    var handle: UInt!
    var tipRef: FIRDatabaseReference!
    var currentUserRef: FIRDatabaseReference!
 //   var viewIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var totalTipsLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var tipsContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        if #available(iOS 10.0, tvOS 10.0, *) {
            self.collectionView.prefetchDataSource = self
        }
        /*
        self.viewIndicator = UIActivityIndicatorView(frame: self.view.frame)
        self.view.addSubview(self.viewIndicator)
        self.viewIndicator.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.gray
        self.viewIndicator.center = CGPoint(self.view.frame.width / 2, self.view.frame.height / 2);
        self.viewIndicator.startAnimating()
       */
        tapRec.addTarget(self, action: #selector(ProfileViewController.changeProfileViewTapped))
        self.configureNavBar()
        self.tipRef = dataService.TIP_REF
        self.currentUserRef = dataService.CURRENT_USER_REF
        setupReachability(nil, useClosures: true)
        startNotifier()
        self.hideUI()
     //   self.setupUI()
            self.setUpProfileDetails()
        
        self.tipsContainer.layer.addBorder(edge: .top, color: UIColor.secondaryTextColor(), thickness: 1.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //   self.setUpProfileDetails()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let handle = handle {
            self.tipRef.removeObserver(withHandle: handle)
        }
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
        
        let navLabel = UILabel()
        navLabel.contentMode = .scaleAspectFill
        navLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 70)
        //    navLogo.contentMode = .scaleAspectFit
        //  let image = UIImage(named: Constants.Images.NavImage)
        //  navLogo.image = image
        navLabel.text = "My tips"
        navLabel.textColor = UIColor.secondaryTextColor()
        
     //   let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
     //   navLogo.contentMode = .scaleAspectFit
     //   let image = UIImage(named: Constants.Images.NavImage)
     //   navLogo.image = image
        self.navigationItem.titleView = navLabel
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    func hideUI() {
        self.containerView.isHidden = true
        self.tipsContainer.isHidden = true
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
        let alertController = UIAlertController()
        alertController.networkAlert(title: Constants.NetworkConnection.NetworkPromptTitle, message: Constants.NetworkConnection.NetworkPromptMessage)
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
        
    //    self.userProfileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let img = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let resizedImage = img?.resizedImageWithinRect(rectSize: CGSize(200, 200)) {
        
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
                            self.dataService.CURRENT_USER_REF.updateChildValues(["photoUrl": photoUrl])
                            
                            // TODO
                            // get users' tips and update those user profile pics
                            // give user a tip attribute in database and store keys in there
                            
                            
                            self.dataService.TIP_REF.queryOrdered(byChild: "addedByUser").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                for tip in snapshot.children.allObjects as! [FIRDataSnapshot] {
                                    
                                      self.dataService.TIP_REF.child(tip.key).updateChildValues(["userPicUrl" : photoUrl])
                                    
                                    self.dataService.USER_TIP_REF.child(userId).child(tip.key).updateChildValues(["userPicUrl" : photoUrl])
                                
                                    if let category = (tip.value as! NSDictionary)["category"] as? String {
                                        
                                        self.dataService.CATEGORY_REF.child(category).child(tip.key).updateChildValues(["userPicUrl" : photoUrl])
                                      
                                    }
                                
                                }
                                
                                self.userProfileImage.image = resizedImage
                                loadingNotification.hide(animated: true)
                                
                                let alertController = UIAlertController()
                                alertController.defaultAlert(title: Constants.Notifications.ProfileUpdateTitle, message: Constants.Notifications.ProfileUpdateSuccess)
                                
                            })
                            
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
        
     /*
        let ai = UIActivityIndicatorView(frame: self.userProfileImage.frame)
        self.userProfileImage.addSubview(ai)
        ai.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.gray
        ai.center = CGPoint(self.userProfileImage.frame.width / 2, self.userProfileImage.frame.height / 2);
        ai.startAnimating()
*/
        self.currentUserRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String : Any] {
                
            
                if let photoUrl = dictionary["photoUrl"] as? String {
                    
                    let url = URL(string: photoUrl)
                    self.userProfileImage.kf.indicatorType = .activity
                    let processor = RoundCornerImageProcessor(cornerRadius: 20)
                    self.userProfileImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { receivedSize, totalSize in
                        print("Loading progress: \(receivedSize)/\(totalSize)")
                    },
                                                      completionHandler: { (image, error, cacheType, imageUrl) in
                        
                                                        if error == nil {
                                                            
                                                            self.setupUI()
                                                         //   ai.stopAnimating()
                                                         //   ai.removeFromSuperview()
                                                            self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
                                                            self.userProfileImage.clipsToBounds = true
                                                            
                                                            self.setUpEditIcon()
                                                            
                                                            if let name = dictionary["name"] as? String {
                                                                DispatchQueue.main.async() {
                                                                    self.firstNameLabel.text = name
                                                                }
                                                                
                                                                if let likes = dictionary["totalLikes"] as? Int {
                                                                    DispatchQueue.main.async() {
                                                                        self.totalLikesLabel.text = String(likes)
                                                                        
                                                                        if (likes == 1) {
                                                                            self.likesLabel.text = "Like"
                                                                        }
                                                                        else {
                                                                            self.likesLabel.text = "Likes"
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                
                                                                if let tips = dictionary["totalTips"] as? Int {
                                                                    
                                                                    self.totalTipsLabel.text = String(tips)
                                                                    
                                                                    if (tips == 1) {
                                                                        self.tipsLabel.text = "Tip"
                                                                    }
                                                                    else {
                                                                        self.tipsLabel.text = "Tips"
                                                                    }
                                                                    
                                                                    
                                                                    
                                                                    if tips > 0 {
                                                                        
                                                                        // get user's tips
                                                                        
                                                                        //      if let id = dictionary["uid"] as? String {
                                                                        self.tips.removeAll()
                                                                        let myGroup = DispatchGroup.init()
                                                                        var tipArray = [Tip]()
                                                                        
                                                                        DispatchQueue.main.async {
                                                                            
                                                                            LoadingOverlay.shared.setSize(width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!)
                                                                            let navBarHeight = self.navigationController!.navigationBar.frame.height
                                                                            LoadingOverlay.shared.reCenterIndicator(view: (self.navigationController?.view)!, navBarHeight: navBarHeight)
                                                                            LoadingOverlay.shared.showOverlay(view: (self.navigationController?.view)!)
                                                                            
                                                                            self.setUpGrid()
                                                                            self.collectionView.isHidden = false
                                                                            self.tipsContainer.backgroundColor = UIColor.white
                                                                        }
                                                                        
                                                                        self.handle = self.dataService.USER_TIP_REF.child(snapshot.key).observe(.childAdded, with: { (tipSnap) in
                                                                            
                                                                            myGroup.enter()
                                                                            
                                                                            if (tipSnap.value as? [String : Any]) != nil {
                                                                                let tipObject = Tip(snapshot: tipSnap)
                                                                                tipArray.append(tipObject)
                                                                            }
                                                                            else {
                                                                                self.tipsContainer.backgroundColor = UIColor.smokeWhiteColor()
                                                                                self.collectionView.isHidden = true
                                                                            }
                                                                            
                                                                            myGroup.leave()
                                                                            
                                                                            myGroup.notify(queue: DispatchQueue.main, execute: {
                                                                                self.tips = tipArray.reversed()
                                                                                
                                                                                UIView.animate(withDuration: 0.0, animations: { [weak self] in
                                                                                    guard let strongSelf = self else { return }
                                                                                    
                                                                                    strongSelf.collectionView.reloadData()
                                                                                    
                                                                                    }, completion: { [weak self] (finished) in
                                                                                        guard self != nil else { return }
                                                                                        
                                                                                        LoadingOverlay.shared.hideOverlayView()
                                                                                })
                                                                                
                                                                 
                                                                            })
                                                                            
                                                                        })
                                                                        
                                                             
                                                                    }
                                                                    
                                                                }
                                                            }
                                                        
                                                        }
                                                        else {
                                                        
                                                        }
                        
                    })
                   
                   /*
                    self.userProfileImage.loadImage(urlString: photoUrl, placeholder: nil, completionHandler: { (success) in
                        
                        if success {
                            
                         //   self.viewIndicator.stopAnimating()
                         //   self.viewIndicator.removeFromSuperview()
                            self.setupUI()
                            ai.stopAnimating()
                            ai.removeFromSuperview()
                            self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
                            self.userProfileImage.clipsToBounds = true
                            
                        self.setUpEditIcon()
                            
                            if let name = dictionary["name"] as? String {
                                DispatchQueue.main.async() {
                                    self.firstNameLabel.text = name
                                }
                                
                                if let likes = dictionary["totalLikes"] as? Int {
                                    DispatchQueue.main.async() {
                                        self.totalLikesLabel.text = String(likes)
                                        
                                        if (likes == 1) {
                                            self.likesLabel.text = "Like"
                                        }
                                        else {
                                            self.likesLabel.text = "Likes"
                                        }
                                    }
                                    
                                }
                                
                                if let tips = dictionary["totalTips"] as? Int {
                                    
                                    self.totalTipsLabel.text = String(tips)
                                    
                                    if (tips == 1) {
                                        self.tipsLabel.text = "Tip"
                                    }
                                    else {
                                        self.tipsLabel.text = "Tips"
                                    }
                                    
                                    
                        
                                    if tips > 0 {
                                        
                                        // get user's tips
                                        
                                        //      if let id = dictionary["uid"] as? String {
                                        self.tips.removeAll()
                                        let myGroup = DispatchGroup.init()
                                        var tipArray = [Tip]()
                                        
                                        DispatchQueue.main.async {
                                            
                                            LoadingOverlay.shared.setSize(width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!)
                                            let navBarHeight = self.navigationController!.navigationBar.frame.height
                                            LoadingOverlay.shared.reCenterIndicator(view: (self.navigationController?.view)!, navBarHeight: navBarHeight)
                                            LoadingOverlay.shared.showOverlay(view: (self.navigationController?.view)!)
                                            
                                            self.setUpGrid()
                                                self.collectionView.isHidden = false
                                                self.tipsContainer.backgroundColor = UIColor.white
                                        }
                                        
                                        self.handle = self.dataService.USER_TIP_REF.child(snapshot.key).observe(.childAdded, with: { (tipSnap) in
                                            
                                           myGroup.enter()
                                            
                                            if (tipSnap.value as? [String : Any]) != nil {
                                                let tipObject = Tip(snapshot: tipSnap)
                                                tipArray.append(tipObject)
                                            }
                                            else {
                                                self.tipsContainer.backgroundColor = UIColor.smokeWhiteColor()
                                                self.collectionView.isHidden = true
                                            }
                                            
                                            myGroup.leave()
                                            
                                            myGroup.notify(queue: DispatchQueue.main, execute: {
                                            self.tips = tipArray.reversed()
                                                
                                                UIView.animate(withDuration: 0.0, animations: { [weak self] in
                                                    guard let strongSelf = self else { return }
                                                    
                                                    strongSelf.collectionView.reloadData()
                                                    
                                                    }, completion: { [weak self] (finished) in
                                                        guard self != nil else { return }
                                                        
                                                     LoadingOverlay.shared.hideOverlayView()
                                                })
                                                
                                        //    self.collectionView.reloadData()
                                            })
                                            
                                        })
                                        
                                        /*
                                        self.handle = self.dataService.USER_TIP_REF.child(snapshot.key).observe( .childAdded, with: { (tip) in
                                            
                                            let tipsRef = self.tipRef.child(tip.key)
                                            tipsRef.observeSingleEvent(of: .value, with: { (tipSnap) in
                                                
                                                
                                                if (tipSnap.value as? [String : Any]) != nil {
                                                    
                                                    //   var newTip = Tip()
                                                    myGroup.enter()
                                                    let tipObject = Tip(snapshot: tipSnap)
                                                    //      newTips.append(tipObject)
                                                    //      self.tips += tipObject
                                                    self.tips.append(tipObject)
                                                    DispatchQueue.main.async {
                                                
                                                    self.collectionView.reloadData()
                                                    }
                                                    myGroup.leave()
                                                    
                                                    myGroup.notify(queue: DispatchQueue.main, execute: {
                                                        self.tips.reverse()
                                                        DispatchQueue.main.async {
                                                                                                        self.collectionView.isHidden = false
                                                            self.tipsContainer.backgroundColor = UIColor.white
                                                        //    self.collectionView.reloadData()
                                                            self.collectionView.activityIndicatorView.stopAnimating()
                                                        }
                                                    })
                                                    
                                                    
                                                }
                                                else {
                                                    self.tipsContainer.backgroundColor = UIColor.smokeWhiteColor()
                                                    self.collectionView.isHidden = true
                                                }
                                                
                                            })
                                            
                                        })
                                        
                                        */
                                    }
                                    
                                }
                            }
                        }
                        else {
                            ai.stopAnimating()
                            ai.removeFromSuperview()

                        }
                        
                    })
                    
                    */
                }
                else {
                print("no data loaded yet...")
                  //  ai.stopAnimating()
                  //  ai.removeFromSuperview()
                }
                
            }
            
        })
        
    }
    
    
    func setupUI() {
      
        self.containerView.isHidden = false
        self.tipsContainer.isHidden = false
        self.firstNameLabel.textColor = UIColor.primaryTextColor()
        self.totalLikesLabel.textColor = UIColor.primaryTextColor()
        self.totalTipsLabel.textColor = UIColor.primaryTextColor()
        self.tipsLabel.textColor = UIColor.secondaryTextColor()
        self.likesLabel.textColor = UIColor.secondaryTextColor()
        self.tipsContainer.layer.borderColor = UIColor.tertiaryColor().cgColor
        self.tipsContainer.layer.borderWidth = 0.5
        
    }
    
    private func setUpEditIcon() {
    
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
 
    
    private func setUpGrid() {
    
     //   let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
     //   layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
     //   let width = (self.view.frame.width / 3) - 2
     //   layout.itemSize = CGSize(width: width, height: width)
  //      layout.minimumInteritemSpacing = 1
  //      layout.minimumLineSpacing = 1
      //  collectionView = UICollectionView()
     //   let frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 5, width: self.view.frame.width, height: self.view.frame.height - 10)
    //    collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
      //  layout.estimatedItemSize = CGSize(200, 200)
        self.collectionView.register(UINib(nibName: "ProfileGridCell", bundle: nil), forCellWithReuseIdentifier: "ProfileGridCell")
    //    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellIdentifier")
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        self.collectionView.isHidden = true
        self.collectionView.clipsToBounds = true
     //   self.collectionView.activityIndicatorView.startAnimating()
        
        let gridWidthConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .width, relatedBy: .equal,
                                                        toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.tipsContainer.frame.width)
        
    //    let gridHeightConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .height, relatedBy: .equal,
      //                                                   toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.tipsContainer.frame.height - 10)
        
        let gridBottomConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
        
        let gridTopConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 5.0)
        
        let gridTrailingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0)
        
        let gridLeadingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.tipsContainer, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0)
        
        
         self.view.addConstraints([gridWidthConstraint, gridBottomConstraint, gridTopConstraint, gridTrailingConstraint, gridLeadingConstraint])
    
    }
    
  /*
    private func gridCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: ProfileGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileGridCell", for: indexPath as IndexPath) as! ProfileGridCell
        
        
        let url = URL(string: self.tips[indexPath.row].tipImageUrl)
        let processor = ResizingImageProcessor(targetSize: CGSize(width: 250, height: 250))
        cell.tipImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { receivedSize, totalSize in
            print("Loading progress: \(receivedSize)/\(totalSize)")
        },
                                  completionHandler: { (image, error, cacheType, imageUrl) in
                                    
                                    if error == nil {
                                     //   cell.tipImage.contentMode = .scaleAspectFill
                                     //   cell.tipImage.clipsToBounds = true
                                    }
                                    else {
                                    print(error?.localizedDescription)
                                    }
                                    
        })
        
        /*
        // fill imageArray before populating cells
        cell.tipImage.loadThumbnail(urlString: self.tips[indexPath.row].tipImageUrl, placeholder: nil) { (success) in
            
            if success {
                cell.tipImage.contentMode = .scaleAspectFill
                cell.tipImage.clipsToBounds = true
                
            }
        }
        */
       
        
        return cell
    }
    */
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.tips.count

    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
     //   _ = self.gridCellForIndexPath(indexPath: indexPath as NSIndexPath)
        let url = URL(string: self.tips[indexPath.row].tipImageUrl)
        let processor = ResizingImageProcessor(targetSize: CGSize(width: 250, height: 250))
        _ = (cell as! ProfileGridCell).tipImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { receivedSize, totalSize in
            print("Loading progress: \(receivedSize)/\(totalSize)")
        },
                                  completionHandler: { (image, error, cacheType, imageUrl) in
                                    
                                    if error == nil {
                                        //   cell.tipImage.contentMode = .scaleAspectFill
                                        //   cell.tipImage.clipsToBounds = true
                                    }
                                    else {
                                        print(error?.localizedDescription)
                                    }
                                    
        })
    }
  
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     //   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath)
        let cell: ProfileGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileGridCell", for: indexPath as IndexPath) as! ProfileGridCell
     //   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath) as UICollectionViewCell
     //   cell.backgroundColor = UIColor.orange
        cell.tipImage.kf.indicatorType = .activity
        
        return cell
     //   return cell
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
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let singleTipViewController = SingleTipViewController()
        singleTipViewController.tip = self.tips[indexPath.row]
        self.addChildViewController(singleTipViewController)
        singleTipViewController.view.frame = self.view.frame
        self.view.addSubview(singleTipViewController.view)
        singleTipViewController.didMove(toParentViewController: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    (cell as! ProfileGridCell).tipImage.kf.cancelDownloadTask()
    }
    

    
    
}


extension ProfileViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    //    let urls = indexPaths.flatMap {
    //        URL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-\($0.row + 1).jpg")
    //    }
        
      //  ImagePrefetcher(urls: urls).start()
    }
}
