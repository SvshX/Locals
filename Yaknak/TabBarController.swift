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
    var categoryHelper = CategoryHelper()
    var categoryArray: [Dashboard.Entry] = []
    var keys: [String]!
    var overallCount = 0
    var finishedLoading = false
    var profileUpdated = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let centerImage = UIImage(named: Constants.Images.AppIcon) {
        addCenterButtonWithImage(buttonImage: centerImage)
        }
        changeTabToCenterTab(button)
        self.setupAppearance()
        self.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tipsUpdated),
                                               name: NSNotification.Name(rawValue: "tipsUpdated"),
                                               object: nil)
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Location.onAddNewRequest = { request in
            print("A new request is added to the queue: \(request)")
        }
        
        Location.onRemoveRequest = { request in
            print("An exisitng request was removed from the queue: \(request)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dataService.removeCurrentUserObserver()
        if let uid = user.key {
        self.dataService.removeUsersTipsObserver(uid)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func preloadUser(completion: @escaping (_ success: Bool) -> ()) {
        
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
                            
                            self.dataService.USER_TIP_REF.child(uid).observe(.value, with: { (tipSnap) in
                                
                                for tip in tipSnap.children.allObjects as! [DataSnapshot] {
                                    
                                    let tipObject = Tip(snapshot: tip)
                                    tipArray.append(tipObject)
                                    
                                }
                               
                                    self.tips = tipArray.reversed()
                                    completion(true)
                                
                                
                            }, withCancel: { (error) in
                                print(error.localizedDescription)
                                completion(false)
                            })
                            
                        }
                        else {
                            if self.tips.count > 0 {
                                self.tips.removeAll()
                            }
                            completion(true)
                        }
                        
                    }
                }
        
            
                else {
                print("Something went wrong...")
            }
            })
        }
    }
    
    
    func addLocationTracker(completion: @escaping (_ success: Bool) -> ()) {
    
        self.getLocation(completion: { (success) in
            
            if success {
                
                if let radius = Location.determineRadius() {
                    self.dataService.getNearbyTips(radius, completion: { (success, keys, error) in
                        
                        self.keys = keys
                        completion(success)
                        })
                    }
                }
            })
    }


    func preloadViews() {
        self.setupUser(completion: { (success) in
        
            if success {
            //    _ = self.viewControllers?[4].view
                self.finishedLoading = true
            if let navController = self.viewControllers?[1] as? UINavigationController {
                    navController.topViewController?.view
                }
                
                if self.profileUpdated {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProfile"), object: nil)
                    self.profileUpdated = false
                }
            }
    })
    }
    
    func tipsUpdated() {
    self.preloadUser { (success) in
        
        if success {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadProfile"), object: nil)
        }
        }
    }
    
    
    private func setupUser(completion: @escaping (Bool) -> ()) {
        
        self.dataService.getCurrentUser { (user) in
            self.user = user
            
            if let tips = user.totalTips {
                
                if let uid = user.key {
                
                if tips > 0 {
                    
                    var tipArray = [Tip]()
                    
                    self.dataService.USER_TIP_REF.child(uid).observeSingleEvent(of: .value, with: { (tipSnap) in
                        
                        for tip in tipSnap.children.allObjects as! [DataSnapshot] {
                            
                            let tipObject = Tip(snapshot: tip)
                            tipArray.append(tipObject)
                            
                        }
                        if !self.finishedLoading {
                            self.tips = tipArray.reversed()
                            self.dataService.getFriends(user, completion: { (friends) in
                                if let friends = friends {
                                    self.friends = friends
                                    completion(true)
                                }
                                else {
                                    completion(false)
                                }
                            })
                        }
                        
                    }, withCancel: { (error) in
                        print(error.localizedDescription)
                    })
                    
                }
                else {
                    if self.tips.count > 0 {
                        self.tips.removeAll()
                    }
                    self.dataService.getFriends(user, completion: { (friends) in
                        if let friends = friends {
                            self.friends = friends
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    })
                    
                }
                
            }
        }
        }
    }
    
    
    
    func setupAppearance() {
        
        selectedIndex = defaultIndex
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
    
    
    private func getLocation(completion: @escaping (_ success: Bool) -> ()) {
        let loc = Location.getLocation(accuracy: .room, frequency: .continuous, timeout: 60*60*5, success: { (_, location) -> (Void) in
            
            print("A new update of location is available: \(location)")
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            self.dataService.setUserLocation(lat, lon)
            
            self.categoryHelper.findNearbyTips(lat, lon, completionHandler: { success in
                
                self.categoryArray = self.categoryHelper.categoryArray
                self.overallCount = self.categoryHelper.overallCount
                completion(true)
            })
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
        
        loc.minimumDistance = 1
        loc.register(observer: LocObserver.onAuthDidChange(.main, { (request, oldAuth, newAuth) -> (Void) in
            print("Authorization moved from \(oldAuth) to \(newAuth)")
            switch (oldAuth) {
                
            case CLAuthorizationStatus.denied:
                
                if newAuth == CLAuthorizationStatus.authorizedWhenInUse {
                    NoLocationOverlay.hide()
                    self.getLocation(completion: { (success) in
                        
                        if success {
                        print("Test...")
                        }
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
             print("New location: \(location)")
        }
        
    }
    
    
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

