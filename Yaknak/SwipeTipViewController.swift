
//
//  SwipeTipViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Koloda
import pop
import CoreLocation
//import PXGoogleDirections
//import GoogleMaps
import NVActivityIndicatorView
import ReachabilitySwift
import MBProgressHUD
import FBSDKShareKit


// private let numberOfCards: UInt = 5
private let frameAnimationSpringBounciness:CGFloat = 9
private let frameAnimationSpringSpeed:CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent:CGFloat = 0.1


class SwipeTipViewController: UIViewController {
    
    
    @IBOutlet weak var nearbyText: UIView!
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var addATipButton: UIButton!
    private var tips = [Tip]()
    var request: PXGoogleDirections!
    var result: [PXGoogleDirectionsRoute]!
    var routeIndex: Int = 0
    let locationManager = CLLocationManager()
    var selectedHomeImage: String!
    var style = NSMutableParagraphStyle()
    var miles = Double()
    var category = String()
    var loader: NVActivityIndicatorView! = nil
    var reachability: Reachability?
    var swipeFlag = false
    var currentTipIndex = Int()
    var currentTip = Tip()
    
    let tapRec = UITapGestureRecognizer()
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavBar()
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        directionsAPI.delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.style.lineSpacing = 2
        
        setupReachability(nil, useClosures: true)
        startNotifier()
        
        //    tapRec.addTarget(self, action: #selector(SwipeTipViewController.addATipTapped))
        //    self.addATipButton.addGestureRecognizer(tapRec)
        //    self.addATipButton.userInteractionEnabled = true
        
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let size = screenWidth
        let frame = CGRect(x: (screenWidth / 2) - (size / 2), y: (screenWidth / 2) - (size / 2), width: screenWidth / 4, height: screenWidth / 4)
        //       let size = CGSize(width: 400, height: 400)
        loader = NVActivityIndicatorView(frame: frame, type: .BallSpinFadeLoader, color: UIColor(red: 227/255, green: 19/255, blue: 63/255, alpha: 1), padding: 10)
        loader.center = CGPoint(screenWidth / 2 , screenHeight / 2)
        loader.alpha = 0.1
        loader.tag = 200
        self.view.addSubview(loader)
        NSLayoutConstraint(item: loader, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loader, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        
        
        if (StackObserver.sharedInstance.triggerReloadData == false && StackObserver.sharedInstance.triggerReloadStack == false && StackObserver.sharedInstance.triggerReload == false) {
            self.nearbyText.isHidden = true
            StackObserver.sharedInstance.passedValue = 10
            self.bringTipStackToFront()
            self.swipeFlag = true
            StackObserver.sharedInstance.triggerReloadStack = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if (swipeFlag == false) {
            
            if (StackObserver.sharedInstance.triggerReloadData == true) {
                self.kolodaView.reloadData()
                StackObserver.sharedInstance.likeCountValue = 1
                StackObserver.sharedInstance.triggerReloadData = false
            }
            
            
            
            if (StackObserver.sharedInstance.triggerReloadStack == true) {
                self.kolodaView.removeStack()
                self.tips.removeAll()
                self.bringTipStackToFront()
                StackObserver.sharedInstance.triggerReloadStack = false
                self.nearbyText.isHidden = true
                for subView in self.view.subviews {
                    if (subView.tag == 100) {
                        subView.removeFromSuperview()
                    }
                }
                
            }
            
            if (StackObserver.sharedInstance.triggerReload == true) {
                self.kolodaView.removeStack()
                self.tips.removeAll()
                self.bringTipStackToFront()
                StackObserver.sharedInstance.reloadValue = 1
                StackObserver.sharedInstance.triggerReload = false
                self.nearbyText.isHidden = true
                for subView in self.view.subviews {
                    if (subView.tag == 100) {
                        subView.removeFromSuperview()
                    }
                }
                
            }
            
            //  self.displayCirclePulse()
            
        }
            
        else {
            //  NSLog(Constants.Logs.SwipeFlag)
        }
        
        self.swipeFlag = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reachability!.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
    
  
    
    
    private func bringTipStackToFront() {
        
        switch (StackObserver.sharedInstance.passedValue) {
            
        case 10:
            fetchAllTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration)
            break
        case 0:
            self.category = Constants.HomeView.Categories[0]
            fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category)
            break
        case 1:
            self.category = Constants.HomeView.Categories[1]
            fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category)
            break
        case 2:
            self.category = Constants.HomeView.Categories[2]
            fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category)
            break
        case 3:
            self.category = Constants.HomeView.Categories[3]
            fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category)
            break
        case 4:
            self.category = Constants.HomeView.Categories[4]
            fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category)
            break
        case 5:
            self.category = Constants.HomeView.Categories[5]
            fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category)
            break
        case 6:
            self.category = Constants.HomeView.Categories[6]
            fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category)
            break
        case 7:
            self.category = Constants.HomeView.Categories[7]
            fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category)
            break
        case 8:
            self.category = Constants.HomeView.Categories[8]
            fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category)
            break
        case 9:
            self.category = Constants.HomeView.Categories[9]
            fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category)
            break
            
        default:
            break
            
        }
        
    }
    
    
    private var directionsAPI: PXGoogleDirections {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).directionsAPI
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
    
    
    @IBAction func returnTap(sender: AnyObject) {
        self.kolodaView.revertAction()
    }
    
    @IBAction func reportTap(sender: AnyObject) {
        self.popUpReportPrompt()
        self.currentTipIndex = self.kolodaView.returnCurrentTipIndex()
        self.currentTip = tips[self.currentTipIndex]
    }
    
    
    private func popUpReportPrompt() {
        
        //    let title = Constants.Notifications.ReportTitle
        let message = Constants.Notifications.ShareMessage
        let cancelButtonTitle = Constants.Notifications.AlertAbort
        let okButtonTitle = Constants.Notifications.ReportOK
        let shareTitle = Constants.Notifications.ShareOk
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        
        let shareButton = UIAlertAction(title: shareTitle, style: .Default) { (Action) in
            self.showSharePopUp(self.currentTip)
        }
        
        let reportButton = UIAlertAction(title: okButtonTitle, style: .Default) { (Action) in
            self.showReportVC(tip: self.currentTip)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (Action) in
            //  alertController.d
        }
        
        alertController.addAction(shareButton)
        alertController.addAction(reportButton)
        alertController.addAction(cancelButton)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
   
    
    
    private func showReportVC(tip: Tip) {
        
        let storyboard = UIStoryboard(name: "Report", bundle: Bundle.main)
        
        let previewVC = storyboard.instantiateViewController(withIdentifier: "NavReportVC") as! UINavigationController
        previewVC.definesPresentationContext = true
        previewVC.modalPresentationStyle = .overCurrentContext
        
        let reportVC = previewVC.viewControllers.first as! ReportViewController
        reportVC.data = tip
        self.show(previewVC, sender: nil)
        
        //    self.showViewController(previewVC, sender: nil)
        
    }
    
    
    private func showSharePopUp(tip: Tip) {
        
        var tipLocation = String()
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: tip.location.latitude, longitude: tip.location.longitude)
        geoCoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: NSError?) in
            
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary)
            
            
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                tipLocation = street as String
                
                // City
                if let city = placeMark.addressDictionary!["City"] as? NSString {
                    tipLocation += ", " + (city as String)
                    
                    
                    // Zip code
                    if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                        tipLocation += " " + (zip as String)
                        
                    }
                }
            }
            
            
            var photo: FBSDKSharePhoto = FBSDKSharePhoto()
            
            let url = NSURL(string: tip.image!.url!)
            
            photo = FBSDKSharePhoto(imageURL: url, userGenerated: true)
            
            let properties: [NSObject : AnyObject] = ["og:type": "yaknaklabs:tip", "og:title":  tipLocation, "og:description": tip.desc, "og:image": photo]
            
            
            
            let object: FBSDKShareOpenGraphObject = FBSDKShareOpenGraphObject(properties: properties)
            
            // Create an action
            let action: FBSDKShareOpenGraphAction = FBSDKShareOpenGraphAction()
            action.actionType = "yaknaklabs:share"
            action.setObject(object, forKey:"tip")
            //    action.setArray([photo], forKey: "image")
            
            
            //Create the content and add the action to it
            let content: FBSDKShareOpenGraphContent = FBSDKShareOpenGraphContent()
            content.action = action
            content.previewPropertyName = "tip"
            
            dispatch_async(dispatch_get_main_queue()) {
                FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
            }
            
        }
        
        
    }
    
    
    
    
    private func convertLocation(location: PFGeoPoint) -> String {
        
        var result = String()
        let location: CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary)
            
            
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                print(street)
                
                
                // City
                if let city = placeMark.addressDictionary!["City"] as? NSString {
                    print(city)
                    
                    
                    // Zip code
                    if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                        print(zip)
                        
                        result = (street as String) + " " + (city as String) + " " + (zip as String)
                    }
                }
            }
        }
        return result
    }
    
    
    // MARK: Database methods
    
    func fetchAllTips(walkingDuration: Double) {
        
        switch (walkingDuration) {
            
        case let walkingDuration where walkingDuration == 5.0:
            self.miles = 0.25
            break;
            
        case let walkingDuration where walkingDuration == 10.0:
            self.miles = 0.5
            break;
            
        case let walkingDuration where walkingDuration == 15.0:
            self.miles = 0.75
            break;
            
        case let walkingDuration where walkingDuration == 30.0:
            self.miles = 1.5
            break;
            
        case let walkingDuration where walkingDuration == 45.0:
            self.miles = 2.25
            break;
            
        case let walkingDuration where walkingDuration == 60.0:
            self.miles = 3
            break;
            
        default:
            break;
            
        }
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                
                self.loader.startAnimating()
                let query = Tip.query()
                query!.whereKey("location", nearGeoPoint: geoPoint!, withinMiles: self.miles)
                query!.orderByDescending("likes")
                query!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
                    if error == nil {
                        print("Successfully retrieved \(objects!.count) tips.")
                        print("The tip distance is: \(self.miles) miles")
                        self.loader.stopAnimating()
                        if objects!.count == 0 {
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.nearbyText.hidden = false
                                self.displayCirclePulse()
                            }
                            print(Constants.Logs.OutOfRange)
                        }
                        
                        if let objects = objects {
                            
                            for object in objects {
                                
                                let tip = object as! Tip
                                self.tips.append(tip)
                            }
                            
                            self.kolodaView.reloadData()
                            
                        }
                    } else if let error = error {
                        
                        self.showErrorView(error)
                    }
                    //   self.kolodaView.reloadData()
                }
                
            }
        }
        
        
        
        
    }
    
    
    
    func fetchTips(walkingDuration: Double, category: String) {
        
        switch (walkingDuration) {
            
        case let walkingDuration where walkingDuration == 5.0:
            self.miles = 0.25
            break;
            
        case let walkingDuration where walkingDuration == 10.0:
            self.miles = 0.5
            break;
            
        case let walkingDuration where walkingDuration == 15.0:
            self.miles = 0.75
            break;
            
        case let walkingDuration where walkingDuration == 30.0:
            self.miles = 1.5
            break;
            
        case let walkingDuration where walkingDuration == 45.0:
            self.miles = 2.25
            break;
            
        case let walkingDuration where walkingDuration == 60.0:
            self.miles = 3
            break;
            
        default:
            break;
            
        }
        
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.loader.startAnimating()
                let query = Tip.query()
                query!.whereKey("category", equalTo: category)
                query!.whereKey("location", nearGeoPoint: geoPoint!, withinMiles: self.miles)
                query!.orderByDescending("likes")
                query!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
                    if error == nil {
                        print("Successfully retrieved \(objects!.count) tips.")
                        self.loader.stopAnimating()
                        if objects!.count == 0 {
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                self.nearbyText.hidden = false
                                self.displayCirclePulse()
                            }
                            print(Constants.Logs.OutOfRange)
                        }
                            
                        else if let objects = objects {
                            
                            for object in objects {
                                //   self.displayCirclePulse()
                                let tip = object as! Tip
                                //       let tip = pfObjectToTip(object)
                                self.tips.append(tip)
                            }
                            self.kolodaView.reloadData()
                        }
                    } else if let error = error {
                        
                        self.showErrorView(error)
                    }
                    //       self.kolodaView.reloadData()
                }
                
            }
        }
        
    }
    
    
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func tipViewHeightConstraintConstant() -> CGFloat {
        switch(self.screenHeight()) {
        case 568:
            return 95
            
        case 667:
            return 75
            
        case 736:
            return 55
            
        default:
            return 100
        }
    }
    
    
    //    //MARK: IBActions
    
    
    @IBAction func addATipButtonTapped(sender: AnyObject) {
        tabBarController!.selectedIndex = 4
    }
    
    
    private func displayCirclePulse() {
        
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let size = screenWidth
        let frame = CGRect(x: (screenWidth / 2) - (size / 2), y: (screenHeight / 2) - (size / 2), width: size, height: size)
        //       let size = CGSize(width: 400, height: 400)
        let circlePulse = NVActivityIndicatorView(frame: frame, type: .BallScaleMultiple, color: UIColor(red: 227/255, green: 19/255, blue: 63/255, alpha: 1), padding: 10)
        circlePulse.alpha = 0.1
        circlePulse.tag = 100
        circlePulse.userInteractionEnabled = false
        //  self.view.addSubview(circlePulse)
        self.view.addSubview(circlePulse)
        circlePulse.startAnimating()
        NSLayoutConstraint(item: circlePulse, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: circlePulse, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0).active = true
        
    }
    
    
    private func handleLikeCount(currentTip: Tip) {
        
        let userQuery = User.query()
        userQuery!.whereKey("tipsLiked", notEqualTo: currentTip.objectId!)
        userQuery!.whereKey("objectId", equalTo: (User.currentUser()?.objectId)!)
        userQuery!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            
            if (error == nil) {
                
                if (objects?.count != 0) {
                    
                    if let objects = objects {
                        for object in objects {
                            
                            self.incrementAndSaveTip(currentTip)
                            
                            object.addObject(currentTip.objectId!, forKey: "tipsLiked")
                            object.saveInBackground()
                        }
                    }
                }
                    
                else if (objects?.count == 0) {
                    
                    print(Constants.Logs.TipAlreadyLiked)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let storyboard = UIStoryboard(name: Constants.NibNames.MainStoryboard, bundle: nil)
                        let mapVC = storyboard.instantiateViewControllerWithIdentifier(Constants.ViewControllers.MapView) as! MapViewController
                        
                        mapVC.data = currentTip
                        self.presentViewController(mapVC, animated: true, completion: nil)
                        self.kolodaView.revertAction()
                        
                    }
                    
                }
                
            }
            else {
                print(Constants.Logs.RequestDidFail)
            }
            
        }
        
        
    }
    
    
    private func incrementAndSaveTip(currentTip: Tip) {
        
        // get the tip to increment like count
        currentTip.incrementKey("likes")
        currentTip.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            
            if (success) {
                
                let query = User.query()
                query?.getObjectInBackgroundWithId(currentTip.userId, block: { (object: PFObject?, error: NSError?) in
                    
                    // TODO send push notification to user - in future
                    
                    //    self.sendPush(currentTip)
                    
                    
                })
                
                //    self.incrementCategoryTip(currentTip)
                self.finaliseSuccess(currentTip)
            }
                
            else {
                print(Constants.Logs.SavingError)
            }
            
        }
        
        
    }
    
    /*
     private func sendPush(currentTip: Tip) {
     
     OneSignal.getTags({ tags in
     
     if let tags = tags {
     for tag in tags {
     
     if (tag.1 as! String == currentTip.userId) {
     OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": [tag.0]]);
     }
     else {
     print("User disabled push notifications.")
     }
     }
     }
     
     }) { (error) in
     print("no tag found")
     }
     
     }
     
     */
    
    private func incrementCategoryTip(currentTip: Tip) {
    
        let query = PFQuery(className: "Category")
        let pointer = PFObject(withoutDataWithClassName: "Tip", objectId: currentTip.objectId)
        query.whereKey("tip", equalTo: pointer)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if (error == nil) {
                
                if let objects = objects {
                    
                    for object in objects {
                        object.incrementKey("like")
                        object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            if (success) {
                                print("success")
                            }
                            else {
                                print("error")
                            }
                        })
                        
                    }
                }
                
                
            }
                
            else {
                print("error")
            }
        }
        
    }
    
    private func finaliseSuccess(currentTip: Tip) {
        
        let tipUserQuery = User.query()
        tipUserQuery!.getObjectInBackgroundWithId(currentTip.userId, block: { (object: PFObject?, error: NSError?) in
            
            if error == nil {
                
                if let object = object {
                    
                    object.incrementKey("totalLikes")
                    object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                        
                        if (success) {
                            
                            print(Constants.Logs.TipIncrementSuccess)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                let storyboard = UIStoryboard(name: Constants.NibNames.MainStoryboard, bundle: nil)
                                let mapVC = storyboard.instantiateViewControllerWithIdentifier(Constants.ViewControllers.MapView) as! MapViewController
                                mapVC.data = currentTip
                                self.presentViewController(mapVC, animated: true, completion: nil)
                                self.kolodaView.revertAction()
                                self.kolodaView.reloadData()
                                
                            }
                            
                        }
                            
                        else {
                            print(Constants.Logs.SavingError)
                        }
                        
                    })
                    
                }
            }
                
            else {
                print(Constants.Logs.SavingError)
            }
            
        })
        
    }
    
}


//MARK: KolodaViewDelegate

extension SwipeTipViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        //  kolodaView?.revertAction()
        //   UIApplication.sharedApplication().openURL(NSURL(string: "http://localstheapp.com/")!)
    }
    
    func koloda(kolodaShouldApplyAppearAnimation koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaShouldMoveBackgroundCard koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(kolodaShouldTransparentizeNextCard koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        
        if (direction == .Right) {
            
            //   increment like
            let currentTip = tips[Int(index)]
            self.handleLikeCount(currentTip)
            
        }
        
        if (direction == .Left) {
            print(Constants.Logs.SwipedLeft)
        }
        
    }
    
}




extension SwipeTipViewController: PXGoogleDirectionsDelegate {
    
    func googleDirectionsWillSendRequestToAPI(googleDirections: PXGoogleDirections, withURL requestURL: NSURL) -> Bool {
        //   NSLog(Constants.Logs.WillSendRequestToAPI)
        return true
    }
    
    func googleDirectionsDidSendRequestToAPI(googleDirections: PXGoogleDirections, withURL requestURL: NSURL) {
        //   NSLog(Constants.Logs.DidSendRequestToAPI)
        //   NSLog("\(requestURL.absoluteString!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)")
    }
    
    func googleDirections(googleDirections: PXGoogleDirections, didReceiveRawDataFromAPI data: NSData) {
        //   NSLog(Constants.Logs.DidReceiveRawDataFromAPI)
        //   NSLog(NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
    }
    
    func googleDirectionsRequestDidFail(googleDirections: PXGoogleDirections, withError error: NSError) {
        //    NSLog(Constants.Logs.RequestDidFail)
        //    NSLog("\(error)")
    }
    
    func googleDirections(googleDirections: PXGoogleDirections, didReceiveResponseFromAPI apiResponse: [PXGoogleDirectionsRoute]) {
        //    NSLog(Constants.Logs.ReceiveResponseFromAPI)
        //    NSLog("Got \(apiResponse.count) routes")
        //    for i in 0 ..< apiResponse.count {
        //        NSLog("Route \(i) has \(apiResponse[i].legs.count) legs")
        
        //    }
        
        
    }
    
}


extension SwipeTipViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let newLocation = locations.last {
            
            Location.sharedInstance.currLat = newLocation.coordinate.latitude
            Location.sharedInstance.currLong = newLocation.coordinate.longitude
            
        }
        
    }
    
}


extension SwipeTipViewController: KolodaViewDataSource {
    
    
    func kolodaNumberOfCards(koloda:KolodaView) -> UInt {
        return UInt (self.tips.count)
        
    }
    
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        
        let tipView = Bundle.mainBundle().loadNibNamed(Constants.NibNames.TipView, owner: self, options: nil)![0] as? CustomTipView
        
        let tip = tips[Int(index)]
        let attributes = [NSParagraphStyleAttributeName : style]
        
        
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor.clear.withAlphaComponent(0.5), UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black
            .withAlphaComponent(0.9).cgColor, UIColor.black.cgColor]
        gradient.locations = [0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8]
        tipView!.tipImage.layer.insertSublayer(gradient, atIndex: 0)
        tipView!.tipImage.file = tip.image
        tipView!.tipImage.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
            if (error != nil) {
                print("Error: \(error!) \(error!.userInfo)")
            } else {
                // image loaded
            }
        }
        
        
        //        tip.getImage({ image in
        //            tipView!.tipImage.image = image
        //        })
        
        tipView!.layoutIfNeeded()
        
        tipView!.userImage.layer.cornerRadius = tipView!.userImage.frame.size.width / 2
        tipView!.userImage.clipsToBounds = true
        tipView!.userImage.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).CGColor
        tipView!.userImage.layer.borderWidth = 0.8
        tipView!.userImage.file = tip.userProfilePicture
        //      tipView!.userImage.file = tip.user.profilePicture
        tipView!.userImage.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
            if (error != nil) {
                print("Error: \(error!) \(error!.userInfo)")
            } else {
                // user profile picture loaded
            }
        }
        
        
        //    tipView?.previousButton.layer.borderColor = UIColor.whiteColor().CGColor
        //    tipView?.previousButton.layer.borderWidth = 1
        //    tipView?.previousButton.layer.cornerRadius = 5
        //    tipView?.previousButton.titleEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
        tipView?.userName.text = tip.userFirstName + " " + tip.userLastName
        
        tipView?.tipViewHeightConstraint.constant = tipViewHeightConstraintConstant()
        //    tipView?.likeIcon.hidden = true
        tipView?.tipDescription?.attributedText = NSAttributedString(string: tip.desc, attributes:attributes)
        tipView?.tipDescription.textColor = UIColor.whiteColor()
        tipView?.tipDescription.font = Constants.Fonts.sysFont.fontWithSize(15)
        
        // if tip.likes == 1 {
        tipView?.likes?.text = String(tip.likes)
        //  }
        //   else
        //   {
        //      tipView?.likes?.text = String(tip.likes) + " likes"
        //   }
        
        let tipLat = tip.location.latitude
        let tipLong = tip.location.longitude
        
        directionsAPI.from = PXLocation.CoordinateLocation(CLLocationCoordinate2DMake(Location.sharedInstance.currLat!, Location.sharedInstance.currLong!))
        directionsAPI.to = PXLocation.CoordinateLocation(CLLocationCoordinate2DMake(tipLat, tipLong))
        directionsAPI.mode = PXGoogleDirectionsMode.Walking
        
        directionsAPI.calculateDirections { (response) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                switch response {
                case let .Error(_, error):
                    let alert = UIAlertController(title: Constants.Config.AppName, message: "Error: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: Constants.Notifications.AlertConfirmation, style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                case let .Success(request, routes):
                    self.request = request
                    self.result = routes
                    
                    
                    //                        for i in 0 ..< (self.result).count {
                    //                            if i != self.routeIndex {
                    //                                self.result[i].drawOnMap(self.mapView, strokeColor: UIColor.blueColor(), strokeWidth: 3.0)
                    //
                    //
                    //                            }
                    //
                    //                        }
                    
                    let totalDuration: NSTimeInterval = self.result[self.routeIndex].totalDuration
                    let ti = NSInteger(totalDuration)
                    let minutes = (ti / 60) % 60
                    
                    tipView?.walkingDistance.text = String(minutes)
                    let totalDistance: CLLocationDistance = self.result[self.routeIndex].totalDistance
                    print("The total distance is: \(totalDistance)")
                    //
                    //                        self.distanceLabel.text = String(totalDistance) + " m"
                    //                        self.distanceLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
                    
                    //     self.durationLabel.text = String(minutes) + " mins"
                    //     self.durationLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
                    //                        self.result[self.routeIndex].drawOnMap(self.mapView, strokeColor: UIColor(red: 57/255, green: 148/255, blue: 228/255, alpha: 1), strokeWidth: 4.0)
                    //      self.presentViewController(rvc, animated: true, completion: nil)
                    //            }
                }
            })
        }
        
        locationManager.stopUpdatingLocation()
        tipView?.contentMode = UIViewContentMode.ScaleAspectFill
        
        return tipView!
        
    }
    
    
}
