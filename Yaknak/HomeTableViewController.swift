

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


class HomeTableViewController: UITableViewController {

    var homeCategories = Category()
    let locationManager = CLLocationManager()
    var reachability: Reachability?
    var miles = Double()
    var categoryArray: [AnyObject] = []
    var overallCount = 0
    weak var activityIndicatorView: UIActivityIndicatorView!
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    let dataService = DataService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupReachability(nil, useClosures: true)
        startNotifier()
        
        self.configureNavBar()
        self.setUpTableView()
        self.configureLocationManager()
        self.detectDistance()
   //     self.queryCategories()
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reachability!.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                            name: ReachabilityChangedNotification,
                                                            object: reachability)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavBar() {
        
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 70))
        navLogo.contentMode = .scaleAspectFit
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        self.navigationItem.titleView = navLogo
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    
     func prepareCategoryList() {
    
    
        let entry = homeCategories.categories
        self.categoryArray.removeAll(keepingCapacity: true)
        self.overallCount = 0
        
        dataService.TIP_REF.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount) // I got the expected number of items
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                print(rest.value)
            }
        })
        
        
     /*
        dataService.TIP_REF.queryOrdered(byChild: "category").observe(.childAdded
            , with: { snapshot in
                var newItems: [Tip] = []
                
                for item in snapshot.children {
                    let tip = Tip(snapshot: item as! FIRDataSnapshot)
                    newItems.append(tip)
                }
                
                //    self.items = newItems
                //    self.tableView.reloadData()
        })
        
        
        */
        /*
        let currentLocation = CLLocation(latitude: Location.sharedInstance.currLat!, longitude: Location.sharedInstance.currLong!)
        let geoFire = GeoFire(firebaseRef: dataService.TIP_REF)
        let query = geoFire?.query(at: currentLocation, withRadius: self.miles)
        
        query?.observe(.keyEntered, with: { (string: String?, location: CLLocation?) in
            
            //  print("+ + + + Key '\(key)' entered the search area and is at location '\(location)'")
            //   self.userCount++
            //   self.refreshUI()
        })
*/
 
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
        
    //    self.refreshControl?.addTarget(self, action: #selector(HomeTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    //    self.refreshControl!.backgroundColor = UIColor.clearColor()
    //    self.refreshControl!.tintColor = UIColor.blackColor()
    }
    
    
    private func configureLocationManager() {
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
        }
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
  /*
    private func queryCategories() {
        
        let entry = homeCategories.categories
        self.categoryArray.removeAll(keepingCapacity: true)
        self.overallCount = 0
        self.doTableRefresh()
        
        
        // Get current user
        
        dataService.CURRENT_USER_REF.observe(.value) { (snapshot) in
            
            let user = User(snapshot : snapshot)
            
        }
        
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint: PFGeoPoint?, error: NSError?) in
            //      dispatch_async(dispatch_get_main_queue()) {
            for (index, cat) in entry.enumerate() {
                let query = Tip.query()
                query!.whereKey("category", equalTo: cat.category)
                query!.whereKey("location", nearGeoPoint: geoPoint!, withinMiles: self.miles)
                query!.countObjectsInBackgroundWithBlock({ (count: Int32, error: NSError?) in
                    if (error == nil) {
                        let number = Int(count)
                        cat.tipCount = number
                        self.overallCount += number
                        self.categoryArray.append(entry[index])
                        self.doTableRefresh()
                    }
                    else {
                        //  NSLog("Count request failed - no objects found")
                    }
                })
                
             
            }
            //    }
            //   self.doTableRefresh()
        }
        //   self.doTableRefresh()
    }
    
    */
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
    
}


extension HomeTableViewController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Cannot fetch your location")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
    //    if let newLocation = locations.last {
        
        let newLocation = locations[0]
            
            Location.sharedInstance.currLat = newLocation.coordinate.latitude
            Location.sharedInstance.currLong = newLocation.coordinate.longitude
        
        self.prepareCategoryList()
         locationManager.stopUpdatingLocation()

            
  //      }
            
    //    else {
    //        print("Cannot fetch your location")
    //    }
        
    }
}