

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


class HomeTableViewController: UITableViewController {
    
    var dashboardCategories = Dashboard()
    var reachability: Reachability?
    var miles = Double()
 //   var categories = [Category]()
    var categoryArray: [Dashboard.Entry] = []
    var overallCount = 0
 //   weak var activityIndicatorView: UIActivityIndicatorView!
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    let dataService = DataService()
    var handle: UInt!
 //   var tipRef: FIRDatabaseReference!
    var categoryRef: FIRDatabaseReference!
    var didFindLocation: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupReachability(nil, useClosures: true)
        startNotifier()
        self.configureNavBar()
        self.setUpTableView()
    //    LocationService.sharedInstance.delegate = self
   //     self.tipRef = dataService.TIP_REF
        self.categoryRef = dataService.CATEGORY_REF
        
        if LocationService.sharedInstance.locationAuthorised() {
            LocationService.sharedInstance.startUpdatingLocation()
        }
        
        LocationService.sharedInstance.onPermissionReceived = { received in
        print("Location permission received...")
            LocationService.sharedInstance.startUpdatingLocation()
        }
        
        LocationService.sharedInstance.onTracingLocation = { currentLocation in
        
            print("Location is being tracked...")
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            
            
            if !self.didFindLocation {
                self.didFindLocation = true
                self.findNearbyTips()
                
            }
            
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
        /*
        if (self.didFindLocation) {
            self.findNearbyTips()
          //  self.didFindLocation = false
        }
 
     //   self.didFindLocation = false
        if LocationService.sharedInstance.locationAuthorised() {
        LocationService.sharedInstance.startUpdatingLocation()
        }
 */
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
     //   if let handle = handle {
     //       tipRef.removeObserver(withHandle: handle)
     //   }
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
    
    func userAlreadyExists() -> Bool {
        return UserDefaults.standard.object(forKey: "uid") != nil
    }
    
    
    
    func findNearbyTips() {
        
        self.detectDistance()
        
   //     self.tableView.activityIndicatorView.startAnimating()
        
        var keys = [String]()
        let geo = GeoFire(firebaseRef: dataService.GEO_TIP_REF)
        let myLocation = CLLocation(latitude: (LocationService.sharedInstance.currentLocation?.coordinate.latitude)!, longitude: (LocationService.sharedInstance.currentLocation?.coordinate.longitude)!)
        let distanceInKM = self.miles * 1609.344 / 1000
        let circleQuery = geo!.query(at: myLocation, withRadius: distanceInKM)  // radius is in km
        
        circleQuery!.observe(.keyEntered, with: { (key, location) in
            
        //    keys.removeAll()
            keys.append(key!)
            //      if !self.nearbyUsers.contains(key!) && key! != FIRAuth.auth()!.currentUser!.uid {
            //          self.nearbyUsers.append(key!)
            //      }
            
        })
        
        //Execute this code once GeoFire completes the query!
        circleQuery?.observeReady ({
            self.prepareTable(keys: keys, completion: { (Void) in
            self.tableView.reloadData()
            })
        
        })
        
    }
    
    
    private func prepareTable(keys: [String], completion: @escaping (Void) -> ()) {
        
        let entry = dashboardCategories.categories
        self.categoryArray.removeAll(keepingCapacity: true)
        self.overallCount = 0
        let group = DispatchGroup()
        
      
        for (index, cat) in entry.enumerated() {
            
             cat.tipCount = 0
            
              group.enter()
            self.categoryRef.child(cat.category.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let i = snapshot.childrenCount
            print(i)
            if (keys.count > 0 && snapshot.hasChildren()) {
            
                for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        
                        if (keys.contains(child.key)) {
                            cat.tipCount += 1
                            self.overallCount += 1
                        }
                        else {
                            print("no match...")
                        }
            
                }
                
            }
            self.categoryArray.append(entry[index])
                 group.leave()
           // self.doTableRefresh()
        })
            
        }
       
        
        group.notify(queue: DispatchQueue.main) { 
             completion()
        }
       
    }
    
    
    
    private func setUpTableView() {
        
        self.tableView.register(UINib(nibName: Constants.NibNames.HomeTable, bundle: nil), forCellReuseIdentifier: Constants.NibNames.HomeTable)
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        LoadingOverlay.shared.setSize(width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!)
        let navBarHeight = self.navigationController!.navigationBar.frame.height
        LoadingOverlay.shared.reCenterIndicator(view: (self.navigationController?.view)!, navBarHeight: navBarHeight)
        LoadingOverlay.shared.showOverlay(view: (self.navigationController?.view)!)
        
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
        let alertController = UIAlertController()
        alertController.networkAlert(title: Constants.NetworkConnection.NetworkPromptTitle, message: Constants.NetworkConnection.NetworkPromptMessage)
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
            
        }
        else if (countSecondSection >= 10 && LocationService.sharedInstance.locationAuthorised()) {
            
            LoadingOverlay.shared.hideOverlayView()
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
            let image = UIImage(named: "everything_home")
            cell.categoryImage.image = image
            cell.categoryName.text = "Everything"
            if (self.overallCount == 1) {
                cell.categoryTipNumber.text = String(self.overallCount) + " Tip"
            }
                
            else {
                cell.categoryTipNumber.text = String(self.overallCount) + " Tips"
            }
            
        }
        
        if (indexPath.section == 1) {
            
            
            let name = self.categoryArray[indexPath.row].category
            cell.categoryName.text = name
            
            let image = UIImage(named: self.categoryArray[indexPath.row].imageName)
            cell.categoryImage.image = image
            
            let count = self.categoryArray[indexPath.row].tipCount as Int
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
    
  /*
    // MARK: LocationService Delegate
    func tracingLocation(_ currentLocation: CLLocation) {
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        
      
        if !self.didFindLocation {
            self.didFindLocation = true
            self.findNearbyTips()
            
        }
        
        if let currentUser = UserDefaults.standard.value(forKey: "uid") as? String {
            let geoFire = GeoFire(firebaseRef: dataService.GEO_USER_REF)
            geoFire?.setLocation(CLLocation(latitude: lat, longitude: lon), forKey: currentUser)
        }
        
        
        
    }
    
    func tracingLocationDidFailWithError(_ error: NSError) {
        print("tracing Location Error : \(error.description)")
    }
    
    func permissionReceived(_ received: Bool) {
        
        if received {
         LocationService.sharedInstance.startUpdatingLocation()
         self.findNearbyTips()
        }
    }
    */
    
}
