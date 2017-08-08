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
import SwiftLocation



class MapViewController: UIViewController {
  
    
    var data: Tip?
    private let tapRec = UITapGestureRecognizer()
    private let dataService = DataService()
    private var tipMapView: MapView!
    private let geoTask = GeoTasks()
    private var travelMode = TravelMode.Modes.walking
    private var routePolyline: GMSPolyline!
    private var tipCoordinates: CLLocationCoordinate2D!
    private var userCoordinates: CLLocationCoordinate2D!
    private var locationRequest: LocationRequest? = nil
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    self.addressLabel.isHidden = true
        tipMapView = Bundle.main.loadNibNamed("MapView", owner: self, options: nil)![0] as? MapView
      configureDetailView()
      initMap()
      showAnimate()
      }
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      trackLocation { (location) in
        self.updateLocation(location)
      }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      if locationRequest != nil {
      locationRequest?.cancel()
      }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initMap() {
        tipMapView.mapView.delegate = self
        tipMapView.mapView.isMyLocationEnabled = true
        tipMapView.mapView.settings.myLocationButton = true
        tipMapView.mapView.settings.compassButton = true
    }
    
    
    func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
          guard let currentLocation = Location.lastLocation.last, let coordinates = Location.lastLocation.last?.coordinate else {return}
          self.userCoordinates = coordinates
            self.tipMapView.setCameraPosition(atLocation: currentLocation)
            self.calculateRoute()
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
        
      guard let tip = data else {return}
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
                if let error = error {
                print(error.localizedDescription)
                }
            }
        }
        
    }
    

    
    private func showSuccessInUI(_ tip: Tip) {
        
      guard let key = tip.key else {return}
      
            self.dataService.getTip(key, completion: { (tip) in
                
              guard let likes = tip.likes else {return}
              
                    DispatchQueue.main.async {
                        
                        if likes == 1 {
                            self.tipMapView.likeLabel.text = "Like"
                        }
                        else {
                            self.tipMapView.likeLabel.text = "Likes"
                        }
                        self.tipMapView.likeNumber.text = "\(likes)"
                        self.tipMapView.likeNumber.textColor = UIColor.primaryText()
                        self.tipMapView.likeLabel.textColor = UIColor.secondaryText()
                        self.tipMapView.unlikeButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                        self.tipMapView.unlikeButton.backgroundColor = UIColor.primary()
                        self.tipMapView.unlikeButton.setTitle("Unliked", for: .normal)
                        self.tipMapView.unlikeButton.isEnabled = false
                        
                        let alertController = UIAlertController()
                        alertController.defaultAlert(nil, Constants.Notifications.UnlikeTipMessage)
                    }
            })
    
    }
    
    
    
    
    
    private func configureDetailView() {
      
        tipMapView.unlikeButton.setTitleColor(UIColor.primaryText(), for: UIControlState.normal)
        tipMapView.unlikeButton.addTopBorder(color: UIColor.tertiary(), width: 1.0)
      
      guard let urlString = data?.userPicUrl else {return}
      
            let url = URL(string: urlString)
            
            let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100))
            self.tipMapView.userProfileImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                
                print("\(receivedSize)/\(totalSize)")
                
            }, completionHandler: { (image, error, cacheType, imageUrl) in
                
                if self.data?.likes == 1 {
                    
                  guard let likes = self.data?.likes else {return}
                  
                        self.tipMapView.likeNumber.text = "\(likes)"
                        self.tipMapView.likeLabel.text = "Like"
                }
                    
                else {
                    
                  guard let likes = self.data?.likes else {return}
                  
                        self.tipMapView.likeNumber.text = "\(likes)"
                        self.tipMapView.likeLabel.text = "Likes"
                    
                    self.tipMapView.likeNumber.textColor = UIColor.primaryText()
                    self.tipMapView.likeLabel.textColor = UIColor.secondaryText()
                }
                
            })
    }
    
    
    private func calculateRoute() {
    
      guard let key = data?.key else {return}
        self.dataService.getTipLocation(key, completion: { (location, error) in
            
            if let error = error {
              print(error.localizedDescription)
              return
            }
            else {
              
              guard let lat = location?.coordinate.latitude, let long = location?.coordinate.longitude else {return}
              self.tipCoordinates = CLLocationCoordinate2DMake(lat, long)
              self.loadMap()
            }
        })
    }
  
  
  private func loadMap() {
  
    self.geoTask.getDirections(tipCoordinates.latitude, originLong: tipCoordinates.longitude, destinationLat: userCoordinates.latitude, destinationLong: userCoordinates.longitude, travelMode: self.travelMode, completion: { (status, success) in
      
      if success {
        self.loadMapData()
      }
        
      else {
        if status == "OVER_QUERY_LIMIT" {
          sleep(2)
          self.geoTask.getDirections(self.tipCoordinates.latitude, originLong: self.tipCoordinates.longitude, destinationLat: self.userCoordinates.latitude, destinationLong: self.userCoordinates.longitude, travelMode: self.travelMode, completion: { (status, success) in
            
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
  
  
    private func loadMapData() {
      
      tipMapView.mapView.clear()
      
        let minutes = self.geoTask.totalDurationInSeconds / 60
      
        self.tipMapView.durationNumber.text = "\(minutes)"
      
        if minutes == 1 {
            self.tipMapView.durationLabel.text = "Min"
        }
        else {
            self.tipMapView.durationLabel.text = "Mins"
        }
      
        self.tipMapView.durationLabel.textColor = UIColor.secondaryText()
        self.tipMapView.durationNumber.textColor = UIColor.primaryText()
        
        let marker = GMSMarker(position: self.geoTask.originCoordinate)
        marker.title = Constants.Notifications.InfoWindow
      guard let category = self.data?.category, let image = UIImage(named: category + "-marker") else {return}
            self.drawRoute(with: category)
                marker.icon = image
        marker.map = self.tipMapView.mapView
    
    }
    
    
    func drawRoute(with category: String) {
        let route = geoTask.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.strokeColor = UIColor.routeColor(with: category)
        routePolyline.strokeWidth = 10.0
        routePolyline.geodesic = true
        
        
        routePolyline.map = tipMapView.mapView
    }
  
  private func updateLocation(_ location: CLLocation) {
    
    if self.hasMovedSignificantly(toNewLocation: location) {
      self.userCoordinates = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
      self.loadMap()
    }
  }
  
  
  private func hasMovedSignificantly(toNewLocation location: CLLocation) -> Bool {
  
    let newLoc = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let oldLoc = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
    let distance: CLLocationDistance = newLoc.distance(from: oldLoc)
    return distance >= 20
  }
  
  
  private func trackLocation(completion: @escaping ((_ location: CLLocation) -> ())) {
    
    locationRequest = Location.getLocation(accuracy: .room, frequency: .continuous, success: { (_, location) -> (Void) in
      
      print("New location available: \(location)")
      completion(location)
      
    }) { (request, location, error) -> (Void) in
      
      switch (error) {
        
      case LocationError.authorizationDenied:
        print("Location monitoring failed due to an error: \(error)")
        NoLocationOverlay.delegate = self
        NoLocationOverlay.show()
        break
        
      case LocationError.invalidData:
        // do nothing
        break
        
      default:
        break
      }
    }
    
    locationRequest?.activity = .fitness
    locationRequest?.minimumDistance = 20.0
    locationRequest?.register(observer: LocObserver.onAuthDidChange(.main, { (request, oldAuth, newAuth) -> (Void) in
      print("Authorization moved from \(oldAuth) to \(newAuth)")
      switch (oldAuth) {
        
      case CLAuthorizationStatus.denied:
        
        if newAuth == CLAuthorizationStatus.authorizedWhenInUse {
          NoLocationOverlay.hide()
          self.trackLocation(completion: { (location) in
            self.updateLocation(location)
          })
        }
        break
        
      case CLAuthorizationStatus.authorizedWhenInUse:
        if newAuth == CLAuthorizationStatus.denied {
          NoLocationOverlay.delegate = self
          NoLocationOverlay.show()
        }
        break
        
      default:
        break
      }
    }))
    
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

extension MapViewController: EnableLocationDelegate {
  
  func onButtonTapped() {
    Utils.redirectToSettings()
  }
  
}

