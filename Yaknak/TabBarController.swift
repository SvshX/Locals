//
//  TabBarController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Firebase
import GeoFire


class TabBarController: UITabBarController {
    
    @IBInspectable var defaultIndex: Int = 2
    
    var button: UIButton = UIButton()
    var user: MyUser!
    var tips = [Tip]()
    var friends = [MyUser]()
    let dataService = DataService()
    var categoryArray: [Dashboard.Entry] = []
    var overallCount = 0
    var refresh: Bool! = true
    var circleQuery: GFCircleQuery!
    var geoTipRef: GeoFire!
    var dashboardCategories = Dashboard()
    var categoryRef: DatabaseReference!
    var animate: Bool!
    var isLaunch: Bool!
    var currentKeys = [String]()
    
    var updatedKeys: [String] = [] {
        didSet {
                self.fillDashboard(completion: { (categories, overallCount) in
                    self.onReloadDashboard?(categories, overallCount, self.isLaunch)
                })
        }
    }
    
    var onReloadDashboard: ((_ categories: [Dashboard.Entry], _ overallCount: Int, _
    animate: Bool)->())?
 
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
        self.circleQuery = GFCircleQuery()
        self.geoTipRef = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
        self.categoryRef = self.dataService.CATEGORY_REF
        
        guard let navController = self.viewControllers?[0] as? UINavigationController else {return}
        let vc = navController.topViewController as! SettingsViewController
        vc.radiusDelegate = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setUser(completion: { (user, friends, tips) in
            
            self.user = user
            self.tips = tips
            self.friends = friends
            self.trackLocation()
        })
        
        
        Location.onAddNewRequest = { request in
            print("A new request is added to the queue: \(request)")
            self.isLaunch = true
        }
        
        Location.onRemoveRequest = { request in
            print("An exisitng request was removed from the queue: \(request)")
            self.isLaunch = false
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
    
    
    private func trackLocation() {
    
        let request = Location.getLocation(accuracy: .house, frequency: .continuous, timeout: 30, cancelOnError: false, success: { (_, location) -> (Void) in
            
            print("New location available: \(location)")
            
                    guard let radius = Location.determineRadius() else {return}
            
                    self.queryGeoFence(center: location, radius: radius)
            
            
        
            
        }) { (request, location, error) -> (Void) in
            
            switch (error) {
                
            case LocationError.authorizationDenied:
                print("Location monitoring failed due to an error: \(error)")
                NoLocationOverlay.delegate = self
                NoLocationOverlay.show()
                break
                
            case LocationError.noData:
                break
                
            case LocationError.timeout:
                // TODO
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
    
    }
    
  
   /*
    private func trackLocation() {
    
        let request = Location.getLocation(accuracy: .house, frequency: .continuous, success: { (_, location) -> (Void) in
            print("Just received new location...reload dashboard...")
         //   LocationService.shared.onDistanceChanged()
            
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
           //  print("New location: \(location)")
        }
    
    }
    */
    
    func queryGeoFence(center: CLLocation, radius: Double) {
        
        
        if self.isLaunch {
        circleQuery = geoTipRef?.query(at: Location.lastLocation.last, withRadius: radius)
        
        circleQuery.observe(.keyEntered, with: { (key, location) in
            
            print("Key Entered...")
            if let key = key {
                self.currentKeys.append(key)
            }
        })
        
        circleQuery.observe(.keyExited, with: { (key, location) in
            
            print("Key Exited...")
            if let key = key, let index = self.currentKeys.index(of: key) {
                self.currentKeys.remove(at: index)
            }
        })
        
        circleQuery.observeReady({
           
            print("Observe ready...")
            self.fillDashboard(completion: { (categories, overallCount) in
                self.onReloadDashboard?(categories, overallCount, self.isLaunch)
                self.refresh = false
                self.isLaunch = false
            })
            /*
            if !Utils.containSameElements(self.currentKeys, self.updatedKeys) {
            self.updatedKeys = self.currentKeys
            }
            */
            /*
            if self.refresh {
            self.fillDashboard(completion: { (categories, overallCount) in
                self.onReloadDashboard?(categories, overallCount, self.isLaunch)
                self.refresh = false
                self.isLaunch = false
            })
            }
            else {
            self.refresh = true
            }
            */
        })
        }
        else {
            if self.circleQuery != nil {
                self.circleQuery.center = Location.lastLocation.last
                self.circleQuery.radius = radius
            }
            else {
                self.circleQuery = self.geoTipRef?.query(at: Location.lastLocation.last, withRadius: radius)
            }
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
    
    
    func fillDashboard(completion: @escaping (_ categories: [Dashboard.Entry], _ overallCount: Int) -> ()) {
        
        
        let entry = dashboardCategories.categories
          var categories: [Dashboard.Entry] = []
          var overallCount: Int = 0
        let group = DispatchGroup()
        
        
        for (index, cat) in entry.enumerated() {
            
            cat.tipCount = 0
           
            group.enter()
            self.categoryRef.child(cat.category.lowercased()).keepSynced(true)
            self.categoryRef.child(cat.category.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if (snapshot.hasChildren()) {
                    
                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        if (self.updatedKeys.contains(child.key)) {
                            cat.tipCount += 1
                            overallCount += 1
                        }
                    }
                    
                }
                categories.append(entry[index])
                group.leave()
            })
            
        }
        
        
        group.notify(queue: DispatchQueue.main) {
            completion(categories, overallCount)
        }
        
    }


    
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


extension TabBarController: RadiusDelegate {

    func radiusChanged() {
        if let radius = Location.determineRadius() {
            if circleQuery != nil {
                circleQuery.center = Location.lastLocation.last
                circleQuery.radius = radius
            }
            else {
                circleQuery = geoTipRef?.query(at: Location.lastLocation.last, withRadius: radius)
            }
        }
    }
}

