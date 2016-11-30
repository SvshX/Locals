//
//  MapViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 16/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import CoreLocation
import PXGoogleDirections
import GoogleMaps
import GeoFire
import ReachabilitySwift


class MapViewController: UIViewController {

   
    @IBOutlet weak var detailView: UIStackView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var unlikeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesNumber: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationNumber: UILabel!
    @IBOutlet weak var middleView: UIView!
  
    
    var data: Tip?
    var request: PXGoogleDirections!
    var result: [PXGoogleDirectionsRoute]!
    var routeIndex: Int = 0
    let locationManager = CLLocationManager()
    var reachability: Reachability?
    let tapRec = UITapGestureRecognizer()
    let dataService = DataService()
    
    var directionsAPI: PXGoogleDirections {
        return (UIApplication.shared.delegate as! AppDelegate).directionsAPI
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //    self.addressLabel.isHidden = true
        self.configureNavBar()
        self.userProfileImage.image = UIImage(named: "icon-square")
        self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
        self.userProfileImage.clipsToBounds = true
        self.configureDetailView()
        self.configureUnlikeButton()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.mapView.delegate = self
        self.directionsAPI.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func configureUnlikeButton() {
        
    //    self.unlikeButton.layer.borderWidth = 1
    //    self.unlikeButton.layer.cornerRadius = 5
    //    self.unlikeButton.layer.borderColor = UIColor.secondaryTextColor().cgColor
        self.unlikeButton.setTitleColor(UIColor.white, for: UIControlState.normal)
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
    
    
    
    //MARK: - Actions
    
  
    @IBAction func cancelButtonTapped(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func unlikeButtonTapped(_ sender: Any) {
     //   unlikeTip(data: data!)
        self.unlikeButton.setTitleColor(UIColor.primaryTextColor(), for: UIControlState.normal)
        self.unlikeButton.backgroundColor = UIColor.white
        self.unlikeButton.setTitle("I don't recommend this tip", for: .normal)
        self.unlikeButton.isEnabled = false
        
    }
   /*
    @IBAction func unlikeButtonTapped(sender: AnyObject) {
        unlikeTip(data: data!)
        self.unlikeButton.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0), for: UIControlState.normal)
        self.unlikeButton.backgroundColor = UIColor(red: 227/255, green: 19/255, blue: 63/255, alpha: 1.0)
        self.unlikeButton.layer.borderColor = UIColor(red: 227/255, green: 19/255, blue: 63/255, alpha: 1.0).cgColor
        self.unlikeButton.isEnabled = false
        
    }
    */
    
 /*
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                self.addressLabel.unlock()
                
                let lines = address.lines as! [String]
                self.addressLabel.text = lines.joinWithSeparator("\n")
                
                //      let labelHeight = self.addressLabel.intrinsicContentSize().height
                //       self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0,
                //           bottom: labelHeight, right: 0)
                
                UIView.animateWithDuration(0.25) {
                    //        self.pinImageVerticalConstraint.constant = ((labelHeight - self.topLayoutGuide.length) * 0.5)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    */
    /*
    func unlikeTip(data: Tip) {
        
        StackObserver.sharedInstance.likeCountValue = 2
        self.getCurrentUser(data: data)
        
    }
    
   
    private func getCurrentUser(data: Tip) {
        
        let userQuery = User.query()
        //  userQuery?.whereKey("objectId", equalTo: (User.currentUser()?.objectId)!)
        //  userQuery?.whereKey("tipsLiked", containsString: data.objectId)
        userQuery?.getObjectInBackgroundWithId((User.currentUser()?.objectId)!, block: { (object: PFObject?, error: NSError?) in
            
            if (error == nil) {
                
                if let object = object {
                    
                    
                    self.decrementCurrentTip(data)
                    object.removeObject(data.objectId!, forKey: "tipsLiked")
                    object.saveInBackground()
                    
                }
                
            }
                
            else
            {
                //  NSLog(Constants.Logs.UserRequestFailed)
            }
            
        })
        
    }
    
    
    private func decrementCurrentTip(data: Tip) {
        
        let query = Tip.query()
        query?.getObjectInBackgroundWithId(data.objectId!, block: { (object: PFObject?, error: NSError?) in
            
            if (error == nil) {
                
                if let object = object {
                    
                    self.decrementCategoryTip(data)
                    print(Constants.Logs.TipRequestSuccess)
                    object.incrementKey("likes", byAmount: -1)
                    object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                        
                        if (success) {
                            
                            data.likes -= 1
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                if data.likes == 1 {
                                    self.likesLabel.text = "Like"
                                }
                                else {
                                    self.likesLabel.text = "Likes"
                                }
                                self.likesNumber.text = String(data.likes)
                                self.likesNumber.textColor = UIColor.primaryTextColor()
                                self.likesLabel.textColor = UIColor.secondaryTextColor()
                                
                                
                                let alertVC = UIAlertController(
                                    title: "",
                                    message: Constants.Notifications.UnlikeTipMessage,
                                    preferredStyle: .Alert)
                                let okAction = UIAlertAction(
                                    title: Constants.Notifications.AlertConfirmation,
                                    style:.Default,
                                    handler: nil)
                                alertVC.addAction(okAction)
                                self.presentViewController(alertVC,
                                                           animated: true,
                                                           completion: nil)
                                
                            }
                            
                            print(Constants.Logs.TipDecrementSuccess)
                            
                        }
                            
                        else {
                            print(Constants.Logs.SavingError)
                        }
                        
                    })
                }
            }
                
            else if let error = error
                
            {
                self.showErrorView(error)
            }
            
        })
        
        
    }
    
    private func decrementCategoryTip(currentTip: Tip) {
        
        let query = PFQuery(className: "Category")
        let pointer = PFObject(withoutDataWithClassName: "Tip", objectId: currentTip.objectId)
        query.whereKey("tip", equalTo: pointer)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if (error == nil) {
                if let objects = objects {
                    
                    for object in objects {
                        object.incrementKey("like", byAmount: -1)
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
    
    */
    
    func configureNavBar() {
        
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        navLogo.contentMode = .scaleAspectFit
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        self.navigationItem.titleView = navLogo
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
   
    private func configureDetailView() {
        
    //    self.view.layoutIfNeeded()
        
        self.detailView.backgroundColor = UIColor.white
        self.middleView.backgroundColor = UIColor.white
        //   self.detailView.layer.cornerRadius = 5
        //   self.detailView.layer.shadowOpacity = 0.7
        //   self.detailView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        //   self.detailView.layer.shadowColor = UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1).CGColor
        self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
        self.userProfileImage.clipsToBounds = true
        
        if let url = data?.getUserPicUrl() {
        self.userProfileImage.loadImageUsingCacheWithUrlString(urlString: url)
        }
        
        if data?.getLikes() == 1 {
            
            if let likes = data?.getLikes() {
                
                self.likesNumber.text = String(likes)
                self.likesLabel.text = "Like"
                
            }
            
        }
            
        else {
            
            if let likes = data?.getLikes() {
                
                self.likesNumber.text = String(likes)
                self.likesLabel.text = "Likes"
                
            }
            
            self.likesNumber.textColor = UIColor.primaryTextColor()
            self.likesLabel.textColor = UIColor.secondaryTextColor()
            
        }
        
        //   self.likesLabel.font = UIFont(name: Constants.Fonts.HelvLight, size: 16.0)
        //    self.unlikeButton.titleLabel?.font = UIFont(name: Constants.Fonts.HelvBold, size: 16.0)
        //    self.unlikeButton.layer.cornerRadius = 3
        //    self.unlikeButton.setTitleColor(UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1.0), forState: UIControlState.Normal)
        
    }
    
    
}


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.settings.compassButton = true
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            let userLat = location.coordinate.latitude
            let userLong = location.coordinate.longitude
            
            let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
            geo?.getLocationForKey(data?.getKey(), withCallback: { (location, error) in
                
                if error == nil {
                
                    if let lat = location?.coordinate.latitude {
                    
                        if let long = location?.coordinate.longitude {
                        
                        
                            self.directionsAPI.from = PXLocation.coordinateLocation(CLLocationCoordinate2DMake(userLat, userLong))
                            self.directionsAPI.to = PXLocation.coordinateLocation(CLLocationCoordinate2DMake(lat, long))
                            self.directionsAPI.mode = PXGoogleDirectionsMode.walking
                            
                            self.directionsAPI.calculateDirections { (response) -> Void in
                                DispatchQueue.main.async(execute: {
                                    
                                    switch response {
                                    case let .error(_, error):
                                        let alert = UIAlertController(title: Constants.Config.AppName, message: "Error: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: Constants.Notifications.AlertConfirmation, style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    case let .success(request, routes):
                                        
                                        self.request = request
                                        self.result = routes
                                        
                                        for i in 0 ..< (self.result).count {
                                            if i != self.routeIndex {
                                                self.result[i].drawOnMap(self.mapView, strokeColor: UIColor.blue, strokeWidth: 3.0)
                                                
                                            }
                                            
                                        }
                                        
                                        let totalDuration: TimeInterval = self.result[self.routeIndex].totalDuration
                                        let ti = NSInteger(totalDuration)
                                        let minutes = (ti / 60) % 60
                                        
                                        //     let totalDistance: CLLocationDistance = self.result[self.routeIndex].totalDistance
                                        
                                        //    self.distanceLabel.text = String(totalDistance) + " m"
                                        //    self.distanceLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
                                        self.durationNumber.text = String(minutes)
                                        
                                        if totalDuration == 1 {
                                            self.durationLabel.text = "Min"
                                        }
                                        else {
                                            self.durationLabel.text = "Mins"
                                        }
                                        
                                        self.durationLabel.textColor = UIColor.secondaryTextColor()
                                        self.durationNumber.textColor = UIColor.primaryTextColor()
                                        self.result[self.routeIndex].drawOnMap(self.mapView, strokeColor: UIColor(red: 57/255, green: 148/255, blue: 228/255, alpha: 1), strokeWidth: 4.0)
                                        //      self.presentViewController(rvc, animated: true, completion: nil)
                                        //            }
                                    }
                                })
                            }
                            
                            let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
                            
                            let marker = GMSMarker()
                            marker.position = coordinates
                            marker.title = Constants.Notifications.InfoWindow
                            marker.icon = GMSMarker.markerImage(with: UIColor(red: 227/255, green: 19/255, blue: 63/255, alpha: 1))
                            
                            marker.map = self.mapView
                        
                        
                        
                        }
                    
                    }
                    
                }
                else {
                print(error?.localizedDescription)
                }
                
                
                
                
                
                
            })
            
            
            locationManager.stopUpdatingLocation()
        }
        
    }
    
}


// MARK: - GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
       // reverseGeocodeCoordinate(position.target)
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
      //  addressLabel.lock()
    }
    
    //  func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
    // 1
    //     let index:Int! = Int(marker.accessibilityLabel!)
    // 2
    //    let customInfoWindow = NSBundle.mainBundle().loadNibNamed("CustomInfoWindow", owner: self, options: nil)[0] as! CustomInfoWindow
    //     customInfoWindow.architectLbl.text = architectNames[index]
    //     customInfoWindow.completedYearLbl.text = completedYear[index]
    //    return customInfoWindow
    //   }
    
}


extension MapViewController: PXGoogleDirectionsDelegate {
    
    func googleDirectionsWillSendRequestToAPI(_ googleDirections: PXGoogleDirections, withURL requestURL: URL) -> Bool {
        //   NSLog(Constants.Logs.WillSendRequestToAPI)
        return true
    }
    
    func googleDirectionsDidSendRequestToAPI(_ googleDirections: PXGoogleDirections, withURL requestURL: URL) {
        //   NSLog(Constants.Logs.DidSendRequestToAPI)
        //   NSLog("\(requestURL.absoluteString!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)")
    }
    
    func googleDirections(_ googleDirections: PXGoogleDirections, didReceiveRawDataFromAPI data: Data) {
        //  NSLog(Constants.Logs.DidReceiveRawDataFromAPI)
        //   NSLog(NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
    }
    
    func googleDirectionsRequestDidFail(_ googleDirections: PXGoogleDirections, withError error: NSError) {
        //    NSLog(Constants.Logs.RequestDidFail)
        //   NSLog("\(error)")
    }
    
    func googleDirections(_ googleDirections: PXGoogleDirections, didReceiveResponseFromAPI apiResponse: [PXGoogleDirectionsRoute]) {
        //   NSLog(Constants.Logs.ReceiveResponseFromAPI)
        //   NSLog("Got \(apiResponse.count) routes")
        //   for i in 0 ..< apiResponse.count {
        //   NSLog("Route \(i) has \(apiResponse[i].legs.count) legs")
        
        //    }
        
        
    }


}

