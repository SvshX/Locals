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
import Firebase
import FirebaseDatabase



class MapViewController: UIViewController, LocationServiceDelegate {
    
    /*
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var unlikeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesNumber: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationNumber: UILabel!
    */
    
    var data: Tip?
    var request: PXGoogleDirections!
    var result: [PXGoogleDirectionsRoute]!
    var routeIndex: Int = 0
    var reachability: Reachability?
    let tapRec = UITapGestureRecognizer()
    let dataService = DataService()
    var handle: UInt!
    var tipListRef: FIRDatabaseReference!
    var tipRef: FIRDatabaseReference!
    var tipMapView: MapView!
    
    var directionsAPI: PXGoogleDirections {
        return (UIApplication.shared.delegate as! AppDelegate).directionsAPI
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    self.addressLabel.isHidden = true
        self.tipMapView = Bundle.main.loadNibNamed("MapView", owner: self, options: nil)![0] as? MapView
        self.showAnimate()
        self.configureNavBar()
        self.configureDetailView()
        LocationService.sharedInstance.delegate = self
        self.tipMapView.mapView.delegate = self
        self.tipMapView.mapView.isMyLocationEnabled = true
        self.tipMapView.mapView.settings.myLocationButton = true
        self.tipMapView.mapView.settings.compassButton = true
        self.directionsAPI.delegate = self
        self.tipListRef = dataService.CURRENT_USER_REF.child("tipsLiked")
        self.tipRef = dataService.TIP_REF
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationService.sharedInstance.startUpdatingLocation()
        
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
        alertController.networkAlert(title: Constants.NetworkConnection.NetworkPromptTitle, message: Constants.NetworkConnection.NetworkPromptMessage)
    }
    
    func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        
        
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
        StackObserver.sharedInstance.likeCountValue = 2
        self.removeTipFromList(tip: data!)
    }
    
 /*
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func unlikeButtonTapped(_ sender: Any) {
        StackObserver.sharedInstance.likeCountValue = 2
        self.removeTipFromList(tip: data!)
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
    
    
    private func removeTipFromList(tip: Tip) {
        
        self.tipListRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let a = snapshot.hasChild(tip.getKey())
            
            if a {
                
                self.tipListRef.child(tip.getKey()).removeValue()
                self.decrementCurrentTip(tip: tip)
            }
            else {
                print("tip does not exist in list...")
            }
            
        })
    }
    
    
    private func decrementCurrentTip(tip: Tip) {
        
        self.tipRef.child(tip.getKey()).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            
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
                self.runTransactionOnUser(tip: tip)
                print(Constants.Logs.TipDecrementSuccess)
            }
        }
    }
    
    
    private func runTransactionOnUser(tip: Tip) {
        
        self.dataService.USER_REF.child(tip.getUserId()).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            
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
    
    
    private func showSuccessInUI(tip: Tip) {
        
        self.dataService.TIP_REF.child(tip.getKey()).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : Any] {
            
                if let likes = dictionary["likes"] as? Int {
                
                    DispatchQueue.main.async {
                        
                        if likes == 1 {
                            self.tipMapView.likeLabel.text = "Like"
                        }
                        else {
                            self.tipMapView.likeLabel.text = "Likes"
                        }
                        self.tipMapView.likeNumber.text = String(likes)
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
        
        //   self.detailView.layer.cornerRadius = 5
        //   self.detailView.layer.shadowOpacity = 0.7
        //   self.detailView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        //   self.detailView.layer.shadowColor = UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1).CGColor
        self.tipMapView.unlikeButton.setTitleColor(UIColor.primaryTextColor(), for: UIControlState.normal)
        self.tipMapView.unlikeButton.addTopBorder(color: UIColor.tertiaryColor(), width: 1.0)
        
        
        if let url = data?.userPicUrl {
            self.tipMapView.userProfileImage.loadImageUsingCacheWithUrlString(urlString: url)
        }
        
        if data?.likes == 1 {
            
            if let likes = data?.likes {
                
                self.tipMapView.likeNumber.text = String(likes)
                self.tipMapView.likeLabel.text = "Like"
                
            }
            
        }
            
        else {
            
            if let likes = data?.likes {
                
                self.tipMapView.likeNumber.text = String(likes)
                self.tipMapView.likeLabel.text = "Likes"
                
            }
            
            self.tipMapView.likeNumber.textColor = UIColor.primaryTextColor()
            self.tipMapView.likeLabel.textColor = UIColor.secondaryTextColor()
            
        }
        
    }
    
    
    private func calculateAndDrawRoute(userLat: CLLocationDegrees, userLong: CLLocationDegrees) {
    
        let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
        geo?.getLocationForKey(data?.key, withCallback: { (location, error) in
            
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
                                    let alertController = UIAlertController()
                                    alertController.defaultAlert(title: Constants.Config.AppName, message: "Error: \(error.localizedDescription)")
                                case let .success(request, routes):
                                    
                                    self.request = request
                                    self.result = routes
                                    
                                    for i in 0 ..< (self.result).count {
                                        if i != self.routeIndex {
                                            self.result[i].drawOnMap(self.tipMapView.mapView, strokeColor: UIColor.blue, strokeWidth: 3.0)
                                            
                                        }
                                        
                                    }
                                    
                                    let totalDuration: TimeInterval = self.result[self.routeIndex].totalDuration
                                    let ti = NSInteger(totalDuration)
                                    let minutes = (ti / 60) % 60
                                    
                                    //     let totalDistance: CLLocationDistance = self.result[self.routeIndex].totalDistance
                                    
                                    //    self.distanceLabel.text = String(totalDistance) + " m"
                                    //    self.distanceLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
                                    self.tipMapView.durationNumber.text = String(minutes)
                                    
                                    if totalDuration == 1 {
                                        self.tipMapView.durationLabel.text = "Min"
                                    }
                                    else {
                                        self.tipMapView.durationLabel.text = "Mins"
                                    }
                                    
                                    self.tipMapView.durationLabel.textColor = UIColor.secondaryTextColor()
                                    self.tipMapView.durationNumber.textColor = UIColor.primaryTextColor()
                                    self.result[self.routeIndex].drawOnMap(self.tipMapView.mapView, strokeColor: UIColor(red: 57/255, green: 148/255, blue: 228/255, alpha: 1), strokeWidth: 4.0)
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
                        
                        marker.map = self.self.tipMapView.mapView
                        
                        
                    }
                    
                }
                
            }
            else {
                print(error?.localizedDescription)
            }
            
        })

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
        
        self.tipMapView.setCameraPosition(currentLocation: currentLocation)
        
        
        self.calculateAndDrawRoute(userLat: lat, userLong: lon)
      
        
    }
    
    
    func tracingLocationDidFailWithError(_ error: NSError) {
        print("tracing Location Error : \(error.description)")
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

