//
//  TabBarController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Firebase


class TabBarController: UITabBarController {
    
    @IBInspectable var defaultIndex: Int = 2
    
    var button: UIButton = UIButton()
    var user: MyUser!
    var tips = [Tip]()
    var friends = [MyUser]()
    let dataService = DataService()
    var categoryArray: [Dashboard.Entry] = []
    var keys: [String]!
    var overallCount = 0
    var refresh: Bool! = true
 
    var onReloadProfile: ((_ user: MyUser, _ friends: [MyUser], _ tips: [Tip]) -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let centerImage = UIImage(named: Constants.Images.AppIcon) {
        addCenterButtonWithImage(buttonImage: centerImage)
        }
        changeTabToCenterTab(button)
        self.selectedIndex = defaultIndex
        self.setupAppearance()
        self.delegate = self
        
        LocationService.shared.onPassKeys = { (keys) in
        self.keys = keys
        }

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.getCurrentLocation {
            
            guard let radius = Location.determineRadius(), let currentLocation = Location.lastLocation.last else {return}
                    
                LocationService.shared.queryGeoFence(center: currentLocation, radius: radius)
            
            self.setUser(completion: { (user, friends, tips) in
                
                self.user = user
                self.tips = tips
                self.friends = friends
                self.trackLocation()
            })
            
        }
        
        /*
        self.loadUser(true) { (success, refresh) in
            
            if success {
                
                if !refresh {
                    self.addLocationTracker(false, completion: { (success, refresh) in
                        
                        if success {
                            
                            if refresh {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadDashboard"), object: nil, userInfo: ["animateTable": false])
                                print("Just received new location...reload dashboard...")
                            }
                            else {
                                
                               
                            }
                            
                        }
                        else {
                            print("Could not track location...")
                        }
                        
                    })
                }
                else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadProfile"), object: nil)
                    print("Just updated user profile...")
                }
                
            }
            else {
                print("Something went wrong...")
            }
            
        }
        */
        
        
        Location.onAddNewRequest = { request in
            print("A new request is added to the queue: \(request)")
        }
        
        Location.onRemoveRequest = { request in
            print("An exisitng request was removed from the queue: \(request)")
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dataService.removeCurrentUserObserver()
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func getCurrentLocation(completion: @escaping () -> ()) {
    
        let request = Location.getLocation(accuracy: .room, frequency: .oneShot, timeout: 10, cancelOnError: false, success: { (_, location) -> (Void) in
            
            print("Initial current location is: \(location)")
            completion()
            
        }) { (request, location, error) -> (Void) in
            
            switch (error) {
                
            case LocationError.authorizationDenied:
                print("Location monitoring failed due to an error: \(error)")
                NoLocationOverlay.delegate = self
                NoLocationOverlay.show()
                break
                
            case LocationError.noData:
                break
                
            default:
                break
            }
        }
        
        
        request.register(observer: LocObserver.onAuthDidChange(.main, { (request, oldAuth, newAuth) -> (Void) in
            print("Authorization moved from \(oldAuth) to \(newAuth)")
            switch (oldAuth) {
                
            case CLAuthorizationStatus.denied:
                
                if newAuth == CLAuthorizationStatus.authorizedWhenInUse {
                    NoLocationOverlay.hide()
                    self.getCurrentLocation {
                        completion()
                    }
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
    
  
    
    private func trackLocation() {
    
        let request = Location.getLocation(accuracy: .house, frequency: .continuous, success: { (_, location) -> (Void) in
            print("Just received new location...reload dashboard...")
            LocationService.shared.onDistanceChanged()
            
        }) { (request, location, error) -> (Void) in
            
            switch (error) {
                
            case LocationError.authorizationDenied:
                print("Location monitoring failed due to an error: \(error)")
                NoLocationOverlay.delegate = self
                NoLocationOverlay.show()
                break
                
            case LocationError.noData:
                break
                
            default:
                break
            }

            
        }
        
        request.minimumDistance = 20.0
        request.register(observer: LocObserver.onAuthDidChange(.main, { (request, oldAuth, newAuth) -> (Void) in
            print("Authorization moved from \(oldAuth) to \(newAuth)")
            switch (oldAuth) {
                
            case CLAuthorizationStatus.denied:
                
                if newAuth == CLAuthorizationStatus.authorizedWhenInUse {
                    NoLocationOverlay.hide()
                    self.trackLocation()
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
        
        Location.onReceiveNewLocation = { location in
             print("New location: \(location)")
        }
    
    }
    
    
    func setUser(completion: @escaping (_ user: MyUser, _ friends: [MyUser], _ tips: [Tip]) -> ()) {
    
        var myFriends = [MyUser]()
        var myTips = [Tip]()
        
    self.dataService.getCurrentUser { (user) in
        
        self.dataService.getFriends(user, completion: { (friends) in
            
            if let friends = friends {
                myFriends = friends
            }
            
            if let tips = user.totalTips {
                
                if let uid = user.key {
                    
                    if tips > 0 {
                        
                        var tipArray = [Tip]()
                        
                        self.dataService.USER_TIP_REF.child(uid).keepSynced(true)
                        self.dataService.USER_TIP_REF.child(uid).observeSingleEvent(of: .value, with: { (tipSnap) in
                            
                            for tip in tipSnap.children.allObjects as! [DataSnapshot] {
                                
                                let tipObject = Tip(snapshot: tip)
                                tipArray.append(tipObject)
                                
                            }
                            
                            myTips = tipArray.reversed()
                            completion(user, myFriends, myTips)
                            
                            
                        }, withCancel: { (error) in
                            print(error.localizedDescription)
                            completion(user, myFriends, myTips)
                        })
                        
                    }
                    else {
                        completion(user, myFriends, myTips)
                    }
                    
                }
            }
                
            else {
                print("User data seems to be wrong...")
            }
        })
        }
    }

    
    func loadUser(_ atLaunch: Bool, completion: @escaping (_ success: Bool, _ refresh: Bool) -> ()) {
        
        if atLaunch {
            refresh = false
        }
        
        self.dataService.observeCurrentUser { (user) in
            
            self.user = nil
            self.user = user
            
            self.dataService.getFriends(user, completion: { (friends) in
                if let friends = friends {
                    self.friends = friends
                }
                
                if let tips = user.totalTips {
                    
                    if let uid = user.key {
                        
                        if tips > 0 {
                            
                            var tipArray = [Tip]()
                            
                            self.dataService.USER_TIP_REF.child(uid).keepSynced(true)
                            self.dataService.USER_TIP_REF.child(uid).observeSingleEvent(of: .value, with: { (tipSnap) in
                                
                                for tip in tipSnap.children.allObjects as! [DataSnapshot] {
                                    
                                    let tipObject = Tip(snapshot: tip)
                                    tipArray.append(tipObject)
                                    
                                }
                               
                                    self.tips = tipArray.reversed()
                                    completion(true, self.refresh)
                                
                                
                            }, withCancel: { (error) in
                                print(error.localizedDescription)
                                completion(false, self.refresh)
                            })
                            
                        }
                        else {
                            if self.tips.count > 0 {
                                self.tips.removeAll()
                            }
                            completion(true, self.refresh)
                        }
                        
                    }
                }
        
            
                else {
                print("Something went wrong...")
            }
            })
        }
    }
    
  /*
    func addLocationTracker(_ isOneShot: Bool, completion: @escaping (_ success: Bool, _ refresh: Bool) -> ()) {
    
        self.getLocation(completion: {
                
                if let radius = Location.determineRadius() {
                    
                    if let currentLocation = Location.lastLocation.last {
                    
                    LocationService.shared.queryGeoFence(center: currentLocation, radius: radius)
                   /*
                    self.dataService.getNearbyTips(radius, completion: { (success, keys, error) in
                        
                    //    var keyProxy = self.mutableArrayValue(forKey: "keys")
                    //    self.geofence = keys
                        
                    //    for i in self.geofence.keys! {
                    //    keyProxy.add(i)
                    //    }
                        self.keys = keys
                        completion(success, isOneShot)
                        })
                    */
                    }
                    }
            })
    }
*/
    

    
    
    func setupAppearance() {
        
        UITabBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().barTintColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
        UITabBar.appearance().selectionIndicatorImage = self.makeImageWithColorAndSize(color: UIColor.smokeWhiteColor(), size: CGSize(tabBar.frame.width/5, tabBar.frame.height))
        UITabBar.appearance().layer.borderWidth = 1
        UITabBar.appearance().layer.borderColor = UIColor.black.cgColor
        tabBar.clipsToBounds = false
        tabBar.isTranslucent = false
        
        if self.tabBar.items != nil {
            // Uses the original colors for images, so they aren't rendered as grey automatically.
            for item in self.tabBar.items! as [UITabBarItem] {
                item.title = ""
                item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
            }
        }
    }
    
    
    func addCenterButtonWithImage(buttonImage: UIImage) {
        
        let frame = CGRect(0.0, 0.0, buttonImage.size.width/2, buttonImage.size.height/2)
        button = UIButton(frame: frame)
        button.setBackgroundImage(buttonImage, for: UIControlState.normal)
        button.contentMode = .scaleAspectFit
        
        var center: CGPoint = self.tabBar.center
        center.y = center.y - buttonImage.size.height / 2
        center.x = center.x - buttonImage.size.width / 2
        button.center = self.tabBar.center
        button.addTarget(self, action: #selector(TabBarController.changeTabToCenterTab(_:)), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(button)
        
    }
    
    
    func changeTabToCenterTab(_ sender: UIButton) {
        
        tabBarController?.selectedIndex = 2
        sender.isUserInteractionEnabled = false
        
        
    }
    
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
   /*
    private func getLocation(completion: @escaping () -> ()) {
        
        let loc = Location.getLocation(accuracy: .room, frequency: .continuous, timeout: 60*60*5, success: { (_, location) -> (Void) in
            
            print("A new update of location is available: \(location)")
            let _ = location.coordinate.latitude
            let _ = location.coordinate.longitude
        //    self.dataService.setUserLocation(lat, lon)
            
             completion()
            //  }
            
        }) { (request, location, error) -> (Void) in
            
            switch (error) {
                
            case LocationError.authorizationDenied:
                print("Location monitoring failed due to an error: \(error)")
                NoLocationOverlay.delegate = self
                NoLocationOverlay.show()
                break
                
            case LocationError.noData:
                break
                
            default:
                break
            }
            
          
            //   request.cancel() // stop continous location monitoring on error
            
        }
        
        loc.minimumDistance = 10
        loc.register(observer: LocObserver.onAuthDidChange(.main, { (request, oldAuth, newAuth) -> (Void) in
            print("Authorization moved from \(oldAuth) to \(newAuth)")
            switch (oldAuth) {
                
            case CLAuthorizationStatus.denied:
                
                if newAuth == CLAuthorizationStatus.authorizedWhenInUse {
                    NoLocationOverlay.hide()
                    self.getLocation(completion: {
                        print("New location received...")
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
        
        Location.onReceiveNewLocation = { location in
            // print("New location: \(location)")
        }
        
    }
    */
    
    
}


extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
}


extension TabBarController: EnableLocationDelegate {
    
    func onButtonTapped() {
        Location.redirectToSettings()
    }
    
}

