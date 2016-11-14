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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var reachability: Reachability?
    let tapRec = UITapGestureRecognizer()
    var changeProfilePicture: UIImageView!
    var initialImage: UIImage!
    let dataService = DataService()
    
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var changeProfileView: UIImageView!
    //   @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var totalTipsLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var likesContainer: UIView!
    
    @IBOutlet weak var tipsContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapRec.addTarget(self, action: #selector(ProfileViewController.changeProfileViewTapped))
        self.configureNavBar()
        setupReachability(nil, useClosures: true)
        startNotifier()
        self.configureProfileImage()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupUserDetails()
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
        
        let title = Constants.NetworkConnection.NetworkPromptTitle
        let message = Constants.NetworkConnection.NetworkPromptMessage
        let cancelButtonTitle = Constants.NetworkConnection.RetryText
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            //  NSLog(Constants.Logs.CancelAlert)
        }
        
        
        // Add the actions.
        alertController.addAction(cancelAction)
        //     alertController.buttonBgColor[.Cancel] = UIColor(red: 227/255, green:19/255, blue:63/255, alpha:1)
        //     alertController.buttonBgColorHighlighted[.Cancel] = UIColor(red:230/255, green:133/255, blue:153/255, alpha:1)
        
        present(alertController, animated: true, completion: nil)
    }    
    
    
    // MARK: - Action
    
    
    func changeProfileViewTapped() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    /*
     @IBAction func editTapped(sender: AnyObject) {
     
     let imagePickerController = UIImagePickerController()
     imagePickerController.delegate = self
     imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
     
     self.presentViewController(imagePickerController, animated: true, completion: nil)
     }
     */
    
    /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        self.userProfileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        let profileImageData = UIImageJPEGRepresentation(self.userProfileImage.image!, 1)
        
        //     if profileImageData != nil {
        
        if let profileFileObject = PFFile(data: profileImageData!) {
            
            User.currentUser()!.setObject(profileFileObject, forKey: "profilePicture")
            
            //     let myUserDetails = (self.tabBarController as! TabBarController).myUserDetails
            
            
            
            
            // display activity indicator
            let window: UIWindow = UIApplication.shared.keyWindow!
            let loadingNotification = MBProgressHUD.showAdded(to: window, animated: true)
            loadingNotification.label.text = Constants.Notifications.LoadingNotificationText
            //    self.view.bringSubviewToFront(loadingNotification)
            User.currentUser()!.saveInBackgroundWithBlock { (success:Bool, error: NSError?) -> Void in
                
                loadingNotification.hideAnimated(true)
                
                if (error != nil) {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertController(title: Constants.Notifications.DefaultAlert, message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: Constants.Notifications.AlertConfirmation, style: UIAlertActionStyle.Default, handler: nil)
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    return
                    
                }
                
                
                if (success) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updateProfilePic(profileFileObject)
                        
                        let alert = UIAlertController(title: Constants.Notifications.ProfileUpdateTitle, message: Constants.Notifications.ProfileUpdateSuccess, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: Constants.Notifications.AlertConfirmation, style: UIAlertActionStyle.Default, handler: nil)
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    return
                    
                }
                
                
            }
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    */
    
    private func configureProfileImage() {
        
        
        dataService.CURRENT_USER_REF.observeSingleEvent(of: .value, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String : Any] {
                if let photoUrl = dictionary["photoUrl"] as? String {
                    
                    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
                    self.userProfileImage.clipsToBounds = true
                    self.userProfileImage.contentMode = .scaleAspectFill
                    self.userProfileImage.loadImageUsingCacheWithUrlString(urlString: photoUrl)
                    
                }
                
            }
            
        })
        
    }
    
    
    func setupUserDetails() {
        
        // Get a reference to the model data from the custom tab bar controller.
        
        //   let prefs = NSUserDefaults.standardUserDefaults()
        
        // Get first name
        //   myUserDetails.firstName = prefs.stringForKey("firstName")!
        
        // Get last name
        //    myUserDetails.lastName = prefs.stringForKey("lastName")!
        
        
        
        self.changeProfilePicture = UIImageView()
        changeProfilePicture.image = UIImage(named: "change-profile")
        changeProfilePicture.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(changeProfilePicture)
        
        changeProfilePicture.addGestureRecognizer(tapRec)
        changeProfilePicture.isUserInteractionEnabled = true
        
        
        self.likesContainer.layer.borderColor = UIColor.tertiaryColor().cgColor
        self.likesContainer.layer.borderWidth = 0.5
        self.tipsContainer.layer.borderColor = UIColor.tertiaryColor().cgColor
        self.tipsContainer.layer.borderWidth = 0.5
        
     
      //  self.fetchInfo()
        
        let profileWidthConstraint = NSLayoutConstraint(item: changeProfilePicture, attribute: .width, relatedBy: .equal,
                                                        toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        
        let profileHeightConstraint = NSLayoutConstraint(item: changeProfilePicture, attribute: .height, relatedBy: .equal,
                                                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        
        let profileBottomConstraint = NSLayoutConstraint(item: userProfileImage, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: changeProfilePicture, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 8.0)
        
        let profileTrailingConstraint = NSLayoutConstraint(item: userProfileImage, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: changeProfilePicture, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0)
        
        
        self.view.addConstraints([profileWidthConstraint, profileHeightConstraint, profileBottomConstraint, profileTrailingConstraint])
        
        
    }
    
    /*
    private func fetchInfo() {
        
        self.view.layoutIfNeeded()
        
        let query = User.query()
        query?.getObjectInBackgroundWithId((User.currentUser()?.objectId)!, block: { (object: PFObject?, error: NSError?) in
            if (error == nil) {
                
                if let object = object {
                    let fullName = object.objectForKey("additional") as! String
                    //     let lastName = object.objectForKey("lastName") as! String
                    let totalLikes = object.objectForKey("totalLikes") as? Int
                    let totalTips = object.objectForKey("totalTips") as? Int
                    let pic = object.objectForKey("profilePicture") as? PFFile
                    
                    self.firstNameLabel.text = fullName
                    if (totalLikes == nil && totalTips == nil && pic == nil) {
                        
                        let user = User.currentUser()!
                        user.setObject(0, forKey: "totalLikes")
                        user.setObject(0, forKey: "totalTips")
                        let file = PFFile(data: UIImageJPEGRepresentation(self.initialImage, 1.0)!)
                        user.setObject(file!, forKey: "profilePicture")
                        user.saveInBackgroundWithBlock({ (success, error) in
                            if (success) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.setUpUI(0, totalTips: 0, pic: file)
                                }
                            }
                        })
                        
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.setUpUI(totalLikes!, totalTips: totalTips!, pic: pic)
                        }
                    }
                    
                }
            }
            else if let error = error {
                self.showErrorView(error)
            }
        })
        
    }
    
    */
   /*
    private func setUpUI(totalLikes: Int, totalTips: Int, pic: PFFile?) {
        
        if (totalLikes == 1) {
            self.totalLikesLabel.text = String(totalLikes) + " like"
        }
        else {
            self.totalLikesLabel.text = String(totalLikes) + " likes"
        }
        
        if (totalTips == 1) {
            self.totalTipsLabel.text = String(totalTips) + " tip"
        }
        else {
            self.totalTipsLabel.text = String(totalTips) + " tips"
        }
        
        self.firstNameLabel.textColor = UIColor.primaryTextColor()
        self.totalLikesLabel.textColor = UIColor.primaryTextColor()
        self.totalTipsLabel.textColor = UIColor.primaryTextColor()
        
        self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
        self.userProfileImage.clipsToBounds = true
        self.userProfileImage.file = pic
        self.userProfileImage.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
            if (error != nil) {
                print("Error: \(error!) \(error!.userInfo)")
            } else {
            }
        }
        
        
        
    }

    
    
    private func updateProfilePic(pic: PFFile) {
        
        self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
        self.userProfileImage.clipsToBounds = true
        self.userProfileImage.file = pic
        self.userProfileImage.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
            if (error != nil) {
                print("Error: \(error!) \(error!.userInfo)")
            } else {
            }
        }
        
    }
    */
}
