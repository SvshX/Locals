//
//  SettingsViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 10/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import HTHorizontalSelectionList
//import ReachabilitySwift
import MBProgressHUD
import FBSDKLoginKit
import FirebaseAuth
import Firebase
import GeoFire



private let selectionListHeight: CGFloat = 50

class SettingsViewController: UITableViewController {
    
    var selectionList : HTHorizontalSelectionList!
    var selectedDuration: Int?
    let header = UITableViewHeaderFooterView()
    let logoView = UIImageView()
    let versionLabel = UILabel()
 //   var reachability: Reachability?
    var dataService = DataService()
    var loadingNotification = MBProgressHUD()
 //   var distanceIndex: Int?
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    
    //   @IBOutlet weak var selectionList: HTHorizontalSelectionList!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
 //   var dismissButton = MalertButtonStruct(title: Constants.Notifications.AlertAbort) {
 //       MalertManager.shared.dismiss()
 //   }
    
 //   lazy var alertView: CustomAlertView = {
 //       return CustomAlertView.instantiateFromNib()
 //   }()
    
    //   var wallControllerAsDelegate: SettingsControllerDelegate?
    
    
    // outlet and action - refresh time
    //    @IBOutlet var refreshTimeLabel: UILabel!
    //
    //    @IBOutlet var refreshTime: UIStepper!
    //    @IBAction func refreshTimeChanged(sender: UIStepper) {
    //
    //        // set label
    //        self.refreshTimeLabel.text = "\(Int(sender.value)) Seconds"
    //
    //        // set value within settings manager
    //        SettingsManager.sharedInstance.refreshTime = Int(sender.value)
    //    }
    
    /*
     // Push notifications in future
     
     
     @IBOutlet weak var enableNotifications: UISwitch!
     @IBAction func enableNotificationsChanged(sender: UISwitch) {
     
     if sender.on {
     
     // set label
     //       self.likeAppLabel.text = "YES"
     
     // set value within settings manager
     SettingsManager.sharedInstance.enableNotifications = true
     
     OneSignal.IdsAvailable({ (userId, pushToken) in
     print("UserId:%@", userId);
     if (pushToken != nil) {
     NSLog("pushtoken successfully delivered.");
     OneSignal.sendTags(["userIdTag" : userId, "parseIdTag" : User.currentUser()!.objectId!])
     //     OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": [userId]]);
     }
     });
     
     } else {
     
     // set label
     //    self.likeAppLabel.text = "NO"
     
     // set value within settings manager
     SettingsManager.sharedInstance.enableNotifications = false
     
     OneSignal.deleteTags(["userIdTag", "parseIdTag"])
     }
     
     }
     
     
     // Push notifications in future
     
     */
    
    
    // outlet and action - default volume
    //    @IBOutlet var defaultVolumeLabel: UILabel!
    //
    //    @IBOutlet var defaultVolume: UISlider!
    //    @IBAction func defaultVolumeChanged(sender: UISlider) {
    //
    //        // set label
    //        self.defaultVolumeLabel.text = "\(Int(sender.value*100)) %"
    //
    //        // set value within settings manager
    //        SettingsManager.sharedInstance.defaultVolume = sender.value
    //    }
    
    
    //   @IBOutlet weak var defaultWalkingDistance: UISegmentedControl!
    
    //   @IBAction func defaultWalkingDistanceChanged(sender: UISegmentedControl) {
    
    // set value within settings manager
    //       SettingsManager.sharedInstance.defaultWalkingDistance = sender.selectedSegmentIndex
    
    //   }
    
    
    //   weak var defaultWalkingDistance: HTHorizontalSelectionList!
    
    //   func defaultWalkingDistanceChanged() {
    
    //       SettingsManager.sharedInstance.defaultWalkingDistance = Double(self.selectedDistance)!
    
    
    //   }
    
    
    // outlet and action - default map type
    //    @IBOutlet var defaultMapType: UISegmentedControl!
    //    @IBAction func defaultMapTypeChanged(sender: UISegmentedControl) {
    //
    //        // set value within settings manager
    //        SettingsManager.sharedInstance.defaultMapType = sender.selectedSegmentIndex
    //    }
    
    
    //   @IBAction func dismissSettings(sender: AnyObject) {
    //       self.dismissViewControllerAnimated(true, completion: nil)
    //   }
    
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        tabBarController?.selectedIndex = 2
    }
   
    
    @IBAction func deleteAccountTapped(_ sender: AnyObject) {
        self.popUpDeletePrompt()
    }
    
    
    override func viewDidLoad() {
        
   //     setupReachability(nil, useClosures: true)
   //     startNotifier()
        // tip distance selection list
        //   durations = Constants.Durations
        //  self.edgesForExtendedLayout = .none
        
        
        self.selectionList = HTHorizontalSelectionList(frame: CGRect(0, 60, self.view.frame.size.width, 40))
        self.selectionList.delegate = self
        self.selectionList.dataSource = self
        
        self.selectionList.selectionIndicatorStyle = .bottomBar
        self.selectionList.selectionIndicatorColor = UIColor.primaryColor()
        self.selectionList.bottomTrimHidden = true
        self.selectionList.centerButtons = true
        
        self.selectionList.buttonInsets = UIEdgeInsetsMake(3, 10, 3, 10);
        self.view.addSubview(self.selectionList)
        //    self.selectionList.frame = self.view.bounds
        //    self.selectionView.addSubview(self.selectionList)
        
        self.configureNavBar()
        
        // Push notifications in future
        // set notification value
        //    self.setValueNotifications()
        
        if UserDefaults.standard.object(forKey: "defaultWalkingDuration") == nil {
            self.selectionList.setSelectedButtonIndex(2, animated: false)
        }
            
        else {
            // set default walking distance value
            self.setValueDefaultWalkingDuration()
        }
        
    //    self.distanceIndex = self.selectionList.selectedButtonIndex
        
        let nib = UINib(nibName: "TableSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
   //     reachability!.stopNotifier()
   //     NotificationCenter.default.removeObserver(self,
   //                                               name: ReachabilityChangedNotification,
     //                                             object: reachability)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      /*
        if self.distanceIndex != self.selectionList.selectedButtonIndex {
            self.distanceIndex = self.selectionList.selectedButtonIndex
            NotificationCenter.default.post(name: Notification.Name(rawValue: "distanceChanged"), object: nil)
        }
 */
    }
  
 /*
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
            NoNetworkOverlay.hide()
        } else {
            print(Constants.Notifications.NotReachable)
            self.popUpPrompt()
        }
    }
    
    deinit {
        stopNotifier()
    }
    */
    
    func popUpPrompt() {
        
        
        NoNetworkOverlay.show("Nooo connection :(")
        // implement like progress overlay
        /*
        let noConnectionView = UIView(frame: CGRect(0, 0, UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height))
        noConnectionView.backgroundColor = UIColor.white
        let noConnectionLabel = UILabel(frame: CGRect(0, 0, 200, 30))
        noConnectionLabel.text = "Nooo connection :("
        noConnectionLabel.textColor = UIColor.primaryTextColor()
        noConnectionLabel.font = UIFont.systemFont(ofSize: 17)
        noConnectionLabel.textAlignment = .center
        noConnectionLabel.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(noConnectionView)
        view.addSubview(noConnectionLabel)
        */
        
     //   let alertController = UIAlertController()
     //   alertController.networkAlert(Constants.NetworkConnection.NetworkPromptMessage)
    }
    
    
    private func setupSelectionListConstraints() {
        
        
        let widthConstraint = NSLayoutConstraint(item: self.selectionList, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.size.width)
        
        let heightConstraint = NSLayoutConstraint(item: self.selectionList, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: selectionListHeight)
        
        let centerXConstraint = NSLayoutConstraint(item: self.selectionList, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let centerYConstraint = NSLayoutConstraint(item: self.selectionList, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.view.addConstraints([centerXConstraint, centerYConstraint, widthConstraint, heightConstraint])
        
    }
    
    
    func configureNavBar() {
        
        /*
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        navLogo.contentMode = .scaleAspectFit
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        self.navigationItem.titleView = navLogo
 */
        
        let navLabel = UILabel()
        navLabel.contentMode = .scaleAspectFill
        navLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 70)
        navLabel.text = "Options"
        navLabel.textColor = UIColor.secondaryTextColor()
        self.navigationItem.titleView = navLabel

        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    
    
    func popUpLogoutPrompt() {
        
        let alertController = UIAlertController(title: Constants.Notifications.LogOutTitle, message: Constants.Notifications.LogOutMessage, preferredStyle: .alert)
        let logOut = UIAlertAction(title: Constants.Notifications.AlertLogout, style: .destructive) { action in
            self.loadingNotification = MBProgressHUD.showAdded(to: self.tableView.superview!, animated: true)
            self.loadingNotification.label.text = Constants.Notifications.LogOutNotificationText
            self.loadingNotification.center = CGPoint(self.width/2, self.height/2)
            
            if FIRAuth.auth()?.currentUser != nil {
                
                do {
                    
                    if let providerData = FIRAuth.auth()?.currentUser?.providerData {
                        for item in providerData {
                            if (item.providerID == "facebook.com") {
                                FBSDKLoginManager().logOut()
                                break
                            }
                        }
                    }
                    else {
                        print("no provider...")
                    }
                    
                    try FIRAuth.auth()?.signOut()
                    if let _ = UserDefaults.standard.object(forKey: "uid") {
                    UserDefaults.standard.removeObject(forKey: "uid")
                    }
                    
                  
                   
                    
                    self.loadingNotification.hide(animated: true)
                    let loginPage = UIStoryboard.instantiateViewController("Main", identifier: "LoginViewController") as! LoginViewController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = loginPage
                    
                } catch let error as NSError {
                    
                    print(error.localizedDescription)
                }
                
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        logOut.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        cancel.setValue(UIColor.primaryTextColor(), forKey: "titleTextColor")
        alertController.addAction(logOut)
        alertController.addAction(cancel)
        alertController.preferredAction = logOut
        
        alertController.show()
        
    }
    
    
    func popUpDeletePrompt() {
        
        let alertController = UIAlertController(title: Constants.Notifications.DeleteTitle, message: Constants.Notifications.DeleteMessage, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: Constants.Notifications.AlertDelete, style: .destructive) { action in
        
            self.loadingNotification = MBProgressHUD.showAdded(to: self.tableView.superview!, animated: true)
            self.loadingNotification.label.text = Constants.Notifications.LogOutNotificationText
            self.loadingNotification.center = CGPoint(self.width/2, self.height/2)
            
            
            let user = FIRAuth.auth()?.currentUser
            
            ////////////////////////////////////////////////////////////////////////////
            
            if let providerData = FIRAuth.auth()?.currentUser?.providerData {
                for item in providerData {
                    if (item.providerID == "facebook.com") {
                        
                        // if Facebook account
                        
                        if  UserDefaults.standard.object(forKey: "accessToken") != nil {
                            let token = UserDefaults.standard.object(forKey: "accessToken") as! String
                            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token)
                            user?.reauthenticate(with: credential, completion: { (error) in
                                
                                if error == nil {
                                    
                                    if let _ = UserDefaults.standard.object(forKey: "accessToken") {
                                        UserDefaults.standard.removeObject(forKey: "accessToken")
                                    }
                                    
                                    if let _ = UserDefaults.standard.object(forKey: "uid") {
                                        UserDefaults.standard.removeObject(forKey: "uid")
                                    }
                                    
                                    self.deleteUserInDatabase(user: user!)
                                  
                                }
                                else {
                                    print(error?.localizedDescription)
                                }
                                
                                
                            })
                        }
                        break
                    }
                    else {
                        self.loadingNotification.hide(animated: true)
                        self.promptForCredentials(user: user!)
                    }
                }
            }
            
        }
    
        delete.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        cancel.setValue(UIColor.primaryTextColor(), forKey: "titleTextColor")
        alertController.addAction(delete)
        alertController.addAction(cancel)
        alertController.preferredAction = delete
        alertController.show()
        
    }
    
    
    private func redirectToLoginPage() {
        
        DispatchQueue.main.async {
            self.loadingNotification.hide(animated: true)
        }
        
        if let _ = UserDefaults.standard.object(forKey: "uid") {
            UserDefaults.standard.removeObject(forKey: "uid")
        }
        
        DispatchQueue.main.async {
            let loginPage = UIStoryboard.instantiateViewController("Main", identifier: "FBLoginViewController") as! FBLoginViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginPage
        }
    }
    
    
    private func promptForCredentials(user: FIRUser) {
    
        let title = "Please enter your email and password in order to delete your account."
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter email"
            textField.keyboardType = .emailAddress
            textField.returnKeyType = .done
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter password"
            textField.isSecureTextEntry = true
            textField.returnKeyType = .done
        }
        
        let saveAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            alert -> Void in
            
            let email = alertController.textFields![0] as UITextField
            let password = alertController.textFields![1] as UITextField
            
            let credential = FIREmailPasswordAuthProvider.credential(withEmail: email.text!, password: password.text!)
            user.reauthenticate(with: credential) { (error) in
                
                if error != nil {
                    let alertController = UIAlertController()
                    alertController.defaultAlert(title: "Oops!", message: "Please enter correct email and password.")
                }
                else {
                    self.finaliseDeletion(user: user)
                }
                
                
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
            
        }

    
    private func finaliseDeletion(user: FIRUser) {
        
        self.loadingNotification = MBProgressHUD.showAdded(to: self.tableView.superview!, animated: true)
        self.loadingNotification.label.text = Constants.Notifications.LogOutNotificationText
        self.loadingNotification.center = CGPoint(self.width/2, self.height/2)
    
        if let _ = UserDefaults.standard.object(forKey: "uid") {
            UserDefaults.standard.removeObject(forKey: "uid")
        }
        
        self.deleteUserInDatabase(user: user)
    }
    
    
    private func deleteUserInDatabase(user: FIRUser) {
        let userRef = self.dataService.USER_REF.child(user.uid)
        userRef.removeValue()
        let geoRef = GeoFire(firebaseRef: dataService.GEO_USER_REF)
        geoRef?.removeKey(user.uid, withCompletionBlock: { (error) in
            
            if error == nil {
             print("Successfully deleted user location...")
                
                user.delete(completion: { (error) in
                    
                    if error == nil {
                        self.redirectToLoginPage()
                    }
                    else {
                        print(error?.localizedDescription)
                    }
                })
            }
            else {
            print("Could not find user location...")
            }
            
        })
    }
    
    // MARK: Utility functions
    
    // function - set refresh time value
    //    private func setValueRefreshTime(){
    //
    //        // read value from settings manager
    //        let refreshTimeValue = Int(SettingsManager.sharedInstance.refreshTime)
    //
    //        // set value for stepper
    //        self.refreshTime.value = Double(refreshTimeValue)
    //
    //        // set label
    //        self.refreshTimeLabel.text = "\(refreshTimeValue) Seconds"
    
    //    }
    
    /*
     // Push notifications in future
     // function - set notification value
     private func setValueNotifications() {
     
     // read value from settings manager
     let notificationValue = SettingsManager.sharedInstance.enableNotifications
     
     // show label based on value
     if notificationValue {
     //   self.likeAppLabel.text = "YES"
     self.enableNotifications.setOn(true, animated: true)
     }else {
     //    self.likeAppLabel.text = "NO"
     self.enableNotifications.setOn(false, animated: true)
     }
     }
     */
    // function - set default volume
    //    private func setValueDefaultVolume(){
    //
    //        // read value from settings manager
    //        let defaultVolumeValue = SettingsManager.sharedInstance.defaultVolume
    //
    //        self.defaultVolume.value = Float(defaultVolumeValue)
    //
    //        // set lablel
    //        self.defaultVolumeLabel.text = "\(Int(defaultVolumeValue*100))%"
    //
    //    }
    
    // function - set default walking distance value
    private func setValueDefaultWalkingDuration() {
        let walkingDuration = SettingsManager.sharedInstance.defaultWalkingDuration
        //      self.defaultWalkingDistance.selectedSegmentIndex = Int(walkingDistance)
        
        switch (walkingDuration)
        {
            
        case let walkingDuration where walkingDuration == 5:
            self.selectionList.selectedButtonIndex = 0
            break
        case let walkingDuration where walkingDuration == 10:
            self.selectionList.selectedButtonIndex = 1
            break
        case let walkingDuration where walkingDuration == 15:
            self.selectionList.selectedButtonIndex = 2
            break
        case let walkingDuration where walkingDuration == 30:
            self.selectionList.selectedButtonIndex = 3
            break
        case let walkingDuration where walkingDuration == 45:
            self.selectionList.selectedButtonIndex = 4
            break
        case let walkingDuration where walkingDuration == 60:
            self.selectionList.selectedButtonIndex = 5
            break
            
        default:
            
            break
            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section.
        
        // section - walking duration
        if section == 0 {
            return 1
        }
        
        // section - legal
        if section == 1 {
            return 4
        }
        
        // section - share
        if section == 2 {
            return 1
        }
        
        // section - logout
        if section == 3 {
            return 1
        }
        
        // section - app logo and current version
        if section == 4 {
            return 0
        }
        
        // section - delete account
        if section == 5 {
            return 1
        }
        
        
        return 0    // default value
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 4 {
            
            // Dequeue with the reuse identifier
            let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeader")
            let header = cell as! TableSectionHeader
            header.versionLabel.text = Constants.Config.AppVersion
            header.versionLabel.textColor = UIColor.secondaryTextColor()
            
            /*
             //     self.header.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height)
             //     let image = UIImage(named: Constants.Images.AppIcon)
             
             //    let screenWidth = self.view.frame.size.width
             //    let screenHeight = self.view.frame.size.height
             //    let size = screenWidth
             
             //    let logoView = UIImageView(frame: CGRectMake(172, 5, 30, 30))
             //    let logoView = UIImageView(frame: CGRectMake(0, 0, 0, 0))
             self.logoView.image = image
             self.header.addSubview(self.logoView)
             
             
             //   let versionLabel = UILabel()
             //  versionLabel.frame = CGRectMake(150, 38, tableView.frame.size.width, 20)
             self.versionLabel.text = Constants.Config.AppVersion
             self.versionLabel.textColor = UIColor.darkGrayColor()
             //    self.versionLabel.font = UIFont(name: Constants.Fonts.HelvRegular, size: 13.0)
             self.header.addSubview(versionLabel)
             
             self.logoView.translatesAutoresizingMaskIntoConstraints = false
             self.versionLabel.translatesAutoresizingMaskIntoConstraints = false
             
             let widthConstraint = NSLayoutConstraint(item: logoView, attribute: .Width, relatedBy: .Equal,
             toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
             
             let heightConstraint = NSLayoutConstraint(item: logoView, attribute: .Height, relatedBy: .Equal,
             toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
             
             let centerXConstraint = NSLayoutConstraint(item: logoView, attribute: .CenterX, relatedBy: .Equal, toItem: self.header, attribute: .CenterX, multiplier: 1, constant: 0)
             
             let centerYConstraint = NSLayoutConstraint(item: logoView, attribute: .CenterY, relatedBy: .Equal, toItem: self.header, attribute: .CenterY, multiplier: 1, constant: 0)
             
             self.header.addConstraints([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
             
             
             
             return header
             */
            return cell
        }
        return nil
        
        //  return tableView
    }
    
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        
        // section - share
        if indexPath.section == 2 {
            return nil
        }
        
        // section - logout
        if indexPath.section == 3 {
            return nil
        }
        
        
        // section - delete account
        if indexPath.section == 5 {
            return nil
        }
        
        
        return indexPath
    }
    
    //    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    //
    //        if section == 5 {
    //
    //            let header = view as! UITableViewHeaderFooterView
    //            let image = UIImage(named: "roundedIcon")
    //            let logoView = UIImageView(frame: CGRectMake(50, 50, 50, 50))
    //            logoView.image = image
    //            header.contentView.addSubview(logoView)
    //
    //
    //
    //        }
    //
    //    }
    // Note: We have set TableView content as 'static' so no other delegate method needed.
    
    
    //    func configureNavBar() {
    //
    //        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
    //        navLogo.contentMode = .ScaleAspectFit
    //        let image = UIImage(named: "navLogo")
    //        navLogo.image = image
    //        self.navigationItem.titleView = navLogo
    //        self.navigationItem.setHidesBackButton(true, animated: false)
    //
    //    }
    
    
    // MARK: - Actions
   
    
    @IBAction func logOutButtonTapped(_ sender: AnyObject) {
        self.popUpLogoutPrompt()
    }
    
    
    @IBAction func shareButtonTapped(_ sender: AnyObject) {
        displayShareSheet(shareContent: Constants.Notifications.ShareSheetMessage)
    }
    
    
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


extension SettingsViewController: HTHorizontalSelectionListDelegate {
    
    // MARK: - HTHorizontalSelectionListDelegate Protocol Methods
    
    func selectionList(_ selectionList: HTHorizontalSelectionList, didSelectButtonWith index: Int) {
        
        // update the distance for the corresponding index
        self.selectedDuration = Constants.Settings.Durations[index]
        
        if let duration = self.selectedDuration {
            SettingsManager.sharedInstance.defaultWalkingDuration = duration
             NotificationCenter.default.post(name: Notification.Name(rawValue: "distanceChanged"), object: nil)

        }
              //  StackObserver.sharedInstance.reloadValue = 2
    }
    
}


extension SettingsViewController: HTHorizontalSelectionListDataSource {
    
    func numberOfItems(in selectionList: HTHorizontalSelectionList) -> Int {
        return Constants.Settings.Durations.count
    }
    
    func selectionList(_ selectionList: HTHorizontalSelectionList, titleForItemWith index: Int) -> String? {
        return "\(Constants.Settings.Durations[index])"
    }
    
}
