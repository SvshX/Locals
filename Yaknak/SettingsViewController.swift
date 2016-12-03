//
//  SettingsViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 10/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import HTHorizontalSelectionList
import ReachabilitySwift
import MBProgressHUD
import FirebaseAuth
import Firebase



protocol SettingsControllerDelegate {
    func returnToLogin()
}

private let selectionListHeight: CGFloat = 50

class SettingsViewController: UITableViewController {
    
    var selectionList : HTHorizontalSelectionList!
    var selectedDuration = String()
    let header = UITableViewHeaderFooterView()
    let logoView = UIImageView()
    let versionLabel = UILabel()
    var reachability: Reachability?
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    
    //   @IBOutlet weak var selectionList: HTHorizontalSelectionList!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
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
        
        setupReachability(nil, useClosures: true)
        startNotifier()
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
            
            /*
             if (User.currentUser()!.isNew) {
             self.selectionList.setSelectedButtonIndex(1, animated: false)
             // SettingsManager.sharedInstance.defaultWalkingDuration = 15.0
             }
             */
            
        else {
            
            // set default walking distance value
            self.setValueDefaultWalkingDuration()
        }
        
        let nib = UINib(nibName: "TableSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reachability!.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
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
        
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        navLogo.contentMode = .scaleAspectFit
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        self.navigationItem.titleView = navLogo
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    
       
    
    func popUpLogoutPrompt() {
        
        let title = Constants.Notifications.LogOutTitle
        let message = Constants.Notifications.LogOutMessage
        let cancelButtonTitle = Constants.Notifications.AlertAbort
        let otherButtonTitle = Constants.Notifications.AlertLogout
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            //  NSLog(Constants.Logs.CancelAlert)
        }
        
        let okAction = UIAlertAction(title: otherButtonTitle, style: .default) { action in
            //   NSLog(Constants.Logs.SuccessAlert)
            
            let loadingNotification = MBProgressHUD.showAdded(to: self.tableView.superview!, animated: true)
            loadingNotification.label.text = Constants.Notifications.LogOutNotificationText
            loadingNotification.center = CGPoint(self.width/2, self.height/2)
            
            
            if FIRAuth.auth()?.currentUser != nil {
                
                do {
                    
                    try FIRAuth.auth()?.signOut()
                    loadingNotification.hide(animated: true)
                    let loginPage = UIStoryboard.instantiateViewController("Main", identifier: "LoginViewController") as! LoginViewController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = loginPage
                    
                } catch let error as NSError {
                    
                    print(error.localizedDescription)
                }
                
            }
            
            /*
             //   do {
             User.currentUser()?.saveInBackgroundWithBlock({ (success:Bool, error: NSError?) in
             if (success) {
             print("User saved before logging out.")
             User.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
             
             
             loadingNotification.hideAnimated(true)
             
             //        let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.ViewControllers.LoginView) as! LoginViewController
             
             let loginPage = MyLogInViewController()
             let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
             
             appDelegate.window?.rootViewController = loginPage
             
             }
             
             }
             })
             */
            //   }
            //   catch { print(Constants.Logs.SavingError) }
            
            ///////////////////////////////////////////
            
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        //     alertController.buttonBgColor[.Default] = UIColor(red: 227/255, green:19/255, blue:63/255, alpha:1)
        //     alertController.buttonBgColorHighlighted[.Default] = UIColor(red:230/255, green:133/255, blue:153/255, alpha:1)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    func popUpDeletePrompt() {
        
        let title = Constants.Notifications.DeleteTitle
        let message = Constants.Notifications.DeleteMessage
        let cancelButtonTitle = Constants.Notifications.AlertAbort
        let otherButtonTitle = Constants.Notifications.AlertDelete
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            //  NSLog(Constants.Logs.CancelAlert)
        }
        
        let okAction = UIAlertAction(title: otherButtonTitle, style: .default) { action in
            
            let loadingNotification = MBProgressHUD.showAdded(to: self.tableView.superview!, animated: true)
            loadingNotification.label.text = Constants.Notifications.LogOutNotificationText
            loadingNotification.center = CGPoint(self.width/2, self.height/2)
            
            
            let user = FIRAuth.auth()?.currentUser
            user?.delete(completion: { (error: Error?) in
                
                if let error = error {
                    if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                        
                        switch errCode {
                        case .errorCodeRequiresRecentLogin:
                            loadingNotification.hide(animated: true)
                           self.promptForCredentials(user: user!)
                            
                       
                        default:
                            print("Deleting account Error: \(error)")
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                    loadingNotification.hide(animated: true)
                    let loginPage = UIStoryboard.instantiateViewController("Main", identifier: "LoginViewController") as! LoginViewController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = loginPage
                    }
                }
                
            })
            
        }
           /*
            if User.currentUser() != nil {
                User.currentUser()?.deleteInBackgroundWithBlock({ (deleteSuccessful, error) -> Void in
                    
                    let deletePermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: nil, HTTPMethod: Constants.Requests.HTTPDeleteRequest)
                    deletePermission.startWithCompletionHandler({(connection,result,error)-> Void in
                        print("the delete permission is \(result)")
                        
                    })
                    
                    
                    User.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
                        
                        loadingNotification.hideAnimated(true)
                        
                        
                        //     let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.ViewControllers.LoginView) as! LoginViewController
                        let loginPage = MyLogInViewController()
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        
                        appDelegate.window?.rootViewController = loginPage
                        
                    }
                    
                })
            }
            */
            
        
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        //     alertController.buttonBgColor[.Default] = UIColor(red: 227/255, green:19/255, blue:63/255, alpha:1)
        //     alertController.buttonBgColorHighlighted[.Default] = UIColor(red:230/255, green:133/255, blue:153/255, alpha:1)
        
        present(alertController, animated: true, completion: nil)
        
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
                    let alertController = UIAlertController(title: "Oops!", message: "Please enter correct email and password.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                else {
                self.finaliseDeletion()
                }
                
                
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
            
        }

    
    private func finaliseDeletion() {
    
        let user = FIRAuth.auth()?.currentUser
        user?.delete(completion: { (error: Error?) in
            
            if let error = error {
                if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                    
                    switch errCode {
                    case .errorCodeRequiresRecentLogin:
                    self.promptForCredentials(user: user!)
                        
                        
                    default:
                        print("Deleting account Error: \(error)")
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    
                let loginPage = UIStoryboard.instantiateViewController("Main", identifier: "LoginViewController") as! LoginViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = loginPage
                }
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
            
        case let walkingDuration where walkingDuration == 5.0:
            self.selectionList.selectedButtonIndex = 0
            break
        case let walkingDuration where walkingDuration == 10.0:
            self.selectionList.selectedButtonIndex = 1
            break
        case let walkingDuration where walkingDuration == 15.0:
            self.selectionList.selectedButtonIndex = 2
            break
        case let walkingDuration where walkingDuration == 30.0:
            self.selectionList.selectedButtonIndex = 3
            break
        case let walkingDuration where walkingDuration == 45.0:
            self.selectionList.selectedButtonIndex = 4
            break
        case let walkingDuration where walkingDuration == 60.0:
            self.selectionList.selectedButtonIndex = 5
            break
            
        default:
            
            break
            
        }
        
        print(self.selectionList.selectedButtonIndex)
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
            return 3
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
        
        SettingsManager.sharedInstance.defaultWalkingDuration = Double(self.selectedDuration)!
        StackObserver.sharedInstance.reloadValue = 2
    }
    
}


extension SettingsViewController: HTHorizontalSelectionListDataSource {
    
    func numberOfItems(in selectionList: HTHorizontalSelectionList) -> Int {
        return Constants.Settings.Durations.count
    }
    
    func selectionList(_ selectionList: HTHorizontalSelectionList, titleForItemWith index: Int) -> String? {
        return Constants.Settings.Durations[index]
    }
    
}
