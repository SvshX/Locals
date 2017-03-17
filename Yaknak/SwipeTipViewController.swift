
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


// private let numberOfCards: UInt = 5
private let frameAnimationSpringBounciness:CGFloat = 9
private let frameAnimationSpringSpeed:CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent:CGFloat = 0.1


class SwipeTipViewController: UIViewController, PXGoogleDirectionsDelegate {
    
    
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
     //   LocationService.sharedInstance.delegate = self
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.style.lineSpacing = 2
        self.catRef = self.dataService.CATEGORY_REF
        self.tipRef = self.dataService.TIP_REF
     //   StackObserver.sharedInstance.likeCountChanged = false
        
        setupReachability(nil, useClosures: true)
        startNotifier()
        self.nearbyText.isHidden = true
        tapRec.addTarget(self, action: #selector(SwipeTipViewController.addATipButtonTapped))
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
    
    
    
    func applyGradient(tipView: CustomTipView) {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor.clear.withAlphaComponent(0.5), UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black
            .withAlphaComponent(0.9).cgColor, UIColor.black.cgColor]
        gradient.locations = [0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.7, 0.8, 0.85, 0.9]
        
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
            tipView.by.isHidden = true
            tipView.contentMode = UIViewContentMode.scaleAspectFill
            
            if let tipPicUrl = tip.tipImageUrl {
                
                    if let url = URL(string: tipPicUrl) {
         
                        
                        tipView.tipImage.kf.setImage(with: url, placeholder: nil, options: [], progressBlock: { (receivedSize, totalSize) in
                            print("\(index): \(receivedSize)/\(totalSize)")
                            
                        }, completionHandler: { (image, error, cacheType, imageUrl) in
                            
                            if index == 0 {
                                self.deInitLoader()
                            }
                            
                            
                            self.applyGradient(tipView: tipView)
                            
                            tipView.tipViewHeightConstraint.constant = self.tipViewHeightConstraintConstant()
                            tipView.tipDescription?.attributedText = NSAttributedString(string: tip.description, attributes:attributes)
                            tipView.tipDescription.textColor = UIColor.white
                            tipView.tipDescription.font = UIFont.systemFont(ofSize: 15)
                            
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
                                tipView.userName.text = name
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
                                                    
                                                    switch response {
                                                    case let .error(_, error):
                                                        let alertController = UIAlertController()
                                                        alertController.defaultAlert(title: Constants.Config.AppName, message: "Error: \(error.localizedDescription)")
                                                    case let .success(request, routes):
                                                        self.request = request
                                                        self.result = routes
                                                        
                                                        let totalDuration: TimeInterval = self.result[self.routeIndex].totalDuration
                                                        //   let ti = NSInteger(totalDuration)
                                                        //   let minutes = (ti / 60) % 60
                                                        let minutes = LocationService.sharedInstance.minutesFromTimeInterval(interval: totalDuration)
                                                        
                                                        tipView.walkingDistance.text = "\(minutes)"
                                                        
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
                
            }
            return tipView
            
        }
        return koloda
    }
    
}

