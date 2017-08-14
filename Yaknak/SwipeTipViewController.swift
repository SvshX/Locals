
//
//  SwipeTipViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import pop
import CoreLocation
import GoogleMaps
import GooglePlaces
import NVActivityIndicatorView
import MBProgressHUD
import Kingfisher
import FirebaseAnalytics
import SwiftLocation


private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1



class SwipeTipViewController: UIViewController, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {
    
    
    @IBOutlet weak var nearbyText: UIView!
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var addATipButton: UIButton!
    var tips: [Tip] = []
    var tip: Tip!
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
    var mapView: KolodaMapView!
    private var routePolyline: GMSPolyline!
    var tipCoordinates: CLLocationCoordinate2D!
    var userCoordinates: CLLocationCoordinate2D!
    var isLoaded: Bool = false
  
    var likesHaveChanged: Bool = false {
  
    didSet(oldValue) {
      if oldValue != likesHaveChanged && likesHaveChanged {
      getTips(fromCategory: StackObserver.shared.categorySelected)
      }
      }
      
  }
  
  
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
      setData()
      initKolodaView()
      initLayout()
      initLoader()
      getTips(fromCategory: StackObserver.shared.categorySelected)
      
      
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
                    strongSelf.getTips(fromCategory: categoryId)
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
        keys = tabC.updatedKeys
    }
  
  private func initKolodaView() {
  
    kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
    kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
    kolodaView.delegate = self
    kolodaView.dataSource = self
    kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
    initMapView()
  }
  
  
  
  func closeMap() {
    isLoaded = false
    likesHaveChanged = false
    mapView.mapView.clear()
    mapView.likeButton.setTitleColor(UIColor.primaryText(), for: UIControlState.normal)
    mapView.likeButton.backgroundColor = UIColor.white
    mapView.likeButton.setTitle("Liked", for: .normal)
    mapView.likeButton.isEnabled = true
    mapView.removeFromSuperview()
    if kolodaView.subviews.count <= 1 {
    kolodaView.resetCurrentCardIndex()
    }
  }
  
  func unlikeTip() {
  
    let tip = self.tips[currentTipIndex]
    self.dataService.removeTipFromList(tip: tip) { (success, error) in
      
      if success {
        print(Constants.Logs.TipDecrementSuccess)
        self.likesHaveChanged = true
        self.showSuccessInUI(tip)
      }
      else {
        if let error = error {
          print(error.localizedDescription)
        }
      }
    }
  }
  
  private func initLayout() {
  
    modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    style.lineSpacing = 2
    placesClient = GMSPlacesClient.shared()
    nearbyText.isHidden = true
    let tapRec = UITapGestureRecognizer(target: self, action: #selector(addATipButtonTapped(_:)))
    tapRec.delegate = self
    addATipButton.addGestureRecognizer(tapRec)
    addATipButton.isUserInteractionEnabled = true
  }
  
  
  private func initMapView() {
  
    mapView = Bundle.main.loadNibNamed("KolodaMapView", owner: self, options: nil)![0] as? KolodaMapView
    mapView.closeButton.addTarget(self, action: #selector(closeMap), for: .touchUpInside)
    mapView.likeButton.addTarget(self, action: #selector(unlikeTip), for: .touchUpInside)
    mapView.likeButton.setTitleColor(UIColor.primaryText(), for: UIControlState.normal)
    mapView.likeButton.addTopBorder(color: UIColor.tertiary(), width: 1.0)
    mapView.likes.textColor = UIColor.primaryText()
    mapView.likesLabel.textColor = UIColor.secondaryText()
    mapView.durationLabel.textColor = UIColor.secondaryText()
    mapView.duration.textColor = UIColor.primaryText()
  //  mapView.mapView.delegate = self
    mapView.mapView.isMyLocationEnabled = true
    mapView.mapView.settings.myLocationButton = true
    mapView.mapView.settings.compassButton = true
  }
  
  
    private func initLoader() {
      
      hideNoTipsAround()
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let size = screenWidth
        let frame = CGRect(x: (size
            / 2) - (size / 2), y: (size
                / 2) - (size / 2), width: size
                    / 4, height: screenWidth / 4)
        
        loader = UIActivityIndicatorView(frame: frame)
        loader.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.gray
        loader.center = CGPoint(size / 2 , screenHeight / 2)
        loader.tag = 200
        view.addSubview(loader)
        loader.startAnimating()
        
        NSLayoutConstraint(item: self.loader, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.loader, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        
    }
    
    
    func deInitLoader() {
        loader.stopAnimating()
        loader.removeFromSuperview()
    }
    
    
    func showNoTipsAround() {
        print(Constants.Logs.OutOfRange)
        DispatchQueue.main.async(execute: {
            self.deInitLoader()
            self.nearbyText.isHidden = false
            self.displayCirclePulse()
            //  self.showHoofAnimation()
        })
    }
    
    
    private func hideNoTipsAround() {
      
      nearbyText.isHidden = true
        for subView in self.view.subviews {
            if (subView.tag == 100) {
                subView.removeFromSuperview()
            }
        }
    }
  
  
  private func showSuccessInUI(_ tip: Tip) {
    
    guard let key = tip.key else {return}
    
    self.dataService.getTip(key, completion: { (tip) in
      
      guard let likes = tip.likes else {return}
      
      DispatchQueue.main.async {
        
        if likes == 1 {
          self.mapView.likesLabel.text = "like"
        }
        else {
          self.mapView.likesLabel.text = "likes"
        }
        self.mapView.likes.text = "\(likes)"
        self.mapView.likeButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.mapView.likeButton.backgroundColor = UIColor.primary()
        self.mapView.likeButton.setTitle("Unliked", for: .normal)
        self.mapView.likeButton.isEnabled = false
        
        let alertController = UIAlertController()
        alertController.defaultAlert(nil, Constants.Notifications.UnlikeTipMessage)
      }
    })
    
  }
  
  
    func updateStack() {
      
      if kolodaView.subviews.last == mapView {
      updateMapDetails()
      }
      else {
        setData()
        kolodaView.removeStack()
        initLoader()
        getTips(fromCategory: StackObserver.shared.categorySelected)
      }
    }
  
  
    func reloadStack() {
      
        kolodaView.removeStack()
        initLoader()
        getTips(fromCategory: StackObserver.shared.categorySelected)
        UserDefaults.standard.removeObject(forKey: "likeCountChanged")
    }
    
    
    func retainStack() {
      
        kolodaView.reloadData()
        UserDefaults.standard.removeObject(forKey: "likeCountChanged")
    }
    
    
    func configureNavBar() {
        
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        navLogo.contentMode = .scaleAspectFit
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        navigationItem.titleView = navLogo
        navigationItem.setHidesBackButton(true, animated: false)
    }
  
    
    
    @IBAction func moreTapped(_ sender: Any) {
      
        currentTip = tips[self.currentTipIndex]
        if let screenshot = self.captureScreenshot() {
            popUpMenu(screenshot)
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
        
      guard let tip = self.currentTip else {return}
      
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
  
  
  
  func initMapDetails(forTip tip: Tip, completion: @escaping (() -> ())) {
    
    guard let urlString = tip.userPicUrl else {return}
    
    let url = URL(string: urlString)
    
    let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100))
    self.mapView.userPic.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
      
      print("\(receivedSize)/\(totalSize)")
      
    }, completionHandler: { (image, error, cacheType, imageUrl) in
      
       guard let likes = tip.likes else {return}
      
       self.mapView.likes.text = "\(likes)"
      if likes == 1 {
        self.mapView.likesLabel.text = "like"
      }
        
      else {
        self.mapView.likesLabel.text = "likes"
      }
      completion()
      
    })
  }
  
  
    private func getTips(fromCategory id: Int) {
      
        self.tips.removeAll()
    
        if id != 10 {
            self.category = Constants.HomeView.Categories[id]
          
            if keys.count > 0 {
                self.dataService.getCategoryTips(keys, self.category.lowercased(), completion: { (success, tips) in
                    
                    if success {
                        self.tips = tips.reversed()
                        print("\(self.tips.count) tips are being displayed...")
                        DispatchQueue.main.async {
                            self.deInitLoader()
                            self.kolodaView.reloadData()
                        }
                    }
                    else {
                        self.showNoTipsAround()
                    }
                })
            }
            else {
                    self.showNoTipsAround()
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
                    }
                    
                })
                
            }
            else {
                    self.showNoTipsAround()
            }
        }
    
    }
  
    
    
    func tipImageViewHeightConstraintMultiplier() -> CGFloat {
        
        switch Utils.screenHeight() {
            
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
  
  
  func calculateRoute(forTip tip: Tip, completion: @escaping (() -> ())) {
    
    guard let key = tip.key else {return}
    self.dataService.getTipLocation(key, completion: { (location, error) in
      
      if let error = error {
        print(error.localizedDescription)
        return
      }
      else {
        guard let lat = location?.coordinate.latitude, let long = location?.coordinate.longitude else {return}
        self.tipCoordinates = CLLocationCoordinate2DMake(lat, long)
        self.loadMap(tip, completion: {
          completion()
        })
      }
    })
  }
  
  
  func loadMap(_ tip: Tip, completion: @escaping (() -> ())) {
    
    self.geoTask.getDirections(tipCoordinates.latitude, originLong: tipCoordinates.longitude, destinationLat: userCoordinates.latitude, destinationLong: userCoordinates.longitude, travelMode: self.travelMode, completion: { (status, success) in
      
      if success {
        self.drawMap(for: tip)
        completion()
      }
        
      else {
        if status == "OVER_QUERY_LIMIT" {
          sleep(2)
          self.geoTask.getDirections(self.tipCoordinates.latitude, originLong: self.tipCoordinates.longitude, destinationLat: self.userCoordinates.latitude, destinationLong: self.userCoordinates.longitude, travelMode: self.travelMode, completion: { (status, success) in
            
            if success {
              self.drawMap(for: tip)
              completion()
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
  
  
  func drawMap(for tip: Tip) {
    
    mapView.mapView.clear()
    
    let minutes = self.geoTask.totalDurationInSeconds / 60
    
    mapView.duration.text = "\(minutes)"
    
    if minutes == 1 {
      mapView.durationLabel.text = "min"
    }
    else {
      mapView.durationLabel.text = "mins"
    }
    
    let marker = GMSMarker(position: self.geoTask.originCoordinate)
    marker.title = Constants.Notifications.InfoWindow
    guard let category = tip.category, let image = UIImage(named: category + "-marker") else {return}
    self.drawRoute(with: category)
    marker.icon = image
    marker.map = mapView.mapView
  }
  
  
  func drawRoute(with category: String) {
    
    let route = geoTask.overviewPolyline["points"] as! String
    let path: GMSPath = GMSPath(fromEncodedPath: route)!
    routePolyline = GMSPolyline(path: path)
    routePolyline.strokeColor = UIColor.routeColor(with: category)
    routePolyline.strokeWidth = 10.0
    routePolyline.geodesic = true
    routePolyline.map = mapView.mapView
  }
  
  
   func updateMapDetails() {
    
    guard let location = Location.lastLocation.last else {return}
    if self.hasMovedSignificantly(toNewLocation: location) {
      self.userCoordinates = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
      self.loadMap(tip, completion: {
        // do nothing
      })
    }
  }
  
  
   func hasMovedSignificantly(toNewLocation location: CLLocation) -> Bool {
    
    let newLoc = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let oldLoc = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
    let distance: CLLocationDistance = newLoc.distance(from: oldLoc)
    return distance >= 20
  }

  
     func openMap(for tip: Tip) {

        DispatchQueue.main.async {
            let mapViewController = MapViewController()
            mapViewController.data = tip
            mapViewController.modalPresentationStyle = .fullScreen
            mapViewController.transitioningDelegate = self
            self.present(mapViewController, animated: true, completion: nil)
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
    
    
    func createTipView(_ view: CustomTipView, tip: Tip, completion: @escaping ((_ placeName: String?, _ minutes: UInt?, _ meters: UInt?, _ success: Bool) -> Void)) {
        
        self.createGeoDetails(view, tip, completion: { (placeName, minutes, meters, success) in
          
            if success {
                
              guard let picUrl = tip.userPicUrl else {return}
              
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
                        
                        
                      guard let tipPicUrl = tip.tipImageUrl, let url = URL(string: tipPicUrl) else {return}
                      
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
                                    view.tipDescription.textColor = UIColor.primaryText()
                                    view.tipDescription.font = UIFont.systemFont(ofSize: 15)
                                    view.tipDescription.textContainer.lineFragmentPadding = 0
                                    
                                  guard let likes = tip.likes, let name = tip.userName else {return}
                                        view.likes?.text = "\(likes)"
                                        if likes == 1 {
                                            view.likesLabel.text = "like"
                                        }
                                        else {
                                            view.likesLabel.text = "likes"
                                        }
                                    
                                        let firstName = name.components(separatedBy: " ")
                                        let formattedString = NSMutableAttributedString()
                                        formattedString
                                            .normal("By ").bold(firstName[0])
                                        view.userName.attributedText = formattedString
                                  
                                    completion(placeName, minutes, meters, true)
                                    
                                })
                          })
            }
        })
        
        
    }
    
    
    func createGeoDetails(_ view: CustomTipView, _ tip: Tip, completion: @escaping ((_ placeName: String?, _ minutes: UInt?, _ meters: UInt?, _ success: Bool) -> Void)) {
      
      guard let placeId = tip.placeId else {return}
      
            if !placeId.isEmpty {
                
                DispatchQueue.main.async {
                    
                    self.placesClient?.lookUpPlaceID(placeId, callback: { (place, error) -> Void in
                        if let error = error {
                            print("lookup place id query error: \(error.localizedDescription)")
                            completion(nil, nil, nil, true)
                        }
                        
                      guard let place = place else {return}
                      
                            if !place.name.isEmpty {
                                
                              guard let currLat = Location.lastLocation.last?.coordinate.latitude, let currLong = Location.lastLocation.last?.coordinate.longitude else {return}
                              
                                        self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: place.coordinate.latitude, destinationLong: place.coordinate.longitude, travelMode: self.travelMode, completion: { (status, success) in
                                            
                                            if success {
                                                let minutes = self.geoTask.totalDurationInSeconds / 60
                                                view.walkingDistance.text = "\(minutes)"
                                                let meters = self.geoTask.totalDistanceInMeters
                                                
                                                if minutes == 1 {
                                                    view.distanceLabel.text = "min"
                                                }
                                                else {
                                                    view.distanceLabel.text = "mins"
                                                }
                                                
                                                completion(place.name, minutes, meters, true)
                                            }
                                            else {
                                                
                                                if status == "OVER_QUERY_LIMIT" {
                                                    sleep(2)
                                                    self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: place.coordinate.latitude, destinationLong: place.coordinate.longitude, travelMode: self.travelMode, completion: { (status, success) in
                                                        
                                                        if success {
                                                            let minutes = self.geoTask.totalDurationInSeconds / 60
                                                            let meters = self.geoTask.totalDistanceInMeters
                                                            view.walkingDistance.text = "\(minutes)"
                                                            
                                                            if minutes == 1 {
                                                                view.distanceLabel.text = "min"
                                                            }
                                                            else {
                                                                view.distanceLabel.text = "mins"
                                                            }
                                                            
                                                            completion(place.name, minutes, meters, true)
                                                            
                                                        }
                                                        
                                                    })
                                                }
                                                else {
                                                    completion(nil, nil, nil, true)
                                                }
                                                
                                            }
                                            
                                        })
                            }
                          
                    })
                    
                }
                
                
            }
                
            else {
              guard let key = tip.key else {return}
              
                self.dataService.getTipLocation(key, completion: { (location, error) in
               
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    else {
                      
                      guard let lat = location?.coordinate.latitude, let long = location?.coordinate.longitude, let currLat = Location.lastLocation.last?.coordinate.latitude, let currLong = Location.lastLocation.last?.coordinate.longitude else {return}
                      
                              self.geoTask.getAddressFromCoordinates(latitude: lat, longitude: long, completion: { (placeName, success) in
                                
                                if success {
                                  view.placeName.text = placeName
                                  
                                  self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: lat, destinationLong: long, travelMode: self.travelMode, completion: { (status, success) in
                                    
                                    if success {
                                      let minutes = self.geoTask.totalDurationInSeconds / 60
                                      view.walkingDistance.text = "\(minutes)"
                                      let meters = self.geoTask.totalDistanceInMeters
                                      
                                      if minutes == 1 {
                                        view.distanceLabel.text = "min"
                                      }
                                      else {
                                        view.distanceLabel.text = "mins"
                                      }
                                      
                                      completion(placeName, minutes, meters, true)
                                    }
                                    else {
                                      
                                      if status == "OVER_QUERY_LIMIT" {
                                        sleep(2)
                                        self.geoTask.getDirections(lat, originLong: long, destinationLat: Location.lastLocation.last?.coordinate.latitude, destinationLong: Location.lastLocation.last?.coordinate.longitude, travelMode: self.travelMode, completion: { (status, success) in
                                          
                                          if success {
                                            let minutes = self.geoTask.totalDurationInSeconds / 60
                                            let meters = self.geoTask.totalDistanceInMeters
                                            view.walkingDistance.text = "\(minutes)"
                                            
                                            if minutes == 1 {
                                              view.distanceLabel.text = "min"
                                            }
                                            else {
                                              view.distanceLabel.text = "mins"
                                            }
                                            
                                            completion(placeName, minutes, meters, true)
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
                })
            }
    }
  
}


//MARK: KolodaViewDelegate

extension SwipeTipViewController: KolodaViewDelegate {
  
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
      if kolodaView.subviews.last != mapView {
        kolodaView.resetCurrentCardIndex()
      }
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
  
  
  
  func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
    
    let currentTip = tips[index]
    self.currentTipIndex = index
    
    if (direction == .right) {
      
      #if DEBUG
        // do nothing
      #else
        Analytics.logEvent("tipLiked", parameters: ["category" : currentTip.category as NSObject, "addedByUser" : currentTip.userName as NSObject])
      #endif
      
      
      self.dataService.doSwipeRight(for: currentTip, completion: { (success, update, error) in
        
        if let error = error {
          print(error.localizedDescription)
        }
        else {
          
          if update {
            print(Constants.Logs.TipIncrementSuccess)
            self.likesHaveChanged = true
            
            guard let likes = currentTip.likes else {return}
            var likeCount = likes
            likeCount += 1
            self.mapView.likes.text = "\(likeCount)"
            if likeCount == 1 {
              self.mapView.likesLabel.text = "like"
            }
            else {
              self.mapView.likesLabel.text = "likes"
            }
          }
          else {
            print(Constants.Logs.TipAlreadyLiked)
            self.likesHaveChanged = false
          }
          
          self.likesHaveChanged = false
          }
      })
      
    }
      
    else if (direction == .left) {
      print(Constants.Logs.SwipedLeft)
      #if DEBUG
        // do nothing
      #else
        Analytics.logEvent("tipPassed", parameters: ["category" : currentTip.category as NSObject, "addedByUser" : currentTip.userName as NSObject])
      #endif
      
    }
    
    return true
  }
  
  
  func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection, atIndex index: Int) {
    
    if direction == .right {
      
      //   koloda.subviews[2].alpha = 0
      
      if finishPercentage > 10.0 {
        mapView.alpha = finishPercentage / 100
        
        if finishPercentage > 30.0 && !isLoaded {
          
          let tip = tips[index]
          self.initMapDetails(forTip: tip, completion: { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.calculateRoute(forTip: tip, completion: {
              strongSelf.isLoaded = true
              strongSelf.tip = tip
            })
          })
        }
        if finishPercentage == 100.0 && kolodaView.subviews.last != mapView {
          kolodaView.bringSubview(toFront: mapView)
        }
        
      }
    }
    else {
      for subView in kolodaView.subviews {
        if subView == mapView {
          subView.alpha = 0
          //  subView.removeFromSuperview()
        }
      }
    }
    
  }
  
  
  func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
    
      mapView.alpha = 0
      mapView.tag = 100
      kolodaView.addSubview(mapView)
      kolodaView.sendSubview(toBack: mapView)
      mapView.fillSuperview()
      guard let currentLocation = Location.lastLocation.last, let coordinates = Location.lastLocation.last?.coordinate else {return true}
      userCoordinates = coordinates
      mapView.setCameraPosition(atLocation: currentLocation)
    
    return true
  }
  
  
  
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
      
      
    }
    
}



extension SwipeTipViewController: KolodaViewDataSource {
    
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return self.tips.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
      
      guard let tipView = Bundle.main.loadNibNamed(Constants.NibNames.TipView, owner: self, options: nil)![0] as? CustomTipView else {return koloda}
      
            let tip = self.tips[index]
      
            self.toggleUI(tipView, false)
      
            self.createTipView(tipView, tip: tip, completion: { (placeName, minutes, meters, success) in
                
                if success {
                    
                    if placeName != nil {
                        tipView.placeName.text = placeName
                    }
                    else {
                      guard let cat = tip.category else {return}
                            if cat == "eat" {
                                tipView.placeName.text = "An eat spot"
                            }
                            else {
                                tipView.placeName.text = "A " + cat + " spot"
                            }
                    }
                    
                    if minutes != nil {
                      guard let min = minutes, let distance = meters else {return}
                            print("The total distance is: " + "\(distance)")
                                
                                tipView.walkingDistance.text = "\(min)"
                                
                                if min == 1 {
                                    tipView.distanceLabel.text = "min"
                                }
                                else {
                                    tipView.distanceLabel.text = "mins"
                                }
                    }
                    else {
                        if SettingsManager.shared.defaultWalkingDuration <= 15 {
                            tipView.walkingDistance.text = "<15"
                        }
                        else {
                            tipView.walkingDistance.text = ">15"
                        }
                        tipView.distanceLabel.text = "mins"
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
    
}


extension SwipeTipViewController: EnableLocationDelegate {
    
    func onButtonTapped() {
        Utils.redirectToSettings()
    }

}

