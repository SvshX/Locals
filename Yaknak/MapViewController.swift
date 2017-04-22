//
//  MapViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 16/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
//import CoreLocation
//import PXGoogleDirections
import GoogleMaps
import GeoFire
//import ReachabilitySwift
import Firebase
import FirebaseDatabase
import Kingfisher



class MapViewController: UIViewController {
    
    var data: Tip?
 //   var request: PXGoogleDirections!
 //   var result: [PXGoogleDirectionsRoute]!
 //   var routeIndex: Int = 0
 //   var reachability: Reachability?
    let tapRec = UITapGestureRecognizer()
    let dataService = DataService()
    var handle: UInt!
    var tipListRef: FIRDatabaseReference!
    var tipRef: FIRDatabaseReference!
    var tipMapView: MapView!
    var initialLikeCount: Int!
    let geoTask = GeoTasks()
    var travelMode = TravelMode.Modes.walking
    var routePolyline: GMSPolyline!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    self.addressLabel.isHidden = true
        self.tipMapView = Bundle.main.loadNibNamed("MapView", owner: self, options: nil)![0] as? MapView
        self.showAnimate()
        self.configureDetailView()
        self.tipMapView.mapView.delegate = self
        self.tipMapView.mapView.isMyLocationEnabled = true
        self.tipMapView.mapView.settings.myLocationButton = true
        self.tipMapView.mapView.settings.compassButton = true
        self.tipListRef = dataService.CURRENT_USER_REF.child("tipsLiked")
        self.tipRef = dataService.TIP_REF
        
        
        LocationService.sharedInstance.onLocationTracingEnabled = { enabled in
            if enabled {
                print("tracing location enabled/received...")
                LocationService.sharedInstance.startUpdatingLocation()
            }
            else {
                print("tracing location denied...")
            }
        }
        
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
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         if (UserDefaults.standard.bool(forKey: "isTracingLocationEnabled")) {
        LocationService.sharedInstance.startUpdatingLocation()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationService.sharedInstance.stopUpdatingLocation()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func popUpPrompt() {
        let alertController = UIAlertController()
        alertController.networkAlert(Constants.NetworkConnection.NetworkPromptMessage)
    }
    
    func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
            if let lat = LocationService.sharedInstance.currentLocation?.coordinate.latitude {
                if let lon = LocationService.sharedInstance.currentLocation?.coordinate.longitude {
            self.tipMapView.setCameraPosition(currentLocation: LocationService.sharedInstance.currentLocation!)
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        if appDelegate.isReachable {
            self.calculateAndDrawRoute(userLat: lat, userLong: lon)
                        }
                    }
            }
        }
        })
    }
    
    func removeAnimate() {
        
        
        // BUG: stack starts from the beginning
        if !UserDefaults.standard.bool(forKey: "likeCountChanged") {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "retainStack"), object: nil)
        }
        else {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStack"), object: nil)
        }
    
    
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        }
    }

    
    
    
    //MARK: - Actions
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.removeAnimate()
    }
    
    
    @IBAction func unlikeButtonTapped(_ sender: Any) {
      self.removeTipFromList(tip: data!)
        
        if StackObserver.sharedInstance.likeCountChanged {
        StackObserver.sharedInstance.likeCountChanged = false
        }
        else {
        StackObserver.sharedInstance.likeCountChanged = true
        }
    }
    

    
    
    private func removeTipFromList(tip: Tip) {
        
        self.tipListRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let key = tip.key {
            let a = snapshot.hasChild(key)
            
            if a {
                
                self.tipListRef.child(key).removeValue()
                self.decrementCurrentTip(tip: tip)
            }
            else {
                print("tip does not exist in list...")
            }
        }
        
        })
    }
    
    
    private func decrementCurrentTip(tip: Tip) {
        
        if let key = tip.key {
            if let category = tip.category {
                if let userId = tip.addedByUser {
            
        self.tipRef.child(key).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            
            if var data = currentData.value as? [String : Any] {
                var count = data["likes"] as! Int
                
                count -= 1
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
                        
                        
                        let updateObject = ["userTips/\(userId)/\(key)/likes" : likes, "categories/\(category)/\(key)/likes" : likes]
                        
                        self.dataService.BASE_REF.updateChildValues(updateObject, withCompletionBlock: { (error, ref) in
                            
                            
                            if error == nil {
                                print("Successfully updated all like counts...")
                            }
                            else {
                                print("Updating failed...")
                            }
                        })
                        
                    }
                
                }
                self.runTransactionOnUser(tip: tip)
                print(Constants.Logs.TipDecrementSuccess)
            }
        }
    }
    }
}
    }
    
    
    private func runTransactionOnUser(tip: Tip) {
        
        if let uid = tip.addedByUser {
        self.dataService.USER_REF.child(uid).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            
            if var data = currentData.value as? [String : Any] {
                var count = data["totalLikes"] as! Int
                
                count -= 1
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
                self.showSuccessInUI(tip: tip)
            }
        }
    }
    
        
    }
    
    
    private func showSuccessInUI(tip: Tip) {
        
        if let key = tip.key {
        self.dataService.TIP_REF.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : Any] {
            
                if let likes = dictionary["likes"] as? Int {
                
                    DispatchQueue.main.async {
                        
                        if likes == 1 {
                            self.tipMapView.likeLabel.text = "Like"
                        }
                        else {
                            self.tipMapView.likeLabel.text = "Likes"
                        }
                        self.tipMapView.likeNumber.text = "\(likes)"
                        self.tipMapView.likeNumber.textColor = UIColor.primaryTextColor()
                        self.tipMapView.likeLabel.textColor = UIColor.secondaryTextColor()
                        self.tipMapView.unlikeButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                        self.tipMapView.unlikeButton.backgroundColor = UIColor.primaryColor()
                        self.tipMapView.unlikeButton.setTitle("Unliked", for: .normal)
                        self.tipMapView.unlikeButton.isEnabled = false
                        
                        let alertController = UIAlertController()
                        alertController.defaultAlert(title: "", message: Constants.Notifications.UnlikeTipMessage)
                        
                    }
                
                }
            
            
            }
            
            
        })
    }
    
    }
    
    
    
    
    
    private func configureDetailView() {
      
        self.tipMapView.unlikeButton.setTitleColor(UIColor.primaryTextColor(), for: UIControlState.normal)
        self.tipMapView.unlikeButton.addTopBorder(color: UIColor.tertiaryColor(), width: 1.0)
        
        
        if let urlString = data?.userPicUrl {
            
            let url = URL(string: urlString)
            
            let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(targetSize: CGSize(width: 100, height: 100))
            self.tipMapView.userProfileImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                
                print("\(receivedSize)/\(totalSize)")
                
            }, completionHandler: { (image, error, cacheType, imageUrl) in
                
                if self.data?.likes == 1 {
                    
                    if let likes = self.data?.likes {
                        
                        self.tipMapView.likeNumber.text = "\(likes)"
                        self.tipMapView.likeLabel.text = "Like"
                        
                    }
                    
                }
                    
                else {
                    
                    if let likes = self.data?.likes {
                        
                        self.tipMapView.likeNumber.text = "\(likes)"
                        self.tipMapView.likeLabel.text = "Likes"
                        
                    }
                    
                    self.tipMapView.likeNumber.textColor = UIColor.primaryTextColor()
                    self.tipMapView.likeLabel.textColor = UIColor.secondaryTextColor()
                    
                }
                
            })
        
        }
        
    }
    
    
    private func calculateAndDrawRoute(userLat: CLLocationDegrees, userLong: CLLocationDegrees) {
    
        let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
        geo?.getLocationForKey(data?.key, withCallback: { (location, error) in
            
            if error == nil {
                
                if let lat = location?.coordinate.latitude {
                    
                    if let long = location?.coordinate.longitude {
                        
                 //       let latitudeText: String = "\(lat)"
                 //       let longitudeText: String = "\(long)"
                        
                        self.geoTask.getDirections(lat, originLong: long, destinationLat: LocationService.sharedInstance.currentLocation?.coordinate.latitude, destinationLong: LocationService.sharedInstance.currentLocation?.coordinate.longitude, travelMode: self.travelMode, completionHandler: { (status, success) in
                            
                            if success {
                                
                          self.loadMapData()
                            }
                            
                            else {
                                
                                if status == "OVER_QUERY_LIMIT" {
                                    sleep(2)
                                self.geoTask.getDirections(lat, originLong: long, destinationLat: LocationService.sharedInstance.currentLocation?.coordinate.latitude, destinationLong: LocationService.sharedInstance.currentLocation?.coordinate.longitude, travelMode: self.travelMode, completionHandler: { (status, success) in
                                    
                                    if success {
                                    self.loadMapData()

                                    }
                                    
                                })
                                }
                                else {
                               
                                let alertController = UIAlertController()
                                alertController.defaultAlert(title: nil, message: "Error: " + status)
                                }
                            
                            }
                            
    
                        })
                        
                    }
                    
                }
                
            }
            else {
                print(error?.localizedDescription)
            }
            
        })

    }
    
    
    func loadMapData() {
        
        let minutes = self.geoTask.totalDurationInSeconds / 60
        
        self.tipMapView.durationNumber.text = "\(minutes)"
        
        if minutes == 1 {
            self.tipMapView.durationLabel.text = "Min"
        }
        else {
            self.tipMapView.durationLabel.text = "Mins"
        }
        
        self.tipMapView.durationLabel.textColor = UIColor.secondaryTextColor()
        self.tipMapView.durationNumber.textColor = UIColor.primaryTextColor()
        
        let marker = GMSMarker(position: self.geoTask.originCoordinate)
        marker.title = Constants.Notifications.InfoWindow
        if let category = self.data?.category {
            self.drawRoute(category: category)
            if let image = UIImage(named: category + "-marker") {
                marker.icon = image
            }
        }
        
        marker.map = self.tipMapView.mapView
    
    }
    
    
    func drawRoute(category: String) {
        let route = self.geoTask.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.strokeColor = UIColor.routeColour(category: category)
        routePolyline.strokeWidth = 10.0
        routePolyline.geodesic = true
        
        routePolyline.map = self.tipMapView.mapView
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

