
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
import PXGoogleDirections
import GoogleMaps
import NVActivityIndicatorView
import ReachabilitySwift
import MBProgressHUD
import FBSDKShareKit
import GeoFire
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Kingfisher
import Nuke
import NukeToucanPlugin


// private let numberOfCards: UInt = 5
private let frameAnimationSpringBounciness:CGFloat = 9
private let frameAnimationSpringSpeed:CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent:CGFloat = 0.1


class SwipeTipViewController: UIViewController, PXGoogleDirectionsDelegate, LocationServiceDelegate {
    
    
    @IBOutlet weak var nearbyText: UIView!
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var addATipButton: UIButton!
    var tips = [Tip]()
    var request: PXGoogleDirections!
    var result: [PXGoogleDirectionsRoute]!
    var routeIndex: Int = 0
    var selectedHomeImage: String!
    var style = NSMutableParagraphStyle()
    var miles = Double()
    var category = String()
    var loader: NVActivityIndicatorView! = nil
    var reachability: Reachability?
    var swipeFlag = false
    var currentTipIndex = Int()
    var currentTip: Tip!
 //   var handle: UInt!
    let dataService = DataService()
    var catRef: FIRDatabaseReference!
    var tipRef: FIRDatabaseReference!
    let tapRec = UITapGestureRecognizer()
    
    var preheater: Preheater!
    var requestArray = [Request]()
    private var ellipsisTimer: Timer?
    private var loadingLabel: UILabel!
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    
    var directionsAPI: PXGoogleDirections {
        return (UIApplication.shared.delegate as! AppDelegate).directionsAPI
    }
    
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavBar()
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        directionsAPI.delegate = self
        LocationService.sharedInstance.delegate = self
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.style.lineSpacing = 2
        self.catRef = self.dataService.CATEGORY_REF
        self.tipRef = self.dataService.TIP_REF
        
        preheater = Preheater()
        
        setupReachability(nil, useClosures: true)
        startNotifier()
        
        tapRec.addTarget(self, action: #selector(SwipeTipViewController.addATipButtonTapped))
        self.addATipButton.addGestureRecognizer(tapRec)
        self.addATipButton.isUserInteractionEnabled = true
        
        //       let size = CGSize(width: 400, height: 400)
        
        
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
        
        LocationService.sharedInstance.startUpdatingLocation()
        self.initLoader()
        
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationService.sharedInstance.stopUpdatingLocation()
    //    if let handle = handle {
    //        catRef.removeObserver(withHandle: handle)
    //    }
    }
    
    
    
    
    private func initLoader() {
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let size = screenWidth
        let frame = CGRect(x: (size
            / 2) - (size / 2), y: (size
                / 2) - (size / 2), width: size
                    / 4, height: screenWidth / 4)
     /*
        self.loadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        self.loadingLabel.textColor = UIColor.primaryTextColor()
        self.loadingLabel.font = UIFont.systemFont(ofSize: 17)
        self.loadingLabel.text = ""
        self.loadingLabel.center = CGPoint(size / 2 , screenHeight / 2)
        self.view.addSubview(loadingLabel)
        
         self.ellipsisTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SwipeTipViewController.updateLabelEllipsis(_:)), userInfo: nil, repeats: true)
       
        
        self.loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self.loadingLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.loadingLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        */
        
      
        
        self.loader = NVActivityIndicatorView(frame: frame, type: .ballSpinFadeLoader, color: UIColor(red: 227/255, green: 19/255, blue: 63/255, alpha: 1), padding: 10)
        self.loader.center = CGPoint(size / 2 , screenHeight / 2)
        loader.alpha = 0.1
        loader.tag = 200
        self.view.addSubview(loader)
        loader.startAnimating()
        
        NSLayoutConstraint(item: self.loader, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.loader, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
 
    }
    
    
    func deInitLoader() {
        /*
        ellipsisTimer?.invalidate()
        ellipsisTimer = nil
        self.loadingLabel.removeFromSuperview()
        */
        
    self.loader.stopAnimating()
    self.loader.removeFromSuperview()
    }
    
  
  /*
    func updateLabelEllipsis(_ timer: Timer) {
        var messageText = String()
        if  self.loadingLabel.text != nil {
        messageText = self.loadingLabel.text!
        }
        let dotCount: Int = (self.loadingLabel.text?.characters.count)! - messageText.replacingOccurrences(of: ".", with: "").characters.count + 1
        self.loadingLabel.text = "  Hang on"
        var addOn: String = "."
        if dotCount < 4 {
            addOn = "".padding(toLength: dotCount, withPad: ".", startingAt: 0)
        }
        else {
            //
            //     let appDelegate  = UIAppliself.dismiss(animated: true, completion: nil)
            //     ellipsisTimer?.invalidate()
            //     ellipsisTimer = nilcation.shared.delegate as! AppDelegate
            //     appDelegate.authenticateUser()
        }
        self.loadingLabel.text = self.loadingLabel.text!.appending(addOn)
    }
*/
    
    
    private func bringTipStackToFront() {
        
        //   self.kolodaView.activityIndicatorView.startAnimating()
        
        if (StackObserver.sharedInstance.passedValue == 10) {
        fetchAllTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration)
        }
        else if (StackObserver.sharedInstance.passedValue >= 0 && StackObserver.sharedInstance.passedValue < 10) {
            self.category = Constants.HomeView.Categories[StackObserver.sharedInstance.passedValue]
            self.fetchTips(walkingDuration: SettingsManager.sharedInstance.defaultWalkingDuration, category: self.category.lowercased())
        }
        
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
        let alertController = UIAlertController()
        alertController.networkAlert(title: Constants.NetworkConnection.NetworkPromptTitle, message: Constants.NetworkConnection.NetworkPromptMessage)
    }
    
    
    @IBAction func returnTap(_ sender: AnyObject) {
        self.kolodaView.revertAction()
    }
    
    
    @IBAction func reportTapped(_ sender: AnyObject) {
        self.popUpReportPrompt()
        self.currentTipIndex = self.kolodaView.returnCurrentTipIndex()
        self.currentTip = tips[self.currentTipIndex]
    }
    
    
    
    private func popUpReportPrompt() {
        
        let title = Constants.Notifications.ReportMessage
        //   let message = Constants.Notifications.ShareMessage
        let cancelButtonTitle = Constants.Notifications.AlertAbort
        let tipButton = Constants.Notifications.ReportTip
        let userButton = Constants.Notifications.ReportUser
        //     let shareTitle = Constants.Notifications.ShareOk
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        //     let shareButton = UIAlertAction(title: shareTitle, style: .Default) { (Action) in
        //         self.showSharePopUp(self.currentTip)
        //     }
        
        let reportButton = UIAlertAction(title: tipButton, style: .default) { (Action) in
            self.showReportVC(tipId: self.currentTip.key!)
        }
        
        let reportUserButton = UIAlertAction(title: userButton, style: .default) { (Action) in
            self.showReportUserVC(userId: self.currentTip.addedByUser)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (Action) in
            //  alertController.d
        }
        
        //     alertController.addAction(shareButton)
        alertController.addAction(reportButton)
        alertController.addAction(reportUserButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    private func showReportVC(tipId: String) {
        
        let storyboard = UIStoryboard(name: "Report", bundle: Bundle.main)
        
        let previewVC = storyboard.instantiateViewController(withIdentifier: "NavReportVC") as! UINavigationController
        previewVC.definesPresentationContext = true
        previewVC.modalPresentationStyle = .overCurrentContext
        
        let reportVC = previewVC.viewControllers.first as! ReportViewController
        reportVC.data = tipId
        self.show(previewVC, sender: nil)
        
        //    self.showViewController(previewVC, sender: nil)
        
    }
    
    
    private func showReportUserVC(userId: String) {
        
        let storyboard = UIStoryboard(name: "ReportUser", bundle: Bundle.main)
        
        let previewVC = storyboard.instantiateViewController(withIdentifier: "NavReportUserVC") as! UINavigationController
        previewVC.definesPresentationContext = true
        previewVC.modalPresentationStyle = .overCurrentContext
        
        let reportVC = previewVC.viewControllers.first as! ReportUserViewController
        reportVC.data = userId
        self.show(previewVC, sender: nil)
    }
    
    
    /*
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
     
     */
    
    
    // MARK: Database methods
    
    func fetchAllTips(walkingDuration: Double) {
        
        
        switch (walkingDuration) {
            
        case let walkingDuration where walkingDuration == 5.0:
            self.miles = 0.22
            break
            
        case let walkingDuration where walkingDuration == 10.0:
            self.miles = 0.44
            break
            
        case let walkingDuration where walkingDuration == 15.0:
            self.miles = 0.65
            break
            
        case let walkingDuration where walkingDuration == 30.0:
            self.miles = 1.3
            break
            
        case let walkingDuration where walkingDuration == 45.0:
            self.miles = 2.0
            break
            
        case let walkingDuration where walkingDuration == 60.0:
            self.miles = 2.6
            break
            
        default:
            break
            
        }
        
        // self.loader.startAnimating()
        var keys = [String]()
        
        
        let geoRef = GeoFire(firebaseRef: dataService.GEO_USER_REF)
        geoRef?.getLocationForKey(FIRAuth.auth()?.currentUser?.uid, withCallback: { (location: CLLocation?, error: Error?) in
            
            if error == nil {
                
                let geoTipRef = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                let distanceInKM = self.miles * 1609.344 / 1000
                let circleQuery = geoTipRef?.query(at: location, withRadius: distanceInKM)  // radius is in km
                
                circleQuery!.observe(.keyEntered, with: { (key, location) in
                    
                    keys.append(key!)
                    
                })
                
                //Execute this code once GeoFire completes the query!
                circleQuery?.observeReady ({
                    
                    //    self.loader.stopAnimating()
                    if keys.count > 0 {
                        
                        print("Number of keys: " + String(keys.count))
                        self.prepareTotalTipList(keys: keys, completion: { (success, tips) in
                            
                            if success {
                            self.tips = tips.reversed()
                            print(self.tips.count)
                            DispatchQueue.main.async {
                                self.kolodaView.reloadData()
                            //    self.deInitLoader()
                                }
                            }
                            else {
                                print(Constants.Logs.OutOfRange)
                                DispatchQueue.main.async(execute: {
                                    self.nearbyText.isHidden = false
                                    self.displayCirclePulse()
                                   // self.deInitLoader()
                                    
                                })
                                
                            }
                            
                        })

                        
                    }
                    else {
                        
                        print(Constants.Logs.OutOfRange)
                        DispatchQueue.main.async(execute: {
                            //   self.kolodaView.activityIndicatorView.stopAnimating()
                            self.nearbyText.isHidden = false
                            self.displayCirclePulse()
                        })
                    }
                    
                })
            }
            else {
                print(error?.localizedDescription)
            }
        })
        
    }
    
    
    private func prepareTotalTipList(keys: [String], completion: @escaping (Bool, [Tip]) -> ()) {
        
        self.tips.removeAll()
        var tipArray = [Tip]()
    //    let myGroup = DispatchGroup()
        
        self.tipRef.queryOrdered(byChild: "likes").observeSingleEvent(of: .value, with: { snapshot in
            
          
            if keys.count > 0 && snapshot.hasChildren() {
                print("Number of tips: " + String(snapshot.childrenCount))
                for tip in snapshot.children.allObjects as! [FIRDataSnapshot] {
                   
                    if (keys.contains(tip.key)) {
                        
                 //       myGroup.enter()
                        let tipObject = Tip(snapshot: tip)
                        tipArray.append(tipObject)
                  //      myGroup.leave()
                    }
                    
                }
                if tipArray.count > 0 {
                completion(true, tipArray)
                }
                else {
                completion(false, tipArray)
                }
               /*
                myGroup.notify(queue: DispatchQueue.main, execute: {
                    if (newTips.count > 0) {
                        self.tips = newTips.reversed()
                        print(self.tips.count)
                     //   DispatchQueue.main.async {
                            self.kolodaView.reloadData()
                            self.loader.stopAnimating()
                            self.loader.removeFromSuperview()
                            //    self.kolodaView.activityIndicatorView.stopAnimating()
                      //  }
                    }
                })
                */
            }
            else {
                completion(false, tipArray)
            }
 
            
        }) {(error: Error) in print(error.localizedDescription)}
        
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
        
        //   self.loader.startAnimating()
        var keys = [String]()
        
        
        let geoRef = GeoFire(firebaseRef: dataService.GEO_USER_REF)
        geoRef?.getLocationForKey(FIRAuth.auth()?.currentUser?.uid, withCallback: { (location: CLLocation?, error: Error?) in
            
            if error == nil {
                
                
                // query only category tips
                
                let geoTipRef = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                let distanceInKM = self.miles * 1609.344 / 1000
                let circleQuery = geoTipRef?.query(at: location, withRadius: distanceInKM)  // radius is in km
                
                circleQuery!.observe(.keyEntered, with: { (key, location) in
                    
                    keys.append(key!)
                    
                })
                
                //Execute this code once GeoFire completes the query!
                circleQuery?.observeReady ({
                    
                    //    self.loader.stopAnimating()
                    
                    if keys.count > 0 {
                        self.prepareCategoryTipList(keys: keys, category: category, completion: { (success, tips) in
                            
                            if success {
                                self.tips = tips.reversed()
                                print(self.tips.count)
                                DispatchQueue.main.async {
                                    self.kolodaView.reloadData()
                                 //   self.deInitLoader()
                                }
                            }
                            else {
                                print(Constants.Logs.OutOfRange)
                                DispatchQueue.main.async(execute: {
                                    self.nearbyText.isHidden = false
                                    self.displayCirclePulse()
                               //     self.deInitLoader()
                                    
                                })
                                
                            }
                            
                        })
                    }
                    
                })
                
            }
        })
        
    }
    
    
    private func prepareCategoryTipList(keys: [String], category: String, completion: @escaping (Bool, [Tip]) -> ()) {
        
        self.tips.removeAll()
        var tipArray = [Tip]()
   //     let myGroup = DispatchGroup.init()
        
        
        self.catRef.child(category).queryOrdered(byChild: "likes").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if keys.count > 0 && snapshot.hasChildren() {
                print("Number of tips: " + String(snapshot.childrenCount))
                for tip in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
                    if (keys.contains(tip.key)) {
                        
                        //       myGroup.enter()
                        let tipObject = Tip(snapshot: tip)
                        tipArray.append(tipObject)
                        //      myGroup.leave()
                    }
                    
                }
                if tipArray.count > 0 {
                    completion(true, tipArray)
                }
                else {
                    completion(false, tipArray)
                }
              
            }
            else {
                completion(false, tipArray)
            }
            
        })
        
     /*
        self.handle = self.catRef.child(category).queryOrdered(byChild: "likes").observe( .childAdded, with: { (snapshot) in
            
            
            //      for tip in snapshot.children.allObjects as! [FIRDataSnapshot] {
            
            if (keys.contains(snapshot.key)) {
                
                myGroup.enter()
                let tipObject = Tip(snapshot: snapshot)
                newTips.append(tipObject)
                myGroup.leave()
            }
            
            //       }
            
            myGroup.notify(queue: DispatchQueue.main, execute: {
                if (newTips.count > 0) {
                    self.tips = newTips.reversed()
                    DispatchQueue.main.async {
                        self.kolodaView.reloadData()
                        self.loader.stopAnimating()
                        self.loader.removeFromSuperview()
                        
                        //      self.kolodaView.activityIndicatorView.stopAnimating()
                    }
                }
                else {
                    print(Constants.Logs.OutOfRange)
                    DispatchQueue.main.async(execute: {
                        //     self.kolodaView.activityIndicatorView.stopAnimating()
                        self.nearbyText.isHidden = false
                        self.displayCirclePulse()
                        self.loader.stopAnimating()
                        self.loader.removeFromSuperview()
                        
                        
                    })
                    
                }
            })
            
        })
        */
        
    }
    
    
    
    
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    
    func tipViewHeightConstraintConstant() -> CGFloat {
        switch self.screenHeight() {
        case 568:
            return 95
            
        case 667:
            return 95
            
        case 736:
            return 95
            
        default:
            return 95
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
        let circlePulse = NVActivityIndicatorView(frame: frame, type: .ballScaleMultiple, color: UIColor(red: 227/255, green: 19/255, blue: 63/255, alpha: 1), padding: 10)
        circlePulse.alpha = 0.1
        circlePulse.tag = 100
        circlePulse.isUserInteractionEnabled = false
        //  self.view.addSubview(circlePulse)
        self.view.addSubview(circlePulse)
        circlePulse.startAnimating()
        NSLayoutConstraint(item: circlePulse, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: circlePulse, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        
    }
    
    
    
    func handleLikeCount(currentTip: Tip) {
        
        let tipListRef = self.dataService.CURRENT_USER_REF.child("tipsLiked")
        self.dataService.CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let a = snapshot.hasChild("tipsLiked")
            let b = snapshot.childSnapshot(forPath: "tipsLiked").hasChild(currentTip.key!)
            
            if a {
                
                if b {
                    print(Constants.Logs.TipAlreadyLiked)
                    self.openMap(currentTip: currentTip)
                }
                else {
                    tipListRef.updateChildValues([currentTip.key! : true])
                    self.incrementTip(currentTip: currentTip)
                }
            }
            else {
                tipListRef.updateChildValues([currentTip.key! : true])
                self.incrementTip(currentTip: currentTip)
            }
            
            
            //      print(Constants.Logs.RequestDidFail)
            
        })
        
        
    }
    
    
    private func openMap(currentTip: Tip) {
        
        DispatchQueue.main.async {
            
            let mapViewController = MapViewController()
            mapViewController.data = currentTip
            self.addChildViewController(mapViewController)
            mapViewController.view.frame = self.view.frame
            self.view.addSubview(mapViewController.view)
            mapViewController.didMove(toParentViewController: self)
            self.kolodaView.revertAction()
            
        }
    }
    
    
    
    private func incrementTip(currentTip: Tip) {
        
        if let key = currentTip.key {
            self.dataService.TIP_REF.child(key).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                
                if var data = currentData.value as? [String : Any] {
                    var count = data["likes"] as! Int
                    
                    count += 1
                    data["likes"] = count
                    
                    currentData.value = data
                    self.dataService.CATEGORY_REF.child(currentTip.category).child(key).updateChildValues(["likes" : count])
                    self.dataService.USER_TIP_REF.child(currentTip.addedByUser).child(key).updateChildValues(["likes" : count])
                    
                    return FIRTransactionResult.success(withValue: currentData)
                }
                return FIRTransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if committed {
                    let tip = Tip(snapshot: snapshot!)
                    self.runTransactionOnUser(currentTip: tip)
                    print(Constants.Logs.TipIncrementSuccess)
                    
                }
            }
        }
        
    }
    
    
    private func runTransactionOnUser(currentTip: Tip) {
        
        if let userId = currentTip.addedByUser {
            self.dataService.USER_REF.child(userId).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                
                if var data = currentData.value as? [String : Any] {
                    var count = data["totalLikes"] as! Int
                    
                    count += 1
                    data["totalLikes"] = count
                    
                    currentData.value = data
                    
                    return FIRTransactionResult.success(withValue: currentData)
                }
                return FIRTransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if committed {
                    DispatchQueue.main.async {
                        self.openMap(currentTip: currentTip)
                    }
                    
                }
            }
        }
        
        
    }
    
    
    
    func applyGradient(tipView: CustomTipView) {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor.clear.withAlphaComponent(0.5), UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black
            .withAlphaComponent(0.9).cgColor, UIColor.black.cgColor]
        gradient.locations = [0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8]
        
        tipView.tipImage.layer.insertSublayer(gradient, at: 0)
        
    }
    
    func googleDirectionsWillSendRequestToAPI(_ googleDirections: PXGoogleDirections, withURL requestURL: URL) -> Bool {
        return true
    }
    
    func googleDirectionsDidSendRequestToAPI(_ googleDirections: PXGoogleDirections, withURL requestURL: URL) {
    }
    
    func googleDirections(_ googleDirections: PXGoogleDirections, didReceiveRawDataFromAPI data: Data) {
        
    }
    
    func googleDirectionsRequestDidFail(_ googleDirections: PXGoogleDirections, withError error: NSError) {
    }
    
    func googleDirections(_ googleDirections: PXGoogleDirections, didReceiveResponseFromAPI apiResponse: [PXGoogleDirectionsRoute]) {
    }
    
    
    // MARK: LocationService Delegate
    func tracingLocation(_ currentLocation: CLLocation) {
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        print(lat)
        print(lon)
        if let currentUser = UserDefaults.standard.value(forKey: "uid") as? String {
            let geoFire = GeoFire(firebaseRef: dataService.GEO_USER_REF)
            geoFire?.setLocation(CLLocation(latitude: lat, longitude: lon), forKey: currentUser)
        }
    }
    
    
    func tracingLocationDidFailWithError(_ error: NSError) {
        print("tracing Location Error : \(error.description)")
    }
    
}


//MARK: KolodaViewDelegate

extension SwipeTipViewController: KolodaViewDelegate {
    
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
    }
    
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        if (direction == .right) {
            
            //   increment like
            let currentTip = tips[Int(index)]
            self.handleLikeCount(currentTip: currentTip)
            
        }
        
        if (direction == .left) {
            print(Constants.Logs.SwipedLeft)
        }
        
    }
    
    
}



extension SwipeTipViewController: KolodaViewDataSource {
    
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return self.tips.count
        
    }
    
    
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        if let tipView = Bundle.main.loadNibNamed(Constants.NibNames.TipView, owner: self, options: nil)![0] as? CustomTipView {
            
            let tip = self.tips[index]
            let attributes = [NSParagraphStyleAttributeName : style]
            
            tipView.distanceImage.isHidden = true
            tipView.likeImage.isHidden = true
            tipView.by.isHidden = true
            tipView.contentMode = UIViewContentMode.scaleAspectFill
            
            if let tipPicUrl = tip.tipImageUrl {
                
            //    if let placeholder = UIImage(named: "placeholder") {
                
                    if let url = URL(string: tipPicUrl) {
            //    let processor = ResizingImageProcessor(targetSize: CGSize(width: 300, height: 500))
                    let request = Request(url: url)
                    ImageHelper.loadImage(with: request, into: tipView.tipImage, completion: { (Void) in
                        
                        if index == 0 {
                        self.deInitLoader()
                        }
                        
                        
                        self.applyGradient(tipView: tipView)
                        
                        tipView.tipViewHeightConstraint.constant = self.tipViewHeightConstraintConstant()
                        tipView.tipDescription?.attributedText = NSAttributedString(string: tip.description, attributes:attributes)
                        tipView.tipDescription.textColor = UIColor.white
                        tipView.tipDescription.font = UIFont.systemFont(ofSize: 15)
                        
                        if let likes = tip.likes {
                            tipView.likes?.text = String(likes)
                            if likes == 1 {
                                tipView.likesLabel.text = "Like"
                            }
                            else {
                                tipView.likesLabel.text = "Likes"
                            }
                        }
                        
                        if let name = tip.userName {
                            tipView.userName.text = name
                        }
                        
                        
                        if let picUrl = tip.userPicUrl {
                            tipView.setUserImage(urlString: picUrl, placeholder: nil, completion: { (success) in
                                
                                if success {
                                    
                                    tipView.userImage.layer.cornerRadius = tipView.userImage.frame.size.width / 2
                                    tipView.userImage.clipsToBounds = true
                                    tipView.userImage.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
                                    tipView.userImage.layer.borderWidth = 0.8
                                    
                                    
                                }
                            })
                            
                        }
                        
                        let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                        geo?.getLocationForKey(tip.key, withCallback: { (location, error) in
                            
                            if error == nil {
                                
                                if let lat = location?.coordinate.latitude {
                                    
                                    if let long = location?.coordinate.longitude {
                                        
                                        self.directionsAPI.from = PXLocation.coordinateLocation(CLLocationCoordinate2DMake((LocationService.sharedInstance.currentLocation?.coordinate.latitude)!, (LocationService.sharedInstance.currentLocation?.coordinate.longitude)!))
                                        self.directionsAPI.to = PXLocation.coordinateLocation(CLLocationCoordinate2DMake(lat, long))
                                        self.directionsAPI.mode = PXGoogleDirectionsMode.walking
                                        
                                        self.directionsAPI.calculateDirections { (response) -> Void in
                                            DispatchQueue.main.async(execute: {
                                                //      })
                                                //   dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                switch response {
                                                case let .error(_, error):
                                                    let alertController = UIAlertController()
                                                    alertController.defaultAlert(title: Constants.Config.AppName, message: "Error: \(error.localizedDescription)")
                                                case let .success(request, routes):
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
                                                    
                                                    let totalDuration: TimeInterval = self.result[self.routeIndex].totalDuration
                                                    //   let ti = NSInteger(totalDuration)
                                                    //   let minutes = (ti / 60) % 60
                                                    let minutes = LocationService.sharedInstance.minutesFromTimeInterval(interval: totalDuration)
                                                    
                                                    tipView.walkingDistance.text = String(minutes)
                                                    
                                                    if minutes == 1 {
                                                        tipView.distanceLabel.text = "Min"
                                                    }
                                                    else {
                                                        tipView.distanceLabel.text = "Mins"
                                                    }
                                                    let totalDistance: CLLocationDistance = self.result[self.routeIndex].totalDistance
                                                    print("The total distance is: \(totalDistance)")
                                                    
                                                }
                                            })
                                        }
                                        
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            else {
                                
                                print(error?.localizedDescription)
                            }
                            
                            
                        })
                        
                        tipView.distanceImage.isHidden = false
                        tipView.likeImage.isHidden = false
                        tipView.by.isHidden = false
                        
                        
                    })
                    }
                
                    
                    /*
                tipView.tipImage.kf.setImage(with: url, placeholder: placeholder, progressBlock: { receivedSize, totalSize in
                    print("Loading progress: \(receivedSize)/\(totalSize)")
                }, completionHandler: { (image, error, cacheType, imageUrl) in
                    
                    if error == nil {
                    
                        self.applyGradient(tipView: tipView)
                        
                        tipView.tipViewHeightConstraint.constant = self.tipViewHeightConstraintConstant()
                        tipView.tipDescription?.attributedText = NSAttributedString(string: tip.description, attributes:attributes)
                        tipView.tipDescription.textColor = UIColor.white
                        tipView.tipDescription.font = UIFont.systemFont(ofSize: 15)
                        
                        if let likes = tip.likes {
                            tipView.likes?.text = String(likes)
                            if likes == 1 {
                                tipView.likesLabel.text = "Like"
                            }
                            else {
                                tipView.likesLabel.text = "Likes"
                            }
                        }
                        
                        if let name = tip.userName {
                            tipView.userName.text = name
                        }
                        
                        
                        if let picUrl = tip.userPicUrl {
                            tipView.setUserImage(urlString: picUrl, placeholder: nil, completion: { (success) in
                                
                                if success {
                                    
                                    tipView.userImage.layer.cornerRadius = tipView.userImage.frame.size.width / 2
                                    tipView.userImage.clipsToBounds = true
                                    tipView.userImage.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
                                    tipView.userImage.layer.borderWidth = 0.8
                                    
                                    
                                }
                            })
                            
                        }
                        
                        let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                        geo?.getLocationForKey(tip.key, withCallback: { (location, error) in
                            
                            if error == nil {
                                
                                if let lat = location?.coordinate.latitude {
                                    
                                    if let long = location?.coordinate.longitude {
                                        
                                        self.directionsAPI.from = PXLocation.coordinateLocation(CLLocationCoordinate2DMake((LocationService.sharedInstance.currentLocation?.coordinate.latitude)!, (LocationService.sharedInstance.currentLocation?.coordinate.longitude)!))
                                        self.directionsAPI.to = PXLocation.coordinateLocation(CLLocationCoordinate2DMake(lat, long))
                                        self.directionsAPI.mode = PXGoogleDirectionsMode.walking
                                        
                                        self.directionsAPI.calculateDirections { (response) -> Void in
                                            DispatchQueue.main.async(execute: {
                                                //      })
                                                //   dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                switch response {
                                                case let .error(_, error):
                                                    let alertController = UIAlertController()
                                                    alertController.defaultAlert(title: Constants.Config.AppName, message: "Error: \(error.localizedDescription)")
                                                case let .success(request, routes):
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
                                                    
                                                    let totalDuration: TimeInterval = self.result[self.routeIndex].totalDuration
                                                    //   let ti = NSInteger(totalDuration)
                                                    //   let minutes = (ti / 60) % 60
                                                    let minutes = LocationService.sharedInstance.minutesFromTimeInterval(interval: totalDuration)
                                                    
                                                    tipView.walkingDistance.text = String(minutes)
                                                    
                                                    if minutes == 1 {
                                                        tipView.distanceLabel.text = "Min"
                                                    }
                                                    else {
                                                        tipView.distanceLabel.text = "Mins"
                                                    }
                                                    let totalDistance: CLLocationDistance = self.result[self.routeIndex].totalDistance
                                                    print("The total distance is: \(totalDistance)")
                                                    
                                                }
                                            })
                                        }
                                        
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            else {
                                
                                print(error?.localizedDescription)
                            }
                            
                            
                        })
                        
                        tipView.distanceImage.isHidden = false
                        tipView.likeImage.isHidden = false
                        tipView.by.isHidden = false
                    }
                    else {
                    print(error?.localizedDescription)
                    }
                    
                })
                    */
                
        //    }
            
                /*
                    tipView.setTipImage(urlString: tipPicUrl, placeholder: placeholder, completion: { (success) in
                 
                        if success {
                 
                            self.applyGradient(tipView: tipView)
                            
                            tipView.tipViewHeightConstraint.constant = self.tipViewHeightConstraintConstant()
                            tipView.tipDescription?.attributedText = NSAttributedString(string: tip.description, attributes:attributes)
                            tipView.tipDescription.textColor = UIColor.white
                            tipView.tipDescription.font = UIFont.systemFont(ofSize: 15)
                            
                            if let likes = tip.likes {
                                tipView.likes?.text = String(likes)
                                if likes == 1 {
                                    tipView.likesLabel.text = "Like"
                                }
                                else {
                                    tipView.likesLabel.text = "Likes"
                                }
                            }
                            
                            if let name = tip.userName {
                                tipView.userName.text = name
                            }
                            
                            
                            if let picUrl = tip.userPicUrl {
                                tipView.setUserImage(urlString: picUrl, placeholder: nil, completion: { (success) in
                                    
                                    if success {
                                        
                                        tipView.userImage.layer.cornerRadius = tipView.userImage.frame.size.width / 2
                                        tipView.userImage.clipsToBounds = true
                                        tipView.userImage.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
                                        tipView.userImage.layer.borderWidth = 0.8
                                        
                                        
                                    }
                                })
                                
                            }
                            
                            let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                            geo?.getLocationForKey(tip.key, withCallback: { (location, error) in
                                
                                if error == nil {
                                    
                                    if let lat = location?.coordinate.latitude {
                                        
                                        if let long = location?.coordinate.longitude {
                                            
                                            self.directionsAPI.from = PXLocation.coordinateLocation(CLLocationCoordinate2DMake((LocationService.sharedInstance.currentLocation?.coordinate.latitude)!, (LocationService.sharedInstance.currentLocation?.coordinate.longitude)!))
                                            self.directionsAPI.to = PXLocation.coordinateLocation(CLLocationCoordinate2DMake(lat, long))
                                            self.directionsAPI.mode = PXGoogleDirectionsMode.walking
                                            
                                            self.directionsAPI.calculateDirections { (response) -> Void in
                                                DispatchQueue.main.async(execute: {
                                                    //      })
                                                    //   dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                    switch response {
                                                    case let .error(_, error):
                                                        let alertController = UIAlertController()
                                                        alertController.defaultAlert(title: Constants.Config.AppName, message: "Error: \(error.localizedDescription)")
                                                    case let .success(request, routes):
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
                                                        
                                                        let totalDuration: TimeInterval = self.result[self.routeIndex].totalDuration
                                                        //   let ti = NSInteger(totalDuration)
                                                        //   let minutes = (ti / 60) % 60
                                                        let minutes = LocationService.sharedInstance.minutesFromTimeInterval(interval: totalDuration)
                                                        
                                                        tipView.walkingDistance.text = String(minutes)
                                                        
                                                        if minutes == 1 {
                                                            tipView.distanceLabel.text = "Min"
                                                        }
                                                        else {
                                                            tipView.distanceLabel.text = "Mins"
                                                        }
                                                        let totalDistance: CLLocationDistance = self.result[self.routeIndex].totalDistance
                                                        print("The total distance is: \(totalDistance)")
                                                        
                                                    }
                                                })
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                else {
                                    
                                    print(error?.localizedDescription)
                                }
                                
                                
                            })
                            
                            tipView.distanceImage.isHidden = false
                            tipView.likeImage.isHidden = false
                            tipView.by.isHidden = false
                            
                            
                        }
                        
                        
                    })
 */
                    
                
                    
              //  }
            }
            return tipView
            
        }
        return koloda
    }
    
}

