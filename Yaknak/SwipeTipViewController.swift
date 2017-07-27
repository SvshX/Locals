
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
import MBProgressHUD
import Kingfisher
import FirebaseAnalytics
import SwiftLocation


// private let numberOfCards: UInt = 5
private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1



class SwipeTipViewController: UIViewController, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {
    
    
    @IBOutlet weak var nearbyText: UIView!
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var addATipButton: UIButton!
    var tips = [Tip]()
    var style = NSMutableParagraphStyle()
    var miles = Double()
    var category = String()
    var loader: UIActivityIndicatorView!
    var currentTipIndex = Int()
    var currentTip: Tip!
    let dataService = DataService()
    let tapRec = UITapGestureRecognizer()
    private var loadingLabel: UILabel!
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    var placesClient: GMSPlacesClient?
    let screenSize: CGRect = UIScreen.main.bounds
    let xStartPoint: CGFloat = 40.0
    var xOffset: CGFloat = 0.0
    let geoTask = GeoTasks()
    var travelMode = TravelMode.Modes.walking
    private var keys: [String]!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     //   self.configureNavBar()
        setData()
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        style.lineSpacing = 2
        placesClient = GMSPlacesClient.shared()
        nearbyText.isHidden = true
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(self.addATipButtonTapped(_:)))
        tapRec.delegate = self
        
        
        addATipButton.addGestureRecognizer(tapRec)
        addATipButton.isUserInteractionEnabled = true
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateStack),
                                               name: NSNotification.Name(rawValue: "reloadTipStack"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(retainStack),
                                               name: NSNotification.Name(rawValue: "retainStack"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadStack),
                                               name: NSNotification.Name(rawValue: "reloadStack"),
                                               object: nil)
        
        
      
        
        StackObserver.shared.onCategorySelected = { [weak self] categoryId in
          
          guard let strongSelf = self, let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
          
                if appDelegate.isReachable {
                    strongSelf.kolodaView.removeStack()
                    strongSelf.initLoader()
                    strongSelf.getTips(categoryId)
                }
        }
        
        
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if appDelegate.isReachable {
                    
                    self.initLoader()
                    self.getTips(StackObserver.shared.categorySelected)
                }
            }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    private func setData() {
        guard let tabC = tabBarController as? TabBarController else {return}
        self.keys = tabC.updatedKeys
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
        
        self.loader = UIActivityIndicatorView(frame: frame)
        self.loader.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.gray
        self.loader.center = CGPoint(size / 2 , screenHeight / 2)
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
    
    
    func showNoTipsAround() {
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
    
    
    func updateStack() {
        self.setData()
        self.kolodaView.removeStack()
        self.initLoader()
        self.getTips(StackObserver.shared.categorySelected)
    }
    
    
    func reloadStack() {
        self.kolodaView.removeStack()
        self.initLoader()
        self.getTips(StackObserver.shared.categorySelected)
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
    
    
    func popUpPrompt() {
        let alertController = UIAlertController()
        alertController.networkAlert(Constants.NetworkConnection.NetworkPromptMessage)
    }
    
    
    
    @IBAction func moreTapped(_ sender: Any) {
        self.currentTip = tips[self.currentTipIndex]
        if let screenshot = self.captureScreenshot() {
            self.popUpMenu(screenshot)
        }
        self.currentTipIndex = self.kolodaView.returnCurrentTipIndex()
    }
    
    
    
    private func captureScreenshot() -> UIImage? {
        
        let bounds = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        self.view.drawHierarchy(in: bounds, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
        
    }
    
    
    private func popUpMenu(_ img: UIImage) {
        
        if let tip = self.currentTip {
            
            let shareTitle = "🎉 " + Constants.Notifications.Share
            let previousTitle = "👈🏼 " + Constants.Notifications.PreviousTip
            let reportTipTitle = "🛎 " + Constants.Notifications.ReportTip
            let reportUserTitle = "🙄 " + Constants.Notifications.ReportUser
            
            let alertController = MyActionController(title: nil, message: nil, style: .ActionSheet)
            
            var previousEnabled = true
            if (self.kolodaView.currentCardIndex == 0) {
                previousEnabled = false
            }
            alertController.addButton(previousTitle, previousEnabled) {
                self.kolodaView.revertAction()
            }
            
            alertController.addButton(shareTitle, true) {
                self.showSharePopUp(tip, img)
            }
            
            alertController.addButton(reportTipTitle, true) {
                self.showReportVC(tip)
            }
            
            alertController.addButton(reportUserTitle, true) {
                self.showReportUserVC(tip)
            }
            
            alertController.cancelButtonTitle = "Cancel"
            
            alertController.touchingOutsideDismiss = true
            alertController.animated = false
            alertController.show()
        }
        
    }
    
    
    
    private func showSharePopUp(_ tip: Tip, _ img: UIImage) {
        
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [ .addToReadingList, .copyToPasteboard,UIActivityType.saveToCameraRoll, .print, .assignToContact, .mail, .openInIBooks, .postToTencentWeibo, .postToVimeo, .postToWeibo]
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    
    
    private func showReportVC(_ tip: Tip) {
        
        let storyboard = UIStoryboard(name: "Report", bundle: Bundle.main)
        
        let previewVC = storyboard.instantiateViewController(withIdentifier: "NavReportVC") as! UINavigationController
        previewVC.definesPresentationContext = true
        previewVC.modalPresentationStyle = .overCurrentContext
        
        let reportVC = previewVC.viewControllers.first as! ReportViewController
        reportVC.data = tip
        self.show(previewVC, sender: nil)
    }
    
    
    private func showReportUserVC(_ tip: Tip) {
        
        let storyboard = UIStoryboard(name: "ReportUser", bundle: Bundle.main)
        
        let previewVC = storyboard.instantiateViewController(withIdentifier: "NavReportUserVC") as! UINavigationController
        previewVC.definesPresentationContext = true
        previewVC.modalPresentationStyle = .overCurrentContext
        
        let reportVC = previewVC.viewControllers.first as! ReportUserViewController
        reportVC.data = tip
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
    
    
    private func getTips(_ id: Int) {
        
        self.tips.removeAll()
      //  guard let keys = self.geofence.keys else {return}
    
        if id != 10 {
            self.category = Constants.HomeView.Categories[id]
            
            if keys.count > 0 {
                self.dataService.getCategoryTips(keys, self.category.lowercased(), completion: { (success, tips) in
                    
                    if success {
                        self.tips = tips.reversed()
                        print("\(self.tips.count) Tips will be displayed...")
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
        }
        else {
            if keys.count > 0 {
                print("Number of keys: \(keys.count)")
                
                self.dataService.getAllTips(keys, completion: { (success, tips) in
                    
                    if success {
                        self.tips = tips.reversed()
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
        }
    
    }
    
 
    
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    
    func tipImageViewHeightConstraintMultiplier() -> CGFloat {
        
        switch self.screenHeight() {
            
        case 480:
            return 0.50
            
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
    
    
    func addATipButtonTapped(_ sender: UIGestureRecognizer) {
        guard let tabC = tabBarController else {return}
        tabC.selectedIndex = 4
    }
    
    
    private func displayCirclePulse() {
        
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let size = screenWidth
        let frame = CGRect(x: (screenWidth / 2) - (size / 2), y: (screenHeight / 2) - (size / 2), width: size, height: size)
        let circlePulse = NVActivityIndicatorView(frame: frame, type: .ballScaleMultiple, color: UIColor(red: 227/255, green: 19/255, blue: 63/255, alpha: 1), padding: 10)
        circlePulse.alpha = 0.1
        circlePulse.tag = 100
        circlePulse.isUserInteractionEnabled = false
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
    
    
     func openMap(_ currentTip: Tip) {
        
        DispatchQueue.main.async {
            let mapViewController = MapViewController()
            mapViewController.data = currentTip
            mapViewController.modalPresentationStyle = .fullScreen
            mapViewController.transitioningDelegate = self
            self.present(mapViewController, animated: true, completion: {})
            self.kolodaView.revertAction()
        }
    }
    
    
    
    func toggleUI(_ view: CustomTipView, _ visible: Bool) {
        
        if visible {
            view.isHidden = false
        }
        else {
            view.isHidden = true
        }
        
    }
    
    
    func createTipView(_ view: CustomTipView, tip: Tip, completionHandler: @escaping ((_ placeName: String?, _ minutes: UInt?, _ meters: UInt?, _ success: Bool) -> Void)) {
        
        self.createGeoDetails(view, tip, completionHandler: { (placeName, minutes, meters, success) in
            if success {
                
                if let picUrl = tip.userPicUrl {
                    
                    let url = URL(string: picUrl)
                    view.userImage.kf.indicatorType = .activity
                    let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100), mode: .aspectFill)
                    view.userImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                        print("Progress: \(receivedSize)/\(totalSize)")
                        
                    }, completionHandler: { (image, error, cacheType, imageUrl) in
                        
                        if (image == nil) {
                            view.userImage.image = UIImage(named: Constants.Images.ProfilePlaceHolder)
                        }
                        view.userImage.layer.cornerRadius = view.userImage.frame.size.width / 2
                        view.userImage.clipsToBounds = true
                        view.userImage.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
                        view.userImage.layer.borderWidth = 0.8
                        
                        
                        if let tipPicUrl = tip.tipImageUrl {
                            
                            if let url = URL(string: tipPicUrl) {
                                
                                let attributes = [NSParagraphStyleAttributeName : self.style]
                                
                                view.tipImage.kf.setImage(with: url, placeholder: nil, options: [], progressBlock: { (receivedSize, totalSize) in
                                    print("Progress: \(receivedSize)/\(totalSize)")
                                    
                                }, completionHandler: { (image, error, cacheType, imageUrl) in
                                    
                                    if (image == nil) {
                                        view.tipImage.image = UIImage(named: Constants.Images.TipImagePlaceHolder)
                                    }
                                    
                                    view.tipImage.contentMode = .scaleAspectFill
                                    view.tipImage.clipsToBounds = true
                                    view.tipDescription?.attributedText = NSAttributedString(string: tip.description, attributes:attributes)
                                    view.tipDescription.textColor = UIColor.primaryTextColor()
                                    view.tipDescription.font = UIFont.systemFont(ofSize: 15)
                                    view.tipDescription.textContainer.lineFragmentPadding = 0
                                    
                                    if let likes = tip.likes {
                                        view.likes?.text = "\(likes)"
                                        if likes == 1 {
                                            view.likesLabel.text = "Like"
                                        }
                                        else {
                                            view.likesLabel.text = "Likes"
                                        }
                                    }
                                    
                                    if let name = tip.userName {
                                        let firstName = name.components(separatedBy: " ")
                                        let formattedString = NSMutableAttributedString()
                                        formattedString
                                            .normal("By ").bold(firstName[0])
                                        view.userName.attributedText = formattedString
                                    }
                                    
                                    completionHandler(placeName, minutes, meters, true)
                                    
                                })
                                
                            }
                        }
                        
                    })
                    
                }
                
                
                
            }
        })
        
        
    }
    
    
    func createGeoDetails(_ view: CustomTipView, _ tip: Tip, completionHandler: @escaping ((_ placeName: String?, _ minutes: UInt?, _ meters: UInt?, _ success: Bool) -> Void)) {
        
        
        if let placeId = tip.placeId {
            
            if !placeId.isEmpty {
                
                DispatchQueue.main.async {
                    
                    self.placesClient?.lookUpPlaceID(placeId, callback: { (place, error) -> Void in
                        if let error = error {
                            print("lookup place id query error: \(error.localizedDescription)")
                            completionHandler(nil, nil, nil, true)
                        }
                        
                        if let place = place {
                            
                            if !place.name.isEmpty {
                                
                                if let currLat = Location.lastLocation.last?.coordinate.latitude {
                                    if let currLong = Location.lastLocation.last?.coordinate.longitude {
                                        self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: place.coordinate.latitude, destinationLong: place.coordinate.longitude, travelMode: self.travelMode, completionHandler: { (status, success) in
                                            
                                            if success {
                                                let minutes = self.geoTask.totalDurationInSeconds / 60
                                                view.walkingDistance.text = "\(minutes)"
                                                let meters = self.geoTask.totalDistanceInMeters
                                                
                                                if minutes == 1 {
                                                    view.distanceLabel.text = "Min"
                                                }
                                                else {
                                                    view.distanceLabel.text = "Mins"
                                                }
                                                
                                                completionHandler(place.name, minutes, meters, true)
                                            }
                                            else {
                                                
                                                if status == "OVER_QUERY_LIMIT" {
                                                    sleep(2)
                                                    self.geoTask.getDirections(place.coordinate.latitude, originLong: place.coordinate.longitude, destinationLat: Location.lastLocation.last?.coordinate.latitude, destinationLong: Location.lastLocation.last?.coordinate.longitude, travelMode: self.travelMode, completionHandler: { (status, success) in
                                                        
                                                        if success {
                                                            let minutes = self.geoTask.totalDurationInSeconds / 60
                                                            let meters = self.geoTask.totalDistanceInMeters
                                                            view.walkingDistance.text = "\(minutes)"
                                                            
                                                            if minutes == 1 {
                                                                view.distanceLabel.text = "Min"
                                                            }
                                                            else {
                                                                view.distanceLabel.text = "Mins"
                                                            }
                                                            
                                                            completionHandler(place.name, minutes, meters, true)
                                                            
                                                        }
                                                        
                                                    })
                                                }
                                                else {
                                                    completionHandler(nil, nil, nil, true)
                                                }
                                                
                                            }
                                            
                                        })
                                    }
                                }
                            }
                            
                        } else {
                            print("No place details for \(placeId)")
                        }
                    })
                    
                }
                
                
            }
                
            else {
                if let key = tip.key {
                
                self.dataService.getTipLocation(key, completion: { (location, error) in
               
                    if error == nil {
                        
                        if let lat = location?.coordinate.latitude {
                            if let long = location?.coordinate.longitude {
                                if let currLat = Location.lastLocation.last?.coordinate.latitude {
                                    if let currLong = Location.lastLocation.last?.coordinate.longitude {
                                        self.geoTask.getAddressFromCoordinates(latitude: lat, longitude: long, completionHandler: { (placeName, success) in
                                            
                                            if success {
                                                view.placeName.text = placeName
                                                
                                                self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: lat, destinationLong: long, travelMode: self.travelMode, completionHandler: { (status, success) in
                                                    
                                                    if success {
                                                        let minutes = self.geoTask.totalDurationInSeconds / 60
                                                        view.walkingDistance.text = "\(minutes)"
                                                        let meters = self.geoTask.totalDistanceInMeters
                                                        
                                                        if minutes == 1 {
                                                            view.distanceLabel.text = "Min"
                                                        }
                                                        else {
                                                            view.distanceLabel.text = "Mins"
                                                        }
                                                        
                                                        completionHandler(placeName, minutes, meters, true)
                                                    }
                                                    else {
                                                        
                                                        if status == "OVER_QUERY_LIMIT" {
                                                            sleep(2)
                                                            self.geoTask.getDirections(lat, originLong: long, destinationLat: Location.lastLocation.last?.coordinate.latitude, destinationLong: Location.lastLocation.last?.coordinate.longitude, travelMode: self.travelMode, completionHandler: { (status, success) in
                                                                
                                                                if success {
                                                                    let minutes = self.geoTask.totalDurationInSeconds / 60
                                                                    let meters = self.geoTask.totalDistanceInMeters
                                                                    view.walkingDistance.text = "\(minutes)"
                                                                    
                                                                    if minutes == 1 {
                                                                        view.distanceLabel.text = "Min"
                                                                    }
                                                                    else {
                                                                        view.distanceLabel.text = "Mins"
                                                                    }
                                                                    
                                                                    completionHandler(placeName, minutes, meters, true)
                                                                }
                                                                
                                                            })
                                                        }
                                                        else {
                                                            
                                                            let alertController = UIAlertController()
                                                            alertController.defaultAlert(nil, "Error: " + status)
                                                        }
                                                        
                                                    }
                                                    
                                                })
                                                
                                            }
                                            
                                        })
                                        
                                    }
                                }
                            }
                        }
                        
                        
                    }
                    else {
                        if let err = error {
                        print(err.localizedDescription)
                        }
                        
                    }
                })
            }
            }
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
            
             Analytics.logEvent("tipLiked", parameters: ["category" : currentTip.category as NSObject, "addedByUser" : currentTip.userName as NSObject])
            
            self.dataService.handleLikeCount(currentTip, completion: { (success, update, error) in
                
                if let err = error {
                print(err.localizedDescription)
                }
                else {
                    guard let key = currentTip.key else {return}
                    self.dataService.getTip(key, completion: { (tip) in
                         self.openMap(tip)
                    })
               
                    if update {
                        print(Constants.Logs.TipIncrementSuccess)
                        StackObserver.shared.likeCountChanged = true
                    }
                    else {
                        // Bug: stack starts from the beginning
                        StackObserver.shared.likeCountChanged = false
                        print(Constants.Logs.TipAlreadyLiked)
                    }
                }
            })
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
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        
        if let tipView = Bundle.main.loadNibNamed(Constants.NibNames.TipView, owner: self, options: nil)![0] as? CustomTipView {
            
            let tip = self.tips[index]
            
            self.toggleUI(tipView, false)
            
            
            self.createTipView(tipView, tip: tip, completionHandler: { (placeName, minutes, meters, success) in
                
                if success {
                    
                    if placeName != nil {
                        tipView.placeName.text = placeName
                    }
                    else {
                        if let cat = tip.category {
                            if cat == "eat" {
                                tipView.placeName.text = "An " + cat + " spot"
                            }
                            else {
                                tipView.placeName.text = "A " + cat + " spot"
                            }
                        }
                    }
                    
                    if minutes != nil {
                        if let min = minutes {
                            if let distance = meters {
                                print("The total distance is: " + "\(distance)")
                                
                                tipView.walkingDistance.text = "\(min)"
                                
                                if min == 1 {
                                    tipView.distanceLabel.text = "Min"
                                }
                                else {
                                    tipView.distanceLabel.text = "Mins"
                                }
                                
                            }
                        }
                    }
                    else {
                        if SettingsManager.shared.defaultWalkingDuration <= 15 {
                            tipView.walkingDistance.text = "<15"
                        }
                        else {
                            tipView.walkingDistance.text = ">15"
                        }
                        tipView.distanceLabel.text = "Mins"
                    }
                    
                    /*
                    if index == 0 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            if appDelegate.firstLaunch.isFirstLaunch && appDelegate.firstLaunch.isFirsPrompt {
                                tipView.showToolTip()
                                appDelegate.firstLaunch.setWasShownBefore()
                            }
                        }
                        
                    }
                    else
                      */
                        if index == 1 {
                        self.deInitLoader()
                    }
                    self.toggleUI(tipView, true)
                }
            })
            
            return tipView
            
        }
        return koloda
    }
    
   /*
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        
        return Bundle.main.loadNibNamed("MapOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
 */
    
}


extension SwipeTipViewController: EnableLocationDelegate {
    
    func onButtonTapped() {
        Utils.redirectToSettings()
    }

}

