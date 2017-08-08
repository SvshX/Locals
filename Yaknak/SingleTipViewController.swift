//
//  SingleTipViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import GeoFire
import GoogleMaps
import GooglePlaces
import CoreLocation
import Firebase
import SwiftLocation


protocol TipEditDelegate: class {
    func editTip(_ tip: Tip)
}

class SingleTipViewController: UIViewController {
    
    var tip: Tip!
    let dataService = DataService()
    var style = NSMutableParagraphStyle()
    let geoTask = GeoTasks()
    var tipImage: UIImage!
    var img: UIImageView!
    var isFriend: Bool!
    var emptyView: UIView!
    var ai = UIActivityIndicatorView()
    var travelMode = TravelMode.Modes.walking
    var placesClient: GMSPlacesClient?
    weak var delegate: TipEditDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navVC = self.navigationController {
        navVC.navigationBar.isHidden = true
        }
        self.style.lineSpacing = 2
        self.placesClient = GMSPlacesClient.shared()
     //   setLoadingOverlay()
        self.setupView()
      //  showAnimate()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.removeAnimate()
    }
    
    
    @IBAction func moreTapped(_ sender: Any) {
        self.popUpMenu()
    }
    
    
    private func setLoadingOverlay() {
        LoadingOverlay.shared.showOverlay(view: self.topMostViewController().view)
        }
    
    
    private func setupView() {
        
      guard let singleTipView = Bundle.main.loadNibNamed("SingleTipView", owner: self, options: nil)![0] as? SingleTipView, let img = tipImage, let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
      
            if isFriend {
            singleTipView.moreButton.isHidden = true
            }
      
            self.emptyView = UIView(frame: CGRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            self.emptyView.backgroundColor = UIColor.white
                
               self.toggleUI(singleTipView, false)
      
                    if appDelegate.isReachable {
                        self.getLocationDetails(singleTipView, completion: { (placeName, success, showDistance) in
                            
                            if success {
                                
                                singleTipView.tipImage.image = img
                                
                              guard let likes = self.tip.likes, let desc = self.tip.description, let cat = self.tip.category else {return}
                              
                                    singleTipView.likes.text = "\(likes)"
                                    
                                    if likes == 1 {
                                        singleTipView.likeLabel.text = "Like"
                                    }
                                    else {
                                        singleTipView.likeLabel.text = "Likes"
                                    }
                                    
                                    let attributes = [NSParagraphStyleAttributeName : self.style]
                                    singleTipView.tipDescription?.attributedText = NSAttributedString(string: desc, attributes: attributes)
                                    singleTipView.tipDescription.textColor = UIColor.primaryText()
                                    singleTipView.tipDescription.font = UIFont.systemFont(ofSize: 15)
                                    singleTipView.tipDescription.textContainer.lineFragmentPadding = 0
                                    
                              
                                
                                if placeName != nil {
                                    singleTipView.placeName.text = placeName
                                }
                                else {
                                  
                                        if cat == "eat" {
                                            singleTipView.placeName.text = "An " + cat + " spot"
                                        }
                                        else {
                                            singleTipView.placeName.text = "A " + cat + " spot"
                                        }
                                    
                                }
                                
                                if showDistance {
                                    self.toggleUI(singleTipView, true)
                                }
                                else {
                                    self.hideDistance(singleTipView)
                                }
                                
                            }
                            
                            
                        })
                    }
          
    }
    
    
    private func getLocationDetails(_ view: SingleTipView, completion: @escaping ((_ placeName: String?, _ success: Bool, _ showDistance: Bool) -> Void)) {
      
      guard let placeId = self.tip.placeId else {return}
      
            if !placeId.isEmpty {
                
                DispatchQueue.main.async {
                    
                    self.placesClient?.lookUpPlaceID(placeId, callback: { (place, error) -> Void in
                      
                        if let error = error {
                            print("lookup place id query error: \(error.localizedDescription)")
                            completion(nil, true, false)
                        }
                        
                      guard let place = place else {return}
                      
                            if !place.name.isEmpty {
                            
                              guard let currLat = Location.lastLocation.last?.coordinate.latitude, let currLong = Location.lastLocation.last?.coordinate.longitude else {return}
                              
                                self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: place.coordinate.latitude, destinationLong: place.coordinate.longitude, travelMode: self.travelMode, completion: { (status, success) in
                                    
                                    if success {
                                        
                                        let minutes = self.geoTask.totalDurationInSeconds / 60
                                        if (minutes <= 60) {
                                            view.walkingDistance.text = "\(minutes)"
                                            
                                            if minutes == 1 {
                                                view.walkingLabel.text = "Min"
                                            }
                                            else {
                                                view.walkingLabel.text = "Mins"
                                            }
                                        }
                                        else {
                                            completion(place.name, true, false)
                                        }
                                        completion(place.name, true, true)
                                        
                                        print("The total distance is: " + "\(self.geoTask.totalDistanceInMeters)")
                                        
                                        
                                    }
                                    else {
                                        completion(place.name, true, false)
                                    }
                                    
                                })
                            }
                    })
                    
                }
                
            }
            else {
                
                let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                geo?.getLocationForKey(tip.key, withCallback: { (location, error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                      self.dismiss(animated: true, completion: nil)
                    }
                    else {
                      
                      
                      guard let lat = location?.coordinate.latitude, let long = location?.coordinate.longitude, let currLat = Location.lastLocation.last?.coordinate.latitude, let currLong = Location.lastLocation.last?.coordinate.longitude else {return}
                      
                              self.geoTask.getAddressFromCoordinates(latitude: lat, longitude: long, completion: { (placeName, success) in
                                
                                if success {
                                  
                                  self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: lat, destinationLong: long, travelMode: self.travelMode, completion: { (status, success) in
                                    
                                    if success {
                                      
                                      let minutes = self.geoTask.totalDurationInSeconds / 60
                                      if (minutes <= 60) {
                                        view.walkingDistance.text = "\(minutes)"
                                        
                                        if minutes == 1 {
                                          view.walkingLabel.text = "Min"
                                        }
                                        else {
                                          view.walkingLabel.text = "Mins"
                                        }
                                      }
                                      else {
                                        completion(placeName, true, false)
                                      }
                                      completion(placeName, true, true)
                                      
                                      print("The total distance is: " + "\(self.geoTask.totalDistanceInMeters)")
                                    }
                                    else {
                                      completion(placeName, true, false)
                                    }
                                    
                                  })
                                }
                                
                              })
                    }
                })
            }
    }
  
  
    private func toggleUI(_ view: SingleTipView, _ show: Bool) {
    
        if show {
            emptyView.isHidden = true
            emptyView.removeFromSuperview()
            view.tipImage.contentMode = .scaleAspectFill
            view.tipImage.clipsToBounds = true
            ai.stopAnimating()
            ai.removeFromSuperview()
        }
        else {
            emptyView.isHidden = false
            view.addSubview(emptyView)
            view.bringSubview(toFront: emptyView)
            ai = UIActivityIndicatorView(frame: emptyView.frame)
            emptyView.addSubview(ai)
            ai.activityIndicatorViewStyle =
                UIActivityIndicatorViewStyle.gray
            ai.center = CGPoint(UIScreen.main.bounds.width / 2, UIScreen.main.bounds.height / 2)
            ai.startAnimating()
          }
    
    }
    
    
    private func hideDistance(_ view: SingleTipView) {
        view.likeIconLeadingConstraint.constant = 20.0
        view.walkingIcon.removeFromSuperview()
        view.walkingLabel.removeFromSuperview()
        view.walkingDistance.removeFromSuperview()
        toggleUI(view, true)
    }
  
    
    func removeAnimate() {
        
        UIView.animate(withDuration: 0.15, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.view.alpha = 1.0
        }) { (finished) in
            if (finished) {
                self.dismiss(animated: true, completion: nil)
               // self.view.removeFromSuperview()
            }
        }
    }
    
    
    
    private func popUpMenu() {
        
      guard let tip = self.tip else {return}
      
            let editButtonTitle = "✏️ " + Constants.Notifications.EditTip
            let deleteButtonTitle = "❌  " + Constants.Notifications.DeleteTip
            
            let alertController = MyActionController(title: nil, message: nil, style: .ActionSheet)
            
            alertController.addButton(editButtonTitle, true) {
                self.delegate?.editTip(tip)
                self.removeAnimate()
                }
            
            alertController.addButton(deleteButtonTitle, true) {
                
                let message = "Are you sure you want to delete this tip?"
                let deleteAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                
                let messageMutableString = NSAttributedString(string: message, attributes: [
                    NSFontAttributeName : UIFont.systemFont(ofSize: 15),
                    NSForegroundColorAttributeName : UIColor.primaryText()
                    ])
                
                deleteAlert.setValue(messageMutableString, forKey: "attributedMessage")
              
                let defaultAction = UIAlertAction(title: "Delete", style: .default) { action in
                    
                      LoadingOverlay.shared.showOverlay(view: self.view)
                        self.deleteTip(tip, completionHandler: { (userId, success) in
                            
                            if success {
                                self.updateTotalTipsCount(userId, completionHandler: { success in
                                    
                                    if success {
                                        self.updateTotalLikes(tip)
                                    }
                                    
                                })
                            }
                            
                        })
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }
                defaultAction.setValue(UIColor.primary(), forKey: "titleTextColor")
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                cancel.setValue(UIColor.primaryText(), forKey: "titleTextColor")
                deleteAlert.addAction(defaultAction)
                deleteAlert.addAction(cancel)
                deleteAlert.preferredAction = defaultAction
                self.present(deleteAlert,animated: false, completion: nil)
            }
            
            alertController.cancelButtonTitle = "Cancel"
            alertController.touchingOutsideDismiss = true
            alertController.animated = false
            alertController.show()
        
    }
    
    
    func updateTotalLikes(_ tip: Tip) {
            
      guard let uid = tip.addedByUser, let key = tip.key else {return}
      
                self.dataService.USER_REF.child(uid).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                    
                    if var data = currentData.value as? [String : Any] {
                        var count = data["totalLikes"] as! Int
                        if let likeCount = tip.likes {
                        count -= likeCount
                        if count > 0 {
                        data["totalLikes"] = count
                        }
                        else {
                        data["totalLikes"] = 0
                        }
                        }
                        
                        currentData.value = data
                        
                        return TransactionResult.success(withValue: currentData)
                    }
                    return TransactionResult.success(withValue: currentData)
                    
                }) { (error, committed, snapshot) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    if committed {
                        LoadingOverlay.shared.hideOverlayView()
                      #if DEBUG
                        // do nothing
                      #else
                        Analytics.logEvent("tipDeleted", parameters: ["tipId" : key as NSObject, "category" : tip.category! as NSObject])
                      #endif
                      
                        
                        self.removeAnimate()
                    }
                }
      
    }
    
       
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    func tipImageHeightConstraintMultiplier() -> CGFloat {
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
    
    
    
    private func deleteTip(_ tip: Tip, completionHandler: @escaping ((_ userId: String, _ success: Bool) -> Void)) {
        
      guard let tipId = tip.key, let userId = tip.addedByUser, let category = tip.category  else {return}
      guard !tipId.isEmpty else {
                        completionHandler(userId, false)
                        return
                    }
                    
                    self.dataService.TIP_REF.child(tipId).removeValue { (error, ref) in
                        
                        if error == nil {
                            
                            self.dataService.CATEGORY_REF.child(category).child(tipId).removeValue(completionBlock: { (error, ref) in
                                
                                if error == nil {
                                    
                                self.dataService.USER_TIP_REF.child(userId).child(tipId).removeValue(completionBlock: { (error, ref) in
                                        
                                        if error == nil {
                                          
                                            self.dataService.GEO_TIP_REF.child(tipId).removeValue(completionBlock: { (error, ref) in
                                                
                                                if error == nil {
                                                    print("Tip successfully deleted...")
                                                    completionHandler(userId, true)
                                                }
                                            })
                                        }
                                    })
                                    
                                }
                                
                            })
                        }
                        else {
                            print("Tip could not be deleted...")
                            completionHandler(userId, false)
                        }
                        
                    }
    }
    

    
    
    private func updateTotalTipsCount(_ userId: String, completionHandler: @escaping ((_ success: Bool) -> Void)) {
      
        guard !userId.isEmpty else {
            completionHandler(false)
            return
        }
        
        self.dataService.USER_REF.child(userId).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            
            if var data = currentData.value as? [String : Any] {
                var count = data["totalTips"] as! Int
                
                if (count > 0) {
                count -= 1
                data["totalTips"] = count
                }
                
                currentData.value = data
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            if committed {
                completionHandler(true)
            }
        }
    }
 
}
