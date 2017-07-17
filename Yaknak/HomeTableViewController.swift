

//
//  HomeTableViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD
import Foundation




class HomeTableViewController: UITableViewController, CAAnimationDelegate {
    
    private var dashboardCategories = Dashboard()
    private var miles = Double()
    private var categoryArray: [Dashboard.Entry] = []
    private var overallCount: Int = 0
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    private let dataService = DataService()
  //  private var emptyView: UIView!
    private var splashView: SplashView!
    private var ellipsisTimer: Timer?
    private var isInitialLoad: Bool!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavBar()
        self.setupTableView()
        self.isInitialLoad = true
        
        
        guard let tabC = self.tabBarController as? TabBarController else {return}
        tabC.onReloadDashboard = { [weak self] (categories, overallCount) in
        
            if !(self?.isInitialLoad)! {
            self?.setLoadingOverlay()
            }
            self?.overallCount = 0
            self?.categoryArray.removeAll()
            self?.overallCount = overallCount
            self?.categoryArray = categories
            self?.doTableRefresh()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavBar() {
        
        let navLabel = UILabel()
        navLabel.contentMode = .scaleAspectFill
        navLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 70)
        navLabel.text = "Nearby"
        navLabel.textColor = UIColor.secondaryTextColor()
        self.navigationItem.titleView = navLabel
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    
    func removeSplash() {
        self.splashView.removeFromSuperview()
    }
    
    
    private func setupTableView() {
        
        self.tableView.register(UINib(nibName: Constants.NibNames.HomeTable, bundle: nil), forCellReuseIdentifier: Constants.NibNames.HomeTable)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.createAnimationView()
    }
    
    private func setLoadingOverlay() {
        
        if let navVC = self.navigationController {
            LoadingOverlay.shared.setSize(width: navVC.view.frame.width, height: navVC.view.frame.height)
            let navBarHeight = navVC.navigationBar.frame.height
            LoadingOverlay.shared.reCenterIndicator(view: navVC.view, navBarHeight: navBarHeight)
            LoadingOverlay.shared.showOverlay(view: navVC.view)
        }
    }
    
    
    private func createAnimationView() {
        
        guard let window = UIApplication.shared.keyWindow else {return}
        self.splashView = Bundle.main.loadNibNamed("SplashView", owner: self, options: nil)![0] as? SplashView
        
        window.addSubview(self.splashView)
        self.splashView.frame = UIScreen.main.bounds
        window.bringSubview(toFront: self.splashView)
        
        var imageNames = ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg", "8.jpg", "9.jpg", "10.jpg", "11.jpg", "11.jpg", "11.jpg", "11.jpg", "11.jpg", "11.jpg"]
        
        
        var images = [CGImage]()
        
        for i in 0..<imageNames.count {
            images.append(UIImage(named: imageNames[i])!.cgImage!)
        }
        
        
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "contents")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 3.0
        keyFrameAnimation.calculationMode = kCAAnimationDiscrete
        keyFrameAnimation.isRemovedOnCompletion = false
        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        //   keyFrameAnimation.values = [1.0, 0.9, 1.0, 0.9, 1.0, 0.9, 1.0, 0.9]
        keyFrameAnimation.values = images
        keyFrameAnimation.repeatCount = .infinity
        keyFrameAnimation.fillMode = kCAFillModeForwards
        keyFrameAnimation.keyTimes = [0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2, 0.22, 0.6, 0.7, 0.8, 0.9, 1.0]
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        self.splashView.animatingImageview.layer.add(keyFrameAnimation, forKey: "contents")
        
        
        ellipsisTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SplashScreenViewController.updateLabelEllipsis(_:)), userInfo: nil, repeats: true)
        
    }
    
   
    func animationDidStart(_ anim: CAAnimation) {}
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        ellipsisTimer?.invalidate()
        ellipsisTimer = nil
    }
    
    
    func updateLabelEllipsis(_ timer: Timer) {
        let messageText: String = self.splashView.dotLabel.text!
        let dotCount: Int = (self.splashView.dotLabel.text?.characters.count)! - messageText.replacingOccurrences(of: ".", with: "").characters.count + 1
        self.splashView.dotLabel.text = "  Finding tips"
        var addOn: String = "."
        if dotCount < 4 {
            addOn = "".padding(toLength: dotCount, withPad: ".", startingAt: 0)
        }
        else {
            
        }
        splashView.dotLabel.text = self.splashView.dotLabel.text!.appending(addOn)
    }
    
    
    
    
    private func doTableRefresh() {
        
        DispatchQueue.main.async {
            self.tableView.isHidden = false
            if self.isInitialLoad {
            self.removeSplash()
            }
            else {
            LoadingOverlay.shared.hideOverlayView()
            }
            self.tableView.reloadData()
            print("Dashboard loaded...")
            if self.isInitialLoad {
            self.animateTable()
                self.isInitialLoad = false
            }
            /*
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    if appDelegate.firstLaunch.isFirstLaunch {
                        self.showToolTip()
                    }
                }
            */
           
           // LoadingOverlay.shared.hideOverlayView()
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
        
        if section == 0 {
            return countFirstSection
        }
        
        if section == 1 {
            return countSecondSection
        }
        
        return 1
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath as IndexPath) as! HomeTableViewCell
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
            StackObserver.shared.categorySelected = 10
        }
        else {
            // handle tap events
            print("You selected cell #\(indexPath.item)!")
            StackObserver.shared.categorySelected = indexPath.item
        }
        guard let tabC = tabBarController else {return}
        tabC.selectedIndex = 3
        
    }
    
}
