

//
//  HomeTableViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import ReachabilitySwift
import CoreLocation
import MBProgressHUD
import Foundation
import FirebaseDatabase
import GeoFire
import Firebase
import FirebaseAuth


class HomeTableViewController: UITableViewController, LocationServiceDelegate {
    
    var homeCategories = Category()
    var reachability: Reachability?
    var miles = Double()
    var categoryArray: [Category.Entry] = []
    var overallCount = 0
    weak var activityIndicatorView: UIActivityIndicatorView!
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    let dataService = DataService()
    var handle: UInt!
    var tipRef: FIRDatabaseReference!
    var categoryRef: FIRDatabaseReference!
    var didFindLocation: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupReachability(nil, useClosures: true)
        startNotifier()
        
        self.configureNavBar()
        self.setUpTableView()
        LocationService.sharedInstance.delegate = self
            //    self.configureLocationManager()
        self.detectDistance()
        self.tipRef = dataService.TIP_REF
        self.categoryRef = dataService.CATEGORY_REF
        
        if let userId = FIRAuth.auth()?.currentUser?.uid {
            if (!userAlreadyExists(userUid: userId)) {
                UserDefaults.standard.set(userId, forKey: "uid")
            }
        
        }
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationService.sharedInstance.startUpdatingLocation()
        self.didFindLocation = false

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reachability!.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
     //   self.tipRef.removeObserver(withHandle: handle)
     //   tipRef.removeAllObservers()
           }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationService.sharedInstance.stopUpdatingLocation()
        if let handle = handle {
        tipRef.removeObserver(withHandle: handle)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavBar() {
        
     //   let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 70))
        let navLabel = UILabel()
        navLabel.contentMode = .scaleAspectFill
        navLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 70)
    //    navLogo.contentMode = .scaleAspectFit
      //  let image = UIImage(named: Constants.Images.NavImage)
      //  navLogo.image = image
        navLabel.text = "Nearby"
        navLabel.textColor = UIColor.secondaryTextColor()
        self.navigationItem.titleView = navLabel
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    func userAlreadyExists(userUid: String) -> Bool {
        return UserDefaults.standard.object(forKey: userUid) != nil
    }
    
    
    func findNearbyTips() {
        
        var keys = [String]()
        let geo = GeoFire(firebaseRef: dataService.GEO_TIP_REF)
        let myLocation = CLLocation(latitude: (LocationService.sharedInstance.currentLocation?.coordinate.latitude)!, longitude: (LocationService.sharedInstance.currentLocation?.coordinate.longitude)!)
        print(myLocation)
        let distanceInKM = self.miles * 1609.344 / 1000
        let circleQuery = geo!.query(at: myLocation, withRadius: distanceInKM)  // radius is in km
        
        self.handle = circleQuery!.observe(.keyEntered, with: { (key, location) in
            
            keys.append(key!)
            //      if !self.nearbyUsers.contains(key!) && key! != FIRAuth.auth()!.currentUser!.uid {
            //          self.nearbyUsers.append(key!)
            //      }
            
        })
        
        //Execute this code once GeoFire completes the query!
        circleQuery?.observeReady ({
            self.prepareCategoryList(keys: keys)
        })
        
    }
    
    
    func prepareCategoryList(keys: [String]) {
        
        let entry = homeCategories.categories
        for (_, cat) in entry.enumerated() {
            cat.tipCount = 0
        }
        self.categoryArray.removeAll(keepingCapacity: true)
        self.overallCount = 0
        
        for (index, cat) in entry.enumerated() {
                
           self.handle = self.tipRef.queryOrdered(byChild: "category").queryEqual(toValue: cat.category).observe(.value, with: { snapshot in
                
                
                if (keys.count != 0) {
                for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    if (keys.contains(child.key)) {
                        cat.tipCount += 1
                        self.overallCount += 1
                    }
                    else {
                        print("no matches...")
                    }
                }
                
                }
                
                
                self.categoryArray.append(entry[index])
                self.doTableRefresh()
            })
            
        }
        
        
        
    }
    
    
    private func setUpTableView() {
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        tableView.backgroundView = activityIndicatorView
        self.activityIndicatorView = activityIndicatorView
        self.activityIndicatorView.center = CGPoint(width/2, height/2)
        self.tableView.register(UINib(nibName: Constants.NibNames.HomeTable, bundle: nil), forCellReuseIdentifier: Constants.NibNames.HomeTable)
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        
        let reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        self.reachability = reachability
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                print(Constants.Notifications.WiFi)
                
            }
            reachability?.whenUnreachable = { reachability in
                DispatchQueue.main.async {
                    print(Constants.Notifications.NotReachable)
                    self.popUpPrompt()
                }
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            print(Constants.Notifications.NoNotifier)
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            print(Constants.Notifications.WiFi)
        } else {
            print(Constants.Notifications.NotReachable)
            self.popUpPrompt()
        }
    }
    
    deinit {
        stopNotifier()
    }
    
    
    func popUpPrompt() {
        AlertViewHelper.promptNetworkFail()
    }
    
    
    
    private func detectDistance() {
        
        let walkingDuration = SettingsManager.sharedInstance.defaultWalkingDuration
        
        switch (walkingDuration) {
            
        case let walkingDuration where walkingDuration == 5.0:
            self.miles = 0.25
            break;
            
        case let walkingDuration where walkingDuration == 10.0:
            self.miles = 0.5
            break;
            
        case let walkingDuration where walkingDuration == 15.0:
            self.miles = 0.75
            break;
            
        case let walkingDuration where walkingDuration == 30.0:
            self.miles = 1.5
            break;
            
        case let walkingDuration where walkingDuration == 45.0:
            self.miles = 2.25
            break;
            
        case let walkingDuration where walkingDuration == 60.0:
            self.miles = 3
            break;
            
        default:
            break;
            
        }
        
    }
    
 
    
    private func doTableRefresh() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let countFirstSection = 1
        let countSecondSection = self.categoryArray.count
        
        if (countSecondSection == 0) {
            //     activityIndicatorView.startAnimating()
        }
        else if (countSecondSection >= 9) {
            //      activityIndicatorView.stopAnimating()
            //      activityIndicatorView.hidesWhenStopped = true
        }
        
        if section == 0 {
            return countFirstSection
        }
        
        if section == 1 {
            return countSecondSection
        }
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //   let cell = NSBundle.mainBundle().loadNibNamed("HomeTableViewCell", owner: self, options: nil)[0] as? HomeTableViewCell
        // get a reference to our storyboard cell
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath as IndexPath) as! HomeTableViewCell
        //      cell = (NSBundle.mainBundle().loadNibNamed("HomeTableViewCell", owner: self, options: nil)[0] as? HomeTableViewCell)!
        //     let entry = homeCategories.categories[indexPath.row]
        
        
        if (indexPath.section == 0) {
            let image = UIImage(named: homeCategories.allCategories.imageName)
            cell.categoryImage.image = image
            cell.categoryName.text = homeCategories.allCategories.category
            if (self.overallCount == 1) {
                cell.categoryTipNumber.text = String(self.overallCount) + " Tip"
            }
                
            else {
                cell.categoryTipNumber.text = String(self.overallCount) + " Tips"
            }
            
        }
        
        if (indexPath.section == 1) {
            
            
            let name = self.homeCategories.categories[indexPath.row].category
            cell.categoryName.text = name
            
            let image = UIImage(named: self.homeCategories.categories[indexPath.row].imageName)
            cell.categoryImage.image = image
            
            let count = self.homeCategories.categories[indexPath.row].tipCount
            if (count == 1) {
                cell.categoryTipNumber.text = String(count) + " Tip"
            }
                
            else {
                cell.categoryTipNumber.text = String(count) + " Tips"
            }
            
            
            
            
        }
        
        
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if (indexPath.section == 0) {
            StackObserver.sharedInstance.passedValue = 10
        }
        else {
            // handle tap events
            print("You selected cell #\(indexPath.item)!")
            StackObserver.sharedInstance.passedValue = indexPath.item
        }
        tabBarController!.selectedIndex = 3
        
    }
    
    
    // MARK: LocationService Delegate
    func tracingLocation(_ currentLocation: CLLocation) {
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
       
        if let currentUser = UserDefaults.standard.value(forKey: "uid") as? String {
            let geoFire = GeoFire(firebaseRef: dataService.GEO_USER_REF)
            geoFire?.setLocation(CLLocation(latitude: lat, longitude: lon), forKey: currentUser)
        }
        if !self.didFindLocation {
        self.didFindLocation = true
            self.findNearbyTips()
          //  LocationService.sharedInstance.stopUpdatingLocation()
        }
        
        
       
        
    }
    
    func tracingLocationDidFailWithError(_ error: NSError) {
        print("tracing Location Error : \(error.description)")
    }
    
}
