

//
//  HomeTableViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
//import ReachabilitySwift
import CoreLocation
import MBProgressHUD
import Foundation
import FirebaseDatabase
import GeoFire
import Firebase
import FirebaseAuth


class HomeTableViewController: UITableViewController {
    
    var dashboardCategories = Dashboard()
    var miles = Double()
    var categoryArray: [Dashboard.Entry] = []
    var overallCount = 0
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    let dataService = DataService()
    var handle: UInt!
    var categoryRef: FIRDatabaseReference!
    var didFindLocation: Bool = false
    var didAnimateTable: Bool!
    var emptyView: UIView!
    let toolTip = ToolTip()
    var timer: Timer? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if !appDelegate.isReachable {
                NoNetworkOverlay.show("Nooo connection :(")
            }
        }
        self.configureNavBar()
        self.didAnimateTable = false
        self.setUpTableView()
        self.categoryRef = dataService.CATEGORY_REF

        if (UserDefaults.standard.bool(forKey: "isTracingLocationEnabled")) {
        LocationService.sharedInstance.startUpdatingLocation()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HomeTableViewController.updateCategoryList),
                                               name: NSNotification.Name(rawValue: "distanceChanged"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HomeTableViewController.updateCategoryList),
                                               name: NSNotification.Name(rawValue: "tipsUpdated"),
                                               object: nil)
 
        
        LocationService.sharedInstance.onLocationTracingEnabled = { enabled in
            if enabled {
            print("tracing location enabled/received...")
            LocationService.sharedInstance.startUpdatingLocation()
            }
            else {
            print("tracing location denied...")
                self.prepareTable(keys: [], completion: { (Void) in
                     self.doTableRefresh()
                })
            }
        }
        
        LocationService.sharedInstance.onTracingLocation = { currentLocation in
        
            print("Location is being tracked...")
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            
         
            if !self.didFindLocation {
                self.didFindLocation = true
                self.findNearbyTips(completionHandler: { success in
                    
                    if success {
                        print("Category list loaded...")
                    }
                    self.doTableRefresh()
                    
                })
                
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
         }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
       
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (UserDefaults.standard.bool(forKey: "isTracingLocationEnabled")) {
        LocationService.sharedInstance.stopUpdatingLocation()
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
    
    func toggleView(_ showTable: Bool) {
    
        if showTable {
            self.emptyView.isHidden = true
            self.emptyView.removeFromSuperview()
        }
        else {
            self.emptyView.isHidden = false
            self.view.addSubview(emptyView)
            self.view.bringSubview(toFront: emptyView)
        }
    
    }
    
   
    
    func userAlreadyExists() -> Bool {
        return UserDefaults.standard.object(forKey: "uid") != nil
    }
    
    
    
    func findNearbyTips(completionHandler: @escaping ((_ success: Bool) -> Void)) {
        
        var keys = [String]()
        let geo = GeoFire(firebaseRef: dataService.GEO_TIP_REF)
        if let lat = LocationService.sharedInstance.currentLocation?.coordinate.latitude {
            if let long = LocationService.sharedInstance.currentLocation?.coordinate.longitude {
        let myLocation = CLLocation(latitude: lat, longitude: long)
        if let radius = LocationService.sharedInstance.determineRadius() {
        let circleQuery = geo!.query(at: myLocation, withRadius: radius)  // radius is in km
        
        circleQuery!.observe(.keyEntered, with: { (key, location) in
            
            if let key = key {
            keys.append(key)
            }
           
        })
    
        //Execute this code once GeoFire completes the query!
        circleQuery?.observeReady ({
            self.prepareTable(keys: keys, completion: { (Void) in
           // self.doTableRefresh()
                completionHandler(true)
            })
        
        })
    }
    }
}
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
            if (snapshot.hasChildren()) {
            
                for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        
                        if (keys.contains(child.key)) {
                            cat.tipCount += 1
                            self.overallCount += 1
                        }
                        else {
                           // print("no match...")
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
    
    func updateCategoryList() {
    self.setLoadingOverlay()
        self.findNearbyTips(completionHandler: { success in
        
            if success {
            LoadingOverlay.shared.hideOverlayView()
            }
            self.doTableRefresh()
        
        })
    }
    
    
    private func setLoadingOverlay() {
        
        if let navVC = self.navigationController {
        LoadingOverlay.shared.setSize(width: navVC.view.frame.width, height: navVC.view.frame.height)
        let navBarHeight = navVC.navigationBar.frame.height
        LoadingOverlay.shared.reCenterIndicator(view: navVC.view, navBarHeight: navBarHeight)
        LoadingOverlay.shared.showOverlay(view: navVC.view)
        }
    }
    
    
    private func setUpTableView() {
        
        self.tableView.register(UINib(nibName: Constants.NibNames.HomeTable, bundle: nil), forCellReuseIdentifier: Constants.NibNames.HomeTable)
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
     //   self.tableView.isHidden = true
        self.emptyView = UIView(frame: CGRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.emptyView.backgroundColor = UIColor.white
        self.toggleView(false)
        self.setLoadingOverlay()
        
    }
    

    
    func popUpPrompt() {
        let alertController = UIAlertController()
        alertController.networkAlert(Constants.NetworkConnection.NetworkPromptMessage)
    }
    
    
    
    private func detectDistance() {
        
        let walkingDuration = SettingsManager.sharedInstance.defaultWalkingDuration
        
        switch (walkingDuration) {
            
        case let walkingDuration where walkingDuration == 5:
            self.miles = 0.25
            break
            
        case let walkingDuration where walkingDuration == 10:
            self.miles = 0.5
            break
            
        case let walkingDuration where walkingDuration == 15:
            self.miles = 0.75
            break
            
        case let walkingDuration where walkingDuration == 30:
            self.miles = 1.5
            break
            
        case let walkingDuration where walkingDuration == 45:
            self.miles = 2.25
            break
            
        case let walkingDuration where walkingDuration == 60:
            self.miles = 3
            break
            
        default:
            break
            
        }
    
    }
    
    
    
    private func doTableRefresh() {
        DispatchQueue.main.async {
            self.tableView.isHidden = false
            self.toggleView(true)
            self.tableView.reloadData()
            if (!self.didAnimateTable) {
            self.animateTable()
            self.didAnimateTable = true
                LoadingOverlay.shared.hideOverlayView()
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    if appDelegate.firstLaunch.isFirstLaunch {
                        self.showToolTip()
                    }
                }
            }
        }
    }
    
    
    private func animateTable() {
        
            let cells = tableView.visibleCells
            let tableHeight: CGFloat = tableView.bounds.size.height
            
            for i in cells {
                let cell: UITableViewCell = i as UITableViewCell
                cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            }
            
            var index = 0
            
            for a in cells {
                
                let cell: UITableViewCell = a as UITableViewCell
                UIView.animate(withDuration: 1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0);
                }, completion: nil)
                
                index += 1
            }
        
    }
    
    
    private func showToolTip() {
        if let navVC = self.navigationController {
      ToolTipsHelper.sharedInstance.showToolTip("☝️ " + "Tap to see what's nearby", navVC.view, CGRect(0, 0, width, height), ToolTipDirection.none)
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let countFirstSection = 1
        let countSecondSection = self.categoryArray.count
        
        
        if countSecondSection >= 10 {
    //    LoadingOverlay.shared.hideOverlayView()
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
        
        cell.selectionStyle = .none
        
        if (indexPath.section == 0) {
            

            let image = UIImage(named: "everything_home")
            cell.categoryImage.image = image
            cell.categoryName.text = "Everything"
            if (self.overallCount == 1) {
                cell.categoryTipNumber.text = "\(self.overallCount) Tip"
            }
                
            else {
                cell.categoryTipNumber.text = "\(self.overallCount) Tips"
            }
            
        }
        
        if (indexPath.section == 1) {
            
            
            let name = self.categoryArray[indexPath.row].category
            cell.categoryName.text = name
            
            let image = UIImage(named: self.categoryArray[indexPath.row].imageName)
            cell.categoryImage.image = image
            
            let count = self.categoryArray[indexPath.row].tipCount as Int
            if (count == 1) {
                cell.categoryTipNumber.text = "\(count) Tip"
            }
                
            else {
                cell.categoryTipNumber.text = "\(count) Tips"
            }
            
        }
    
        return cell
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if (indexPath.section == 0) {
            StackObserver.sharedInstance.categorySelected = 10
        }
        else {
            // handle tap events
            print("You selected cell #\(indexPath.item)!")
            StackObserver.sharedInstance.categorySelected = indexPath.item
        }
        tabBarController!.selectedIndex = 3
        
    }
    
}
