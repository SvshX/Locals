

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




class HomeTableViewController: UITableViewController {
    
    private var dashboardCategories = Dashboard()
    private var miles = Double()
    private var categoryArray: [Dashboard.Entry] = []
    private var overallCount: Int = 0
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    private let dataService = DataService()
    private var emptyView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavBar()
        self.setupTableView()
            
        guard let tabController = self.tabBarController as? TabBarController else {return}
            tabController.onReloadDashboard = { (categories, overallCount, animateTable) in
            
                self.toggleView(false)
                self.setLoadingOverlay()
                self.overallCount = 0
                self.categoryArray.removeAll()
                self.overallCount = overallCount
                self.categoryArray = categories
                self.doTableRefresh(animateTable)
            
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
    
    
    private func setLoadingOverlay() {
        
        if let navVC = self.navigationController {
        LoadingOverlay.shared.setSize(width: navVC.view.frame.width, height: navVC.view.frame.height)
        let navBarHeight = navVC.navigationBar.frame.height
        LoadingOverlay.shared.reCenterIndicator(view: navVC.view, navBarHeight: navBarHeight)
        LoadingOverlay.shared.showOverlay(view: navVC.view)
        }
    }
    
    
    private func setupTableView() {
        
        self.tableView.register(UINib(nibName: Constants.NibNames.HomeTable, bundle: nil), forCellReuseIdentifier: Constants.NibNames.HomeTable)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.emptyView = UIView(frame: CGRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        self.emptyView.backgroundColor = UIColor.white
        self.toggleView(false)
        self.setLoadingOverlay()
        //  self.doTableRefresh(true)
    }
    
    
    
    private func doTableRefresh(_ animateTable: Bool) {
        
        DispatchQueue.main.async {
            self.tableView.isHidden = false
            self.toggleView(true)
            self.tableView.reloadData()
            print("Dashboard loaded...")
            if animateTable {
            self.animateTable()
            }
            /*
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    if appDelegate.firstLaunch.isFirstLaunch {
                        self.showToolTip()
                    }
                }
            */
            LoadingOverlay.shared.hideOverlayView()
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
            StackObserver.sharedInstance.categorySelected = 10
        }
        else {
            // handle tap events
            print("You selected cell #\(indexPath.item)!")
            StackObserver.sharedInstance.categorySelected = indexPath.item
        }
        guard let tabC = tabBarController else {return}
        tabC.selectedIndex = 3
        
    }
    
}

/*
extension HomeTableViewController: DashboardDelegate {

    func onReloadDashboard(_ animateTable: Bool) {
        reloadDashboard(animateTable)
    }

}
*/
