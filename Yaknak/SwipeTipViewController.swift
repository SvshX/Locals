
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
import GoogleMaps
import GooglePlaces
import NVActivityIndicatorView
import ReachabilitySwift
import MBProgressHUD
import FBSDKShareKit
import GeoFire
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Kingfisher


// private let numberOfCards: UInt = 5
private let frameAnimationSpringBounciness:CGFloat = 9
private let frameAnimationSpringSpeed:CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent:CGFloat = 0.1




class SwipeTipViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var nearbyText: UIView!
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var addATipButton: UIButton!
    var tips = [Tip]()
    var selectedHomeImage: String!
    var style = NSMutableParagraphStyle()
    var miles = Double()
    var category = String()
    var loader: NVActivityIndicatorView! = nil
    var reachability: Reachability?
    var currentTipIndex = Int()
    var currentTip: Tip!
    let dataService = DataService()
    var catRef: FIRDatabaseReference!
    var tipRef: FIRDatabaseReference!
    let tapRec = UITapGestureRecognizer()
    
    private var loadingLabel: UILabel!
    private let hoofImage = UIImageView()
    private let hoofImage2 = UIImageView()
    
    let screenSize: CGRect = UIScreen.main.bounds
    let xStartPoint: CGFloat = 40.0
    var xOffset: CGFloat = 0.0
    var mapViewController: MapViewController!
    let mapTasks = MapTasks()
    var travelMode = TravelMode.Modes.walking
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavBar()
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.style.lineSpacing = 2
        self.catRef = self.dataService.CATEGORY_REF
        self.tipRef = self.dataService.TIP_REF
        setupReachability(nil, useClosures: true)
        startNotifier()
        self.nearbyText.isHidden = true
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(self.addATipButtonTapped(_:)))
        tapRec.delegate = self

        
        self.addATipButton.addGestureRecognizer(tapRec)
        self.addATipButton.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SwipeTipViewController.updateStack),
                                               name: NSNotification.Name(rawValue: "distanceChanged"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SwipeTipViewController.retainStack),
                                               name: NSNotification.Name(rawValue: "retainStack"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SwipeTipViewController.reloadStack),
                                               name: NSNotification.Name(rawValue: "reloadStack"),
                                               object: nil)

        
        LocationService.sharedInstance.onTracingLocation = { currentLocation in
            
            print("Location is being tracked...")
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            
            if let currentUser = UserDefaults.standard.value(forKey: "uid") as? String {
                let geoFire = GeoFire(firebaseRef: self.dataService.GEO_USER_REF)
                geoFire?.setLocation(CLLocation(latitude: lat, longitude: lon), forKey: currentUser)
            }
            
        }
        
        LocationService.sharedInstance.onTracingLocationDidFailWithError = { error in
            print("tracing Location Error : \(error.description)")
        }
        
        
        LocationService.sharedInstance.onSettingsPrompt = {
            self.showNeedAccessMessage()
        }
        
        
        StackObserver.sharedInstance.onCategorySelected = { categoryId in
        
            
            if self.mapViewController != nil && self.mapViewController.isViewLoaded {
                self.mapViewController.removeAnimate()
            }
            
            self.kolodaView.removeStack()
            self.initLoader()
            self.bringTipStackToFront(categoryId: categoryId)
        }
        
      
        
        if (UserDefaults.standard.bool(forKey: "isTracingLocationEnabled")) {
            self.initLoader()
            self.bringTipStackToFront(categoryId: StackObserver.sharedInstance.categorySelected)
        }
        
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /*
        if !self.nearbyText.isHidden {
        self.hideNoTipsAround()
        }
 */
        if (UserDefaults.standard.bool(forKey: "isTracingLocationEnabled")) {
        LocationService.sharedInstance.stopUpdatingLocation()
        }
    }
    
   
    
    private func initLoader() {
        self.hideNoTipsAround()
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let size = screenWidth
        let frame = CGRect(x: (size
            / 2) - (size / 2), y: (size
                / 2) - (size / 2), width: size
                    / 4, height: screenWidth / 4)
        
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
    self.loader.stopAnimating()
    self.loader.removeFromSuperview()
    }
    
    
    private func showNeedAccessMessage() {
        let alertController = UIAlertController()
        alertController.promptRedirectToSettings(title: "Info", message: "Yaknak needs to access your location. Tips will be presented based on it.")
    }

    
    
    private func showNoTipsAround() {
        print(Constants.Logs.OutOfRange)
        DispatchQueue.main.async(execute: {
            self.nearbyText.isHidden = false
            self.displayCirclePulse()
          //  self.showHoofAnimation()
        })
    }
    
    
    private func hideNoTipsAround() {
        self.nearbyText.isHidden = true
        for subView in self.view.subviews {
            if (subView.tag == 100) {
                subView.removeFromSuperview()
            }
        }
    }
    
    
    private func bringTipStackToFront(categoryId: Int) {
        
        self.tips.removeAll()
        if let radius = LocationService.sharedInstance.determineRadius() {
        if categoryId == 10 {
        fetchAllTips(radius: radius)
        }
        else if 0...9 ~= categoryId {
            self.category = Constants.HomeView.Categories[categoryId]
            self.fetchTips(radius: radius, category: self.category.lowercased())
        }
        }
        
    }
    
    
    func updateStack() {
    self.bringTipStackToFront(categoryId: StackObserver.sharedInstance.categorySelected)
    }
    
    
    func reloadStack() {
        self.kolodaView.removeStack()
        self.updateStack()
     //   self.kolodaView.reloadCardsInIndexRange(0..<self.kolodaView.currentCardIndex + 1)
        UserDefaults.standard.removeObject(forKey: "likeCountChanged")
        }
    
    
    func retainStack() {
        self.kolodaView.reloadData()
        UserDefaults.standard.removeObject(forKey: "likeCountChanged")
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
    
    
    @IBAction func returnTapped(_ sender: UITapGestureRecognizer) {
        self.kolodaView.revertAction()
    }
    
    
    @IBAction func reportTapped(_ sender: UITapGestureRecognizer) {
        self.popUpReportPrompt()
        self.currentTipIndex = self.kolodaView.returnCurrentTipIndex()
        self.currentTip = tips[self.currentTipIndex]
    }
    
    
    @IBAction func returnButtonTapped(_ sender: Any) {
        self.kolodaView.revertAction()
    }
    
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        self.popUpReportPrompt()
        self.currentTipIndex = self.kolodaView.returnCurrentTipIndex()
        self.currentTip = tips[self.currentTipIndex]
    }
 /*
    func returnTapped(_ sender: UIGestureRecognizer) {
         self.kolodaView.revertAction()
    }
    
    
    func reportTapped(_ sender: UIGestureRecognizer) {
        self.popUpReportPrompt()
        self.currentTipIndex = self.kolodaView.returnCurrentTipIndex()
        self.currentTip = tips[self.currentTipIndex]
    }
 */
    /*
    @IBAction func returnTap(_ sender: AnyObject) {
        self.kolodaView.revertAction()
    }
    
    
    @IBAction func reportTapped(_ sender: AnyObject) {
        self.popUpReportPrompt()
        self.currentTipIndex = self.kolodaView.returnCurrentTipIndex()
        self.currentTip = tips[self.currentTipIndex]
    }
    
    */
    
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
    
    func fetchAllTips(radius: Double) {
        
        var keys = [String]()
        
        let geoRef = GeoFire(firebaseRef: dataService.GEO_USER_REF)
        geoRef?.getLocationForKey(FIRAuth.auth()?.currentUser?.uid, withCallback: { (location: CLLocation?, error: Error?) in
            
            if error == nil {
                
                let geoTipRef = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                let circleQuery = geoTipRef?.query(at: location, withRadius: radius)  // radius is in km
                
                circleQuery!.observe(.keyEntered, with: { (key, location) in
                    
                    keys.append(key!)
                    
                })
                
                //Execute this code once GeoFire completes the query!
                circleQuery?.observeReady ({
                    
                    //    self.loader.stopAnimating()
                    if keys.count > 0 {
                        
                        print("Number of keys: \(keys.count)")
                        self.prepareTotalTipList(keys: keys, completion: { (success, tips) in
                            
                            if success {
                            self.tips = tips.reversed()
                            print(self.tips.count)
                            DispatchQueue.main.async {
                                self.deInitLoader()
                                self.kolodaView.reloadData()
                                }
                            }
                            else {
                               self.showNoTipsAround()
                                self.deInitLoader()
                            }
                            
                        })

                        
                    }
                    else {
                        DispatchQueue.main.async {
                            self.deInitLoader()
                            self.showNoTipsAround()
                        }
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
            
          
            if snapshot.hasChildren() {
                print("Number of tips: \(snapshot.childrenCount)")
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
 
            
        }) {(error: Error) in print(error.localizedDescription)}
        
    }
    
    
    
    func fetchTips(radius: Double, category: String) {
        
        var keys = [String]()
        let geoRef = GeoFire(firebaseRef: dataService.GEO_USER_REF)
        geoRef?.getLocationForKey(FIRAuth.auth()?.currentUser?.uid, withCallback: { (location: CLLocation?, error: Error?) in
            
            if error == nil {
                
                
                // query only category tips
                
                let geoTipRef = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                let circleQuery = geoTipRef?.query(at: location, withRadius: radius)  // radius is in km
                
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
                                print("\(self.tips.count)" + " Tips will be displayed...")
                                DispatchQueue.main.async {
                                    self.deInitLoader()
                                    self.kolodaView.reloadData()
                                }
                            }
                            else {
                              self.deInitLoader()
                              self.showNoTipsAround()
                            }
                            
                        })
                    }
                    else {
                        DispatchQueue.main.async {
                            self.deInitLoader()
                            self.showNoTipsAround()
                        }
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
                print("Number of tips: \(snapshot.childrenCount)")
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
        
}
    
    
    
    
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    
    func tipImageViewHeightConstraintMultiplier() -> CGFloat {
        switch self.screenHeight() {
        case 568:
            return 0.68
            
        case 667:
            return 0.73
            
        case 736:
            return 0.75
            
        default:
            return 0.73
        }
    }
    
    
    //    //MARK: IBActions
    
    
    func addATipButtonTapped(_ sender: UIGestureRecognizer) {
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
    
 /*
    private func showHoofAnimation() {
        
        self.hoofImage.image = UIImage(named: "hoof")
        self.hoofImage.frame = CGRect(x: 20, y: (screenSize.height / 2) + 20, width: 20, height: 20)
        self.hoofImage.tag = 100
        self.view.addSubview(self.hoofImage)
        
        self.hoofImage2.image = UIImage(named: "hoof")
        self.hoofImage2.frame = CGRect(x: 40, y: screenSize.height / 2, width: 20, height: 20)
        self.hoofImage2.tag = 300
        self.view.addSubview(self.hoofImage2)
        
  //      for i in 0...10 {
        moveOneStep()
  //      }
        
        /*
    
        let f = NSValue(cgPoint: CGPoint(10, 10))
        let m = NSValue(cgPoint: CGPoint(100, 10))
        let n = NSValue(cgPoint: CGPoint(10, 100))
        let pathArray = [f, m, n, f]
        
        
        // loop from 0 to 5
   //     for i in 0...5 {
            
    let imageView = UIImageView()
    imageView.image = UIImage(named: "hoof")
    imageView.frame = CGRect(x: 55, y: 300, width: 20, height: 20)
    imageView.tag = 100
    self.view.addSubview(imageView)
    
        
            // randomly create a value between 0.0 and 150.0
            let randomYOffset = CGFloat( arc4random_uniform(150))
        
        // now create a bezier path that defines our curve
        // the animation function needs the curve defined as a CGPath
        // but these are more difficult to work with, so instead
        // we'll create a UIBezierPath, and then create a
        // CGPath from the bezier when we need it
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 16,y: 239 + randomYOffset))
        path.addCurve(to: CGPoint(x: 301, y: 239 + randomYOffset), controlPoint1: CGPoint(x: 136, y: 373 + randomYOffset), controlPoint2: CGPoint(x: 178, y: 110 + randomYOffset))
        
        // create a new CAKeyframeAnimation that animates the objects position
        let anim = CAKeyframeAnimation(keyPath: "position")
        
        // set the animations path to our bezier curve
     //   anim.path = path.cgPath
        anim.values = pathArray
        anim.keyTimes = [0.2, 0.4, 0.7, 1.0]
        // set some more parameters for the animation
        // this rotation mode means that our object will rotate so that it's parallel to whatever point it is currently on the curve
        anim.rotationMode = kCAAnimationRotateAuto
        anim.repeatCount = Float.infinity
//        anim.duration = 5.0

        // each square will take between 4.0 and 8.0 seconds
        // to complete one animation loop
        anim.duration = Double(arc4random_uniform(40)+30) / 10
            
        // stagger each animation by a random value
        // `290` was chosen simply by experimentation
    //    anim.timeOffset = Double(arc4random_uniform(290))
        anim.timeOffset = 1
        
        // we add the animation to the images 'layer' property
        imageView.layer.add(anim, forKey: "animate position along path")
        
    /*
        UIView.perform(UISystemAnimation.delete, on: viewsToAnimate, options: [], animations: {
            
            print("")
            
        }, completion: { (finished) in
            print("")
            
        })
 */
            
   //     }
    
    */
    }
    
    
    func moveOneStep() {
    
        UIView.animate(withDuration: 0.0,
                       delay: 2.5,
                       options: .curveEaseInOut,
                       animations: {
                        self.hoofImage.alpha = 1.0
                        self.hoofImage.center = CGPoint(x: self.xStartPoint + self.xOffset, y: (self.screenSize.height / 2) + 20)
        },
                       completion: { finished in
                   //     self.hoofImage.alpha = 0.0
                        self.xOffset += 20
                            self.move2()
                        
        })
    
    }
    
    func move2() {
        
        UIView.animate(withDuration: 0.0,
                       delay: 2.5,
                       options: .curveEaseInOut,
                       animations: {
                        self.hoofImage2.alpha = 1.0
                        self.hoofImage2.center = CGPoint(x: self.xStartPoint + self.xOffset, y: (self.screenSize.height / 2))
        },
                       completion: { finished in
                    //    self.hoofImage2.alpha = 0.0
                        self.xOffset += 20
                            self.move3()
                        
        })
        
    }
    
    func move3() {
        
        UIView.animate(withDuration: 0.0,
                       delay: 2.5,
                       options: .curveEaseInOut,
                       animations: {
                        self.hoofImage.alpha = 1.0
                        self.hoofImage.center = CGPoint(x: self.xStartPoint + self.xOffset, y: (self.screenSize.height / 2 + 20))
        },
                       completion: { finished in
                    //    self.hoofImage.alpha = 0.0
                        self.xOffset += 20
                        self.move4()
                        
        })
        
    }
    
    func move4() {
        
        UIView.animate(withDuration: 0.0,
                       delay: 2.5,
                       options: .curveEaseInOut,
                       animations: {
                        self.hoofImage2.alpha = 1.0
                        self.hoofImage2.center = CGPoint(x: self.xStartPoint + self.xOffset, y: (self.screenSize.height / 2))
        },
                       completion: { finished in
                   //     self.hoofImage2.alpha = 0.0
                        self.xOffset += 20
                        
        })
        
    }
    */
   
    
    
    func handleLikeCount(currentTip: Tip) {
        
        let tipListRef = self.dataService.CURRENT_USER_REF.child("tipsLiked")
        self.dataService.CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let a = snapshot.hasChild("tipsLiked")
            let b = snapshot.childSnapshot(forPath: "tipsLiked").hasChild(currentTip.key!)
            
            if a {
                
                if b {
                    print(Constants.Logs.TipAlreadyLiked)
                    self.openMap(currentTip: currentTip)
                    
                    
                    // Bug: stack starts from the beginning
                    StackObserver.sharedInstance.likeCountChanged = false
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
            
            self.mapViewController = MapViewController()
            self.mapViewController.data = currentTip
            self.addChildViewController(self.mapViewController)
            self.mapViewController.view.frame = self.view.frame
            self.view.addSubview(self.mapViewController.view)
            self.mapViewController.didMove(toParentViewController: self)
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
                    
                    return FIRTransactionResult.success(withValue: currentData)
                }
                return FIRTransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if committed {
                    
                    if let snap = snapshot?.value as? [String : Any] {
                        
                        if let likes = snap["likes"] as? Int {
                            self.dataService.CATEGORY_REF.child(currentTip.category).child(key).updateChildValues(["likes" : likes])
                            self.dataService.USER_TIP_REF.child(currentTip.addedByUser).child(key).updateChildValues(["likes" : likes])
                            
                        }
                        
                    }
                    
                    let tip = Tip(snapshot: snapshot!)
                    self.runTransactionOnUser(currentTip: tip)
                    print(Constants.Logs.TipIncrementSuccess)
                    StackObserver.sharedInstance.likeCountChanged = true
                    
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
    
    func getAddressForLatLng(latitude: String, longitude: String, completionHandler: @escaping ((_ tipPlace: String, _ success: Bool) -> Void)) {
        let url = URL(string: "\(Constants.Config.GeoCodeString)latlng=\(latitude),\(longitude)")
        
        let request: URLRequest = URLRequest(url:url!)
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if(error != nil) {
                
                print(error?.localizedDescription)
                completionHandler("", false)
                
            } else {
                
                let kStatus = "status"
                let kOK = "ok"
                let kZeroResults = "ZERO_RESULTS"
                let kAPILimit = "OVER_QUERY_LIMIT"
                let kRequestDenied = "REQUEST_DENIED"
                let kInvalidRequest = "INVALID_REQUEST"
                let kInvalidInput =  "Invalid Input"
                
                //let dataAsString: NSString? = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                
                let jsonResult: NSDictionary = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                
                var status = jsonResult.value(forKey: kStatus) as! NSString
                status = status.lowercased as NSString
                
                if(status.isEqual(to: kOK)) {
                    
                    let address = AddressParser()
                    
                    address.parseGoogleLocationData(jsonResult)
                    
                    let addressDict = address.getAddressDictionary()
                    //     let placemark:CLPlacemark = address.getPlacemark()
                    
                    
                    
                    if let placeId = addressDict["placeId"] as? String {
                        
                        DispatchQueue.main.async {
                            
                            GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (place, err) -> Void in
                                if let error = error {
                                    print("lookup place id query error: \(error.localizedDescription)")
                                    return
                                }
                                
                                if let place = place {
                                    
                                    
                                    if !place.name.isEmpty {
                                        print(place.name)
                                        completionHandler(place.name, true)
                                    }
                                    else {
                                        if let address = addressDict["formattedAddess"] as? String {
                                            completionHandler(address, true)
                                        }
                                    }
                                    
                                    
                                } else {
                                    print("No place details for \(placeId)")
                                    if let address = addressDict["formattedAddess"] as? String {
                                        completionHandler(address, true)
                                    }
                                }
                            })
                            
                        }
                    }
                    
                }
                else if(!status.isEqual(to: kZeroResults) && !status.isEqual(to: kAPILimit) && !status.isEqual(to: kRequestDenied) && !status.isEqual(to: kInvalidRequest)){
                    
                    completionHandler("", false)
                    
                }
                    
                else {
                    
                    //status = (status.componentsSeparatedByString("_") as NSArray).componentsJoinedByString(" ").capitalizedString
                    
                    completionHandler("", false)
                    
                }
                
            }
            
        })
        
        task.resume()
        
        
    }
    
    
    
    
    private class AddressParser: NSObject {
        
        fileprivate var latitude = NSString()
        fileprivate var longitude  = NSString()
        fileprivate var streetNumber = NSString()
        fileprivate var route = NSString()
        fileprivate var locality = NSString()
        fileprivate var subLocality = NSString()
        fileprivate var formattedAddress = NSString()
        fileprivate var administrativeArea = NSString()
        fileprivate var administrativeAreaCode = NSString()
        fileprivate var subAdministrativeArea = NSString()
        fileprivate var postalCode = NSString()
        fileprivate var country = NSString()
        fileprivate var subThoroughfare = NSString()
        fileprivate var thoroughfare = NSString()
        fileprivate var ISOcountryCode = NSString()
        fileprivate var state = NSString()
        fileprivate var placeId = NSString()
        
        
        override init(){
            
            super.init()
            
        }
        
        fileprivate func getAddressDictionary()-> NSDictionary {
            
            let addressDict = NSMutableDictionary()
            
            addressDict.setValue(latitude, forKey: "latitude")
            addressDict.setValue(longitude, forKey: "longitude")
            addressDict.setValue(streetNumber, forKey: "streetNumber")
            addressDict.setValue(locality, forKey: "locality")
            addressDict.setValue(subLocality, forKey: "subLocality")
            addressDict.setValue(administrativeArea, forKey: "administrativeArea")
            addressDict.setValue(postalCode, forKey: "postalCode")
            addressDict.setValue(country, forKey: "country")
            addressDict.setValue(formattedAddress, forKey: "formattedAddress")
            addressDict.setValue(placeId, forKey: "placeId")
            
            return addressDict
        }
        
        
        
        
        fileprivate func parseGoogleLocationData(_ resultDict:NSDictionary) {
            
            let locationDict = (resultDict.value(forKey: "results") as! NSArray).firstObject as! NSDictionary
            
            let formattedAddrs = locationDict.object(forKey: "formatted_address") as! NSString
            
            let geometry = locationDict.object(forKey: "geometry") as! NSDictionary
            let location = geometry.object(forKey: "location") as! NSDictionary
            let lat = location.object(forKey: "lat") as! Double
            let lng = location.object(forKey: "lng") as! Double
            let placeId = locationDict.object(forKey: "place_id") as! NSString
            
            self.latitude = lat.description as NSString
            self.longitude = lng.description as NSString
            self.placeId = placeId
            
            let addressComponents = locationDict.object(forKey: "address_components") as! NSArray
            
            self.subThoroughfare = component("street_number", inArray: addressComponents, ofType: "long_name")
            self.thoroughfare = component("route", inArray: addressComponents, ofType: "long_name")
            self.streetNumber = self.subThoroughfare
            self.locality = component("locality", inArray: addressComponents, ofType: "long_name")
            self.postalCode = component("postal_code", inArray: addressComponents, ofType: "long_name")
            self.route = component("route", inArray: addressComponents, ofType: "long_name")
            self.subLocality = component("subLocality", inArray: addressComponents, ofType: "long_name")
            self.administrativeArea = component("administrative_area_level_1", inArray: addressComponents, ofType: "long_name")
            self.administrativeAreaCode = component("administrative_area_level_1", inArray: addressComponents, ofType: "short_name")
            self.subAdministrativeArea = component("administrative_area_level_2", inArray: addressComponents, ofType: "long_name")
            self.country =  component("country", inArray: addressComponents, ofType: "long_name")
            self.ISOcountryCode =  component("country", inArray: addressComponents, ofType: "short_name")
            
            
            self.formattedAddress = formattedAddrs;
            
        }
        
        fileprivate func component(_ component:NSString,inArray:NSArray,ofType:NSString) -> NSString {
            let index = inArray.indexOfObject(passingTest:) {obj, idx, stop in
                
                let objDict:NSDictionary = obj as! NSDictionary
                let types:NSArray = objDict.object(forKey: "types") as! NSArray
                let type = types.firstObject as! NSString
                return type.isEqual(to: component as String)
            }
            
            if (index == NSNotFound){
                
                return ""
            }
            
            if (index >= inArray.count){
                return ""
            }
            
            let type = ((inArray.object(at: index) as! NSDictionary).value(forKey: ofType as String)!) as! NSString
            
            if (type.length > 0){
                
                return type
            }
            return ""
            
        }
        
        fileprivate func getPlacemark() -> CLPlacemark {
            
            var addressDict = [String : AnyObject]()
            
            let formattedAddressArray = self.formattedAddress.components(separatedBy: ", ") as Array
            
            let kSubAdministrativeArea = "SubAdministrativeArea"
            let kSubLocality           = "SubLocality"
            let kState                 = "State"
            let kStreet                = "Street"
            let kThoroughfare          = "Thoroughfare"
            let kFormattedAddressLines = "FormattedAddressLines"
            let kSubThoroughfare       = "SubThoroughfare"
            let kPostCodeExtension     = "PostCodeExtension"
            let kCity                  = "City"
            let kZIP                   = "ZIP"
            let kCountry               = "Country"
            let kCountryCode           = "CountryCode"
            let kPlaceId               = "PlaceId"
            
            addressDict[kSubAdministrativeArea] = self.subAdministrativeArea
            addressDict[kSubLocality] = self.subLocality as NSString
            addressDict[kState] = self.administrativeAreaCode
            
            addressDict[kStreet] = formattedAddressArray.first! as NSString
            addressDict[kThoroughfare] = self.thoroughfare
            addressDict[kFormattedAddressLines] = formattedAddressArray as AnyObject?
            addressDict[kSubThoroughfare] = self.subThoroughfare
            addressDict[kPostCodeExtension] = "" as AnyObject?
            addressDict[kCity] = self.locality
            
            addressDict[kZIP] = self.postalCode
            addressDict[kCountry] = self.country
            addressDict[kCountryCode] = self.ISOcountryCode
            addressDict[kPlaceId] = self.placeId
            
            let lat = self.latitude.doubleValue
            let lng = self.longitude.doubleValue
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict as [String : AnyObject]?)
            
            return (placemark as CLPlacemark)
            
            
        }
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
    
 
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        
        return 0.7
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
            tipView.reportContainer.isHidden = true
            tipView.returnContainer.isHidden = true
            
            
            if let tipPicUrl = tip.tipImageUrl {
                
                    if let url = URL(string: tipPicUrl) {
         
                        
                  //      let processor = ResizingImageProcessor(targetSize: CGSize(width: 450, height: 550), contentMode: .aspectFill)
                        tipView.tipImage.kf.setImage(with: url, placeholder: nil, options: [], progressBlock: { (receivedSize, totalSize) in
                            print("\(index): \(receivedSize)/\(totalSize)")
                            
                        }, completionHandler: { (image, error, cacheType, imageUrl) in
                            
                            if index == 0 {
                                self.deInitLoader()
                            }
                            
                           
                            tipView.tipImage.contentMode = .scaleAspectFill
                            tipView.tipImage.clipsToBounds = true
                        //    self.applyGradient(tipView: tipView)
                            
                            tipView.tipImageViewHeightConstraint.setMultiplier(multiplier: self.tipImageViewHeightConstraintMultiplier())
                            tipView.tipDescription?.attributedText = NSAttributedString(string: tip.description, attributes:attributes)
                            tipView.tipDescription.textColor = UIColor.primaryTextColor()
                            tipView.tipDescription.font = UIFont.systemFont(ofSize: 15)
                            tipView.tipDescription.textContainer.lineFragmentPadding = 0
                            
                            if let likes = tip.likes {
                                tipView.likes?.text = "\(likes)"
                                if likes == 1 {
                                    tipView.likesLabel.text = "Like"
                                }
                                else {
                                    tipView.likesLabel.text = "Likes"
                                }
                            }
                            
                            if let name = tip.userName {
                                let firstName = name.components(separatedBy: " ")
                                let formattedString = NSMutableAttributedString()
                                formattedString
                                    .normal("By ").bold(firstName[0])
                                tipView.userName.attributedText = formattedString
                           
                            
                            }
                            
                            
                            if let picUrl = tip.userPicUrl {
                                
                                let url = URL(string: picUrl)
                                tipView.userImage.kf.indicatorType = .activity
                                let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill)
                                tipView.userImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                                    print("\(index): \(receivedSize)/\(totalSize)")
                                    
                                }, completionHandler: { (image, error, cacheType, imageUrl) in
                                    
                                    tipView.userImage.layer.cornerRadius = tipView.userImage.frame.size.width / 2
                                    tipView.userImage.clipsToBounds = true
                                    tipView.userImage.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
                                    tipView.userImage.layer.borderWidth = 0.8
                                  //  tipView.bringSubview(toFront: tipView.userImage)
                                    
                                })
                                
                            }
                            
                            let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                            geo?.getLocationForKey(tip.key, withCallback: { (location, error) in
                                
                                if error == nil {
                                    
                                    if let lat = location?.coordinate.latitude {
                                        
                                        if let long = location?.coordinate.longitude {
                                            
                                            let latitudeText: String = "\(lat)"
                                            let longitudeText: String = "\(long)"
                                            
                                            self.getAddressForLatLng(latitude: latitudeText, longitude: longitudeText, completionHandler: { (placeName, success) in
                                            
                                                if success {
                                                tipView.placeName.text = placeName
                                                }
                                            
                                            })
                                            
                                            
                                          self.mapTasks.getDirections(latitudeText, originLong: longitudeText, destinationLat: LocationService.sharedInstance.currentLocation?.coordinate.latitude, destinationLong: LocationService.sharedInstance.currentLocation?.coordinate.longitude, travelMode: self.travelMode, completionHandler: { (status, success) in
                                            
                                            if success {
                                            
                                                let minutes = self.mapTasks.totalDurationInSeconds / 60
                                                tipView.walkingDistance.text = "\(minutes)"
                                                
                                                if minutes == 1 {
                                                    tipView.distanceLabel.text = "Min"
                                                }
                                                else {
                                                    tipView.distanceLabel.text = "Mins"
                                                }
                                                
                                                print("The total distance is: " + "\(self.mapTasks.totalDistanceInMeters)")
                                                
                                            
                                            }
                                            else {
                                                let alertController = UIAlertController()
                                                alertController.defaultAlert(title: Constants.Config.AppName, message: "Status: " + status)
                                            }
                                            
                                            
                                            
                                          })
                                            
                                    
                                        }
                                        
                                    }
                                    
                                    
                                }
                                else {
                                    
                                    print(error?.localizedDescription)
                                }
                                
                                
                            })
                            
                            tipView.distanceImage.isHidden = false
                            tipView.likeImage.isHidden = false
                            tipView.reportContainer.isHidden = false
                            tipView.returnContainer.isHidden = false
                            tipView.reportContainer.makeCircle()
                            tipView.returnContainer.makeCircle()
                            tipView.reportContainer.isUserInteractionEnabled = true
                            tipView.returnContainer.isUserInteractionEnabled = true
                            
                        })
                        
                    }
                
            }
            return tipView
            
        }
        return koloda
    }
    
}

