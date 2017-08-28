
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



class SwipeTipViewController: UIViewController, UIGestureRecognizerDelegate {
  
  
  private struct Category {
  
    var section: Int!
    var row: Int!
  }
  
  @IBOutlet weak var nearbyText: UIView!
  @IBOutlet weak var kolodaView: CustomKolodaView!
  @IBOutlet weak var addATipButton: UIButton!
  
  var tips: [Tip] = []
  var tip: Tip!
  var style = NSMutableParagraphStyle()
  var miles = Double()
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
  private var routePolyline: GMSPolyline!
  var tipCoordinates: CLLocationCoordinate2D!
  var userCoordinates: CLLocationCoordinate2D!
  var category: (section: Int, row: Int) = (0, 0)
  var tipData: [TipData] = []
  
  var likesHaveChanged: Bool = false {
    
    didSet(oldValue) {
      if oldValue != likesHaveChanged && likesHaveChanged {
        getTips()
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
    initLayout()
    
    guard let tabC = tabBarController as? TabBarController else {return}
    tabC.onCategorySelected = { [weak self] section, row in
      guard let strongSelf = self, let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
      
      strongSelf.category = (section, row)
      if appDelegate.isReachable {
        strongSelf.kolodaView.removeStack()
        strongSelf.getTips()
      }
    }
  }
  
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if kolodaView.subviews.last is KolodaMapView {
    kolodaView.removeMap()
    }
  }
  
  
  private func setData() {
    guard let tabC = tabBarController as? TabBarController else {return}
    keys = tabC.updatedKeys
  }
  
  
  
  private func initObserver() {
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(updateStack),
                                           name: NSNotification.Name(rawValue: "reloadTipStack"),
                                           object: nil)
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
    initKolodaView()
    initObserver()
  }
  
  
  private func initKolodaView() {
    
    kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
    kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
    kolodaView.delegate = self
    kolodaView.dataSource = self
    kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
  }
  
  
  private func initLoader() {
    
    hideNoTipsAround()
    
    if loader == nil {
    loader = UIActivityIndicatorView()
    loader.activityIndicatorViewStyle =
      UIActivityIndicatorViewStyle.gray
    loader.tag = 200
    }
    view.addSubview(loader)
    
    loader.anchorCenterSuperview()
    loader.startAnimating()
    
  }
  
  
  func deInitLoader() {
    
    if loader != nil && loader.isAnimating {
      DispatchQueue.main.async {
    self.loader.stopAnimating()
    self.loader.removeFromSuperview()
      }
    }
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
  
  
   func showSuccessInUI(_ tip: Tip) {
    
    guard let key = tip.key else {return}
    
    self.dataService.getTip(key, completion: { (tip) in
      
      guard let likes = tip.likes else {return}
      
      DispatchQueue.main.async {
        
        if likes == 1 {
          self.kolodaView.map.likesLabel.text = "like"
        }
        else {
          self.kolodaView.map.likesLabel.text = "likes"
        }
        self.kolodaView.map.likes.text = "\(likes)"
        self.kolodaView.map.likeButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.kolodaView.map.likeButton.backgroundColor = UIColor.primary()
        self.kolodaView.map.likeButton.setTitle("Unliked", for: .normal)
        self.kolodaView.map.likeButton.isEnabled = false
        
        let alertController = UIAlertController()
        alertController.defaultAlert(nil, Constants.Notifications.UnlikeTipMessage)
      }
    })
    
  }
  
  
  func updateStack() {
    
    if kolodaView.subviews.last == kolodaView.map {
      updateMapDetails()
    }
    else {
      setData()
      kolodaView.removeStack()
      getTips()
    }
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
    self.kolodaView.map.userPic.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
      
      print("\(receivedSize)/\(totalSize)")
      
    }, completionHandler: { (image, error, cacheType, imageUrl) in
      
      guard let likes = tip.likes else {return}
      
      self.kolodaView.map.likes.text = "\(likes)"
      if likes == 1 {
        self.kolodaView.map.likesLabel.text = "like"
      }
        
      else {
        self.kolodaView.map.likesLabel.text = "likes"
      }
      completion()
      
    })
  }
  
  
  private func getTips() {
    
    initLoader()
    
    if keys.count > 0 {
      print("Number of keys: \(keys.count)")
      self.tips.removeAll()
      
      switch category.0 {
      case 0:
        getAllTips()
        break
      case 1:
        getCategoryTips()
        break
      default:
        break
      }
      
      
    }
    else {
    self.showNoTipsAround()
    }
    
    
    
    
    
  }
  
  
  
  private func getAllTips() {
    
    self.dataService.getAllTips(keys, completion: { (success, tips) in
        
        if success {
          self.tips = tips.reversed()
          DispatchQueue.main.async {
            self.kolodaView.reloadData()
          }
        }
        else {
          self.showNoTipsAround()
        }
        
      })
  }
  
  
  private func getCategoryTips() {
    
      self.dataService.getCategoryTips(keys, Constants.HomeView.Categories[category.1].lowercased(), completion: { (success, tips) in
        
        if success {
          self.tips = tips.reversed()
          print("\(self.tips.count) tips are being displayed...")
          DispatchQueue.main.async {
            self.kolodaView.reloadData()
          }
        }
        else {
          self.showNoTipsAround()
        }
      })
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
  
  
 
  
  func getDirection(_ tip: Tip, completion: @escaping (() -> ())) {
    
    self.geoTask.getDirections(tipCoordinates.latitude, originLong: tipCoordinates.longitude, destinationLat: userCoordinates.latitude, destinationLong: userCoordinates.longitude, travelMode: self.travelMode, completion: { (status, success) in
      
      if success {
        completion()
      }
        
      else {
        if status == "OVER_QUERY_LIMIT" {
          sleep(2)
          self.geoTask.getDirections(self.tipCoordinates.latitude, originLong: self.tipCoordinates.longitude, destinationLat: self.userCoordinates.latitude, destinationLong: self.userCoordinates.longitude, travelMode: self.travelMode, completion: { (status, success) in
            
            if success {
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
  

  
  func updateMapDetails() {
    
    guard let location = Location.lastLocation.last else {return}
      self.userCoordinates = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
    // TODO
      self.getDirection(tip, completion: {
        // do nothing
      })
  }
  
  
   private func initMap() {
  
    kolodaView.map.alpha = 0
    guard let topView = kolodaView.subviews.last else {return}
    kolodaView.insertSubview(kolodaView.map, belowSubview: topView)
    kolodaView.map.fillSuperview()
  }
  
  
}


//MARK: KolodaViewDelegate

extension SwipeTipViewController: KolodaViewDelegate {
  
  func kolodaDidRunOutOfCards(_ koloda: KolodaView) {

      koloda.resetCurrentCardIndex()
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
  
  
  
  func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection, atIndex index: Int) {
    
    DispatchQueue.main.async {
      self.kolodaView.map.update(progress: finishPercentage, direction: direction)
    }
  }
  
  
  
  func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
    
    currentTipIndex = index
    deInitLoader()
  }
  
  
  
  func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
    return true
  }
  
  
  func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
    
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
            self.kolodaView.map.likes.text = "\(likeCount)"
            if likeCount == 1 {
              self.kolodaView.map.likesLabel.text = "like"
            }
            else {
              self.kolodaView.map.likesLabel.text = "likes"
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
  }
  
  
  func koloda(_ koloda: KolodaView, addMapDetailsAt index: Int) {
    
      koloda.map.likeButton.setTitleColor(UIColor.primaryText(), for: UIControlState.normal)
      koloda.map.likeButton.backgroundColor = UIColor.white
      koloda.map.likeButton.setTitle("Liked", for: .normal)
      koloda.map.likeButton.isEnabled = true
      
      guard let tip = TipBuilder.shared.tipData[index], let currentLocation = Location.lastLocation.last, let coordinates = Location.lastLocation.last?.coordinate else {return}
      koloda.map.drawMapDetails(for: tip)
      userCoordinates = coordinates
      koloda.map.setCameraPosition(atLocation: currentLocation)
      koloda.mapDetailsAdded = true
  }
  
  
  func koloda(_ koloda: KolodaView, closeMapAt index: Int) {
    
      koloda.mapDetailsAdded = false
      likesHaveChanged = false
      koloda.delegate?.koloda(koloda, addMapDetailsAt: index)
  }
  
  
  func koloda(_ koloda: KolodaView, unlikeTipAt index: Int) {
      
      let tip = self.tips[index]
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
   
    tipView.isHidden = true
    
 
    TipBuilder.setup(tip: tip, mode: self.travelMode, index: index)
    TipBuilder.shared.buildTip { (tipData, _, error) in
      
      if let error = error {
      print(error.localizedDescription)
      }
      else {
      
        guard let data = tipData, let tip = data.tip, let description = tip.description, let picUrl = tip.userPicUrl else {return}
        
        let url = URL(string: picUrl)
        tipView.userImage.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100), mode: .aspectFill)
        tipView.userImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
          print("Progress: \(receivedSize)/\(totalSize)")
          
        }, completionHandler: { (image, error, cacheType, imageUrl) in
          
          if (image == nil) {
            tipView.userImage.image = UIImage(named: Constants.Images.ProfilePlaceHolder)
          }
          tipView.userImage.layer.cornerRadius = tipView.userImage.frame.size.width / 2
          tipView.userImage.clipsToBounds = true
          tipView.userImage.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
          tipView.userImage.layer.borderWidth = 0.8
          
          
          guard let tipPicUrl = tip.tipImageUrl, let url = URL(string: tipPicUrl) else {return}
          
          let attributes = [NSParagraphStyleAttributeName : self.style]
          
          tipView.tipImage.kf.setImage(with: url, placeholder: nil, options: [], progressBlock: { (receivedSize, totalSize) in
            print("Progress: \(receivedSize)/\(totalSize)")
            
          }, completionHandler: { (image, error, cacheType, imageUrl) in
            
            if (image == nil) {
              tipView.tipImage.image = UIImage(named: Constants.Images.TipImagePlaceHolder)
            }
            
            tipView.tipImage.contentMode = .scaleAspectFill
            tipView.tipImage.clipsToBounds = true
            tipView.tipDescription.attributedText = NSAttributedString(string: description, attributes:attributes)
            tipView.tipDescription.textColor = UIColor.primaryText()
            tipView.tipDescription.font = UIFont.systemFont(ofSize: 15)
            tipView.tipDescription.textContainer.lineFragmentPadding = 0
            
            guard let likes = tip.likes, let name = tip.userName else {return}
            tipView.likes.text = "\(likes)"
            if likes == 1 {
              tipView.likesLabel.text = "like"
            }
            else {
              tipView.likesLabel.text = "likes"
            }
            
            let firstName = name.components(separatedBy: " ")
            let formattedString = NSMutableAttributedString()
            formattedString
              .normal("By ").bold(firstName[0])
            tipView.userName.attributedText = formattedString
            
            if data.placeName != nil {
              tipView.placeName.text = data.placeName
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
            
            if data.minutes != nil {
              guard let mins = data.minutes, let distance = data.meters else {return}
              
              print("The total distance is: " + "\(distance)")
              
              tipView.walkingDistance.text = "\(mins)"
              
              if mins == 1 {
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
            
         tipView.isHidden = false
            })
          })
       
      }
    }
    return tipView
  }
  
  
}


extension SwipeTipViewController: EnableLocationDelegate {
  
  func onButtonTapped() {
    Utils.redirectToSettings()
  }
  
}

