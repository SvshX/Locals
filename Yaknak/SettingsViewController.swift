//
//  SettingsViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 10/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import HTHorizontalSelectionList
import MBProgressHUD
import FBSDKLoginKit
import Firebase
import GeoFire


protocol RadiusDelegate: class {
    func radiusChanged()
}

private let selectionListHeight: CGFloat = 50

class SettingsViewController: UITableViewController {
    
    var selectionList: HTHorizontalSelectionList!
    var selectedDuration: Int?
    var showTips: Bool?
    let header = UITableViewHeaderFooterView()
    let logoView = UIImageView()
    let versionLabel = UILabel()
    let dataService = DataService()
    var loadingNotification = MBProgressHUD()
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    weak var radiusDelegate: RadiusDelegate?
  
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var tipSwitcher: UISwitch!
    
    
    override func viewDidLoad() {
      
      configureNavBar()
      initDistanceSetting()
      initPrivacySetting()
      
      let nib = UINib(nibName: "TableSectionHeader", bundle: nil)
      tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
    }
    
  private func initDistanceSetting() {
    
    self.selectionList = HTHorizontalSelectionList(frame: CGRect(0, 50, self.view.frame.size.width, 30))
    self.selectionList.delegate = self
    self.selectionList.dataSource = self
    self.selectionList.selectionIndicatorStyle = .bottomBar
    self.selectionList.selectionIndicatorColor = UIColor.primary()
    self.selectionList.bottomTrimHidden = true
    self.selectionList.centerButtons = true
    self.selectionList.buttonInsets = UIEdgeInsetsMake(3, 10, 3, 10);
    self.view.addSubview(self.selectionList)
   
    if UserDefaults.standard.object(forKey: "defaultWalkingDuration") == nil {
      self.selectionList.setSelectedButtonIndex(2, animated: false)
    }
    else {
      // set default walking distance value
      self.setDefaultWalkingDuration()
    }

  }
  
  
  
  private func initPrivacySetting() {
  
    let isShown = SettingsManager.shared.defaultShowTips
    self.tipSwitcher.setOn(!isShown, animated: false)
  }
  
  
    @IBAction func showTipsChanged(_ sender: UISwitch) {
      
        if sender.isOn {
        SettingsManager.shared.defaultShowTips = false
        }
        else {
        SettingsManager.shared.defaultShowTips = true
        }
    }
    
    
    private func isFacebookUser() -> Bool {
      guard let currentUser = Auth.auth().currentUser else {return false}
            for item in currentUser.providerData {
                if (item.providerID == "facebook.com") {
                    return true
                }
            }
        return false
    }
   
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
      guard let tabC = tabBarController as? TabBarController else {return}
        tabC.selectedIndex = 2
    }
   
    
    @IBAction func deleteAccountTapped(_ sender: AnyObject) {
        self.popUpDeletePrompt()
    }
    
  
    func popUpPrompt() {
        NoNetworkOverlay.show("Nooo connection :(")
    }
    
  
    
    func configureNavBar() {
        
        let navLabel = UILabel()
        navLabel.contentMode = .scaleAspectFill
        navLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 70)
        navLabel.text = "Options"
        navLabel.textColor = UIColor.secondaryText()
        navigationItem.titleView = navLabel
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    
    
    func popUpLogoutPrompt() {
        
        let alertController = UIAlertController(title: Constants.Notifications.LogOutTitle, message: Constants.Notifications.LogOutMessage, preferredStyle: .alert)
        let logOut = UIAlertAction(title: Constants.Notifications.AlertLogout, style: .destructive) { action in
            self.logUserOut()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        logOut.setValue(UIColor.primary(), forKey: "titleTextColor")
        cancel.setValue(UIColor.primaryText(), forKey: "titleTextColor")
        alertController.addAction(logOut)
        alertController.addAction(cancel)
        alertController.preferredAction = logOut
        alertController.show()
        
    }
    
    
    func popUpDeletePrompt() {
        
        let alertController = UIAlertController(title: Constants.Notifications.DeleteTitle, message: Constants.Notifications.DeleteMessage, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: Constants.Notifications.AlertDelete, style: .destructive) { action in
        
          guard let sView = self.tableView.superview, let user = Auth.auth().currentUser else {return}
            self.loadingNotification = MBProgressHUD.showAdded(to: sView, animated: true)
            self.loadingNotification.label.text = Constants.Notifications.LogOutNotificationText
            self.loadingNotification.center = CGPoint(self.width/2, self.height/2)
            
            for item in user.providerData {
                    if (item.providerID == "facebook.com") {
                        
                        // if Facebook account
                        
                        if  UserDefaults.standard.object(forKey: "accessToken") != nil {
                            let token = UserDefaults.standard.object(forKey: "accessToken") as! String
                            let credential = FacebookAuthProvider.credential(withAccessToken: token)
                            user.reauthenticate(with: credential, completion: { (error) in
                                
                                if let error = error {
                                   print(error.localizedDescription)
                                }
                                else {
                                    if let _ = UserDefaults.standard.object(forKey: "accessToken") {
                                        UserDefaults.standard.removeObject(forKey: "accessToken")
                                    }
                                    
                                    self.dataService.getCurrentUser({ (myUser) in
                                        
                                        guard let facebookID = myUser.facebookId else {return}
                                        let fbRef = self.dataService.FB_USER_REF.child(facebookID)
                                        fbRef.removeValue(completionBlock: { (error, ref) in
                                            print("Facebook user removed...")
                                        })
                                        
                                    })
                                    self.deleteUserInDatabase(user)
                                }
                            })
                        }
                        break
                    }
                    else {
                        self.loadingNotification.hide(animated: true)
                      self.promptForCredentials(for: user)
                    }
                }
      }
    
        delete.setValue(UIColor.primary(), forKey: "titleTextColor")
        let cancel = UIAlertAction(title: Constants.Notifications.GenericCancelTitle, style: .cancel)
        cancel.setValue(UIColor.primaryText(), forKey: "titleTextColor")
        alertController.addAction(delete)
        alertController.addAction(cancel)
        alertController.preferredAction = delete
        alertController.show()
        
    }
    
    
    private func logUserOut() {
        
      guard let sView = self.tableView.superview, let user = Auth.auth().currentUser else {return}
        self.loadingNotification = MBProgressHUD.showAdded(to: sView, animated: true)
        self.loadingNotification.label.text = Constants.Notifications.LogOutNotificationText
        self.loadingNotification.center = CGPoint(self.width/2, self.height/2)
  
            do {
                    for item in user.providerData {
                        if item.providerID == "facebook.com" {
                            FBSDKLoginManager().logOut()
                            break
                        }
                    }
                
                try Auth.auth().signOut()
                if let _ = UserDefaults.standard.object(forKey: "uid") {
                    UserDefaults.standard.removeObject(forKey: "uid")
                }
              
                self.loadingNotification.hide(animated: true)
                let loginPage = UIStoryboard.instantiateViewController("Main", identifier: "LoginViewController") as! LoginViewController
              guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                appDelegate.window?.rootViewController = loginPage
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
    }
    
    
    private func redirectToLoginPage() {
        
        DispatchQueue.main.async {
            self.loadingNotification.hide(animated: true)
            let loginPage = UIStoryboard.instantiateViewController("Main", identifier: "FBLoginViewController") as! FBLoginViewController
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            appDelegate.window?.rootViewController = loginPage
        }
    }
    
    
    private func promptForCredentials(for user: User) {
    
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
            
            
            let credential = EmailAuthProvider.credential(withEmail: email.text!, password: password.text!)
            user.reauthenticate(with: credential) { (error) in
                
                if error != nil {
                    let alertController = UIAlertController()
                    alertController.defaultAlert(Constants.Notifications.GenericFailureTitle, "Please enter correct email and password.")
                }
                else {
                    self.finaliseDeletion(user: user)
                }
                
                
            }
        })
        
        let cancelAction = UIAlertAction(title: Constants.Notifications.GenericCancelTitle, style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
            
        }

    
    private func finaliseDeletion(user: User) {
        
      guard let sView = self.tableView.superview else {return}
        self.loadingNotification = MBProgressHUD.showAdded(to: sView, animated: true)
        self.loadingNotification.label.text = Constants.Notifications.LogOutNotificationText
        self.loadingNotification.center = CGPoint(self.width/2, self.height/2)
    
        if let _ = UserDefaults.standard.object(forKey: "uid") {
            UserDefaults.standard.removeObject(forKey: "uid")
        }
        self.deleteUserInDatabase(user)
    }
    
    
    private func deleteUserInDatabase(_ user: User) {
        let userRef = self.dataService.USER_REF.child(user.uid)
        userRef.removeValue { (error, ref) in
            
            if let error = error {
            print(error.localizedDescription)
            }
            else {
                user.delete(completion: { (error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    else {
                        self.redirectToLoginPage()
                    }
                    
                })
            }
            
            
        }
        
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
    private func setDefaultWalkingDuration() {
      
    let walkingDuration = SettingsManager.shared.defaultWalkingDuration
      
      switch (walkingDuration) {
            
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
       return 7
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
        return "Minutes Walk"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section.
        
            switch section {
            case 0:
                return 1
            case 1:
                if !isFacebookUser() {
                return 0
                }
                else {
                return 1
                }
            case 2:
                return 4
            case 3:
                return 1
            case 4:
                return 1
            case 5:
                return 0
            case 6:
                return 1
            default:
                return 0
            }
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 5 {
            
            // Dequeue with the reuse identifier
            let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeader") as! TableSectionHeader
            cell.versionLabel.text = Constants.Config.AppVersion
            cell.versionLabel.textColor = UIColor.secondaryText()
            cell.versionLabel.textAlignment = .center
            
            return cell
        }
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 && !isFacebookUser() {
        return 0
        }
        else if section == 5 {
        return 10
        }
        else {
        return 40
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        
        // section - share
        if indexPath.section == 3 {
            return nil
        }
        
        // section - logout
        if indexPath.section == 4 {
            return nil
        }
        
        
        // section - delete account
        if indexPath.section == 6 {
            return nil
        }
        
        
        return indexPath
    }
    
    
    
    // MARK: - Actions
   
    
    @IBAction func logOutButtonTapped(_ sender: AnyObject) {
        self.popUpLogoutPrompt()
    }
    
    
    @IBAction func shareButtonTapped(_ sender: AnyObject) {
        displayShareSheet()
    }
    
    
    func displayShareSheet() {
        let activityViewController = UIActivityViewController(activityItems: [Constants.Notifications.ShareSheetMessage as NSString], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [ .addToReadingList, .copyToPasteboard,UIActivityType.saveToCameraRoll, .print, .assignToContact, .mail, .openInIBooks, .postToTencentWeibo, .postToVimeo, .postToWeibo]
        present(activityViewController, animated: true, completion: nil)
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
        
      guard let duration = self.selectedDuration else {return}
            SettingsManager.shared.defaultWalkingDuration = duration
            self.radiusDelegate?.radiusChanged()
        
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
