//
//  MapViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 16/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import GoogleMaps
import Kingfisher



class MapViewController: UIViewController {
    
    var data: Tip?
    let tapRec = UITapGestureRecognizer()
    let dataService = DataService()
    var tipMapView: MapView!
    let geoTask = GeoTasks()
    var travelMode = TravelMode.Modes.walking
    var routePolyline: GMSPolyline!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    self.addressLabel.isHidden = true
        self.tipMapView = Bundle.main.loadNibNamed("MapView", owner: self, options: nil)![0] as? MapView
        self.showAnimate()
        self.configureDetailView()
        self.initMap()
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initMap() {
        self.tipMapView.mapView.delegate = self
        self.tipMapView.mapView.isMyLocationEnabled = true
        self.tipMapView.mapView.settings.myLocationButton = true
        self.tipMapView.mapView.settings.compassButton = true
    }
    
    
    func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
            if let lat = Location.lastLocation.last?.coordinate.latitude {
                if let lon = Location.lastLocation.last?.coordinate.longitude {
                    if let currentLocation = Location.lastLocation.last {
            self.tipMapView.setCameraPosition(currentLocation: currentLocation)
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        if appDelegate.isReachable {
            self.calculateAndDrawRoute(userLat: lat, userLong: lon)
                        }
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
    
    
        UIView.animate(withDuration: 0.15, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
         //   self.view.alpha = 0.0
        }) { (finished) in
            if (finished) {
                self.dismiss(animated: true, completion: nil)
              //  self.view.removeFromSuperview()
            }
        }
    }

    
    
    
    //MARK: - Actions
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.removeAnimate()
    }
    
    
    @IBAction func unlikeButtonTapped(_ sender: Any) {
        
        if let tip = data {
        self.dataService.removeTipFromList(tip: tip) { (success, error) in
            
            if success {
                print(Constants.Logs.TipDecrementSuccess)
            self.showSuccessInUI(tip)
                if StackObserver.shared.likeCountChanged {
                    StackObserver.shared.likeCountChanged = false
                }
                else {
                    StackObserver.shared.likeCountChanged = true
                }
            }
            else {
                if let err = error {
                print(err.localizedDescription)
                }
            }
        }
        }
    }
    

    
    private func showSuccessInUI(_ tip: Tip) {
        
        if let key = tip.key {
            
            self.dataService.getTip(key, completion: { (tip) in
                
                if let likes = tip.likes {
                    
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
                        alertController.defaultAlert(nil, Constants.Notifications.UnlikeTipMessage)
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
            
            let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100))
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
    
        if let key = data?.key {
        self.dataService.getTipLocation(key, completion: { (location, error) in
            
            if error == nil {
                
                if let lat = location?.coordinate.latitude {
                    
                    if let long = location?.coordinate.longitude {
                        
                        self.geoTask.getDirections(lat, originLong: long, destinationLat: Location.lastLocation.last?.coordinate.latitude, destinationLong: Location.lastLocation.last?.coordinate.longitude, travelMode: self.travelMode, completionHandler: { (status, success) in
                            
                            if success {
                          self.loadMapData()
                            }
                            
                            else {
                                
                                if status == "OVER_QUERY_LIMIT" {
                                    sleep(2)
                                self.geoTask.getDirections(lat, originLong: long, destinationLat: Location.lastLocation.last?.coordinate.latitude, destinationLong: Location.lastLocation.last?.coordinate.longitude, travelMode: self.travelMode, completionHandler: { (status, success) in
                                    
                                    if success {
                                    self.loadMapData()

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

