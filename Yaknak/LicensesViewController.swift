//
//  LicensesViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 10/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class LicensesViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var byLine: UITextView!
    
    
    struct Libs {
        var sectionName: String!
        var sectionContent: [String]!
    }
    
  var libArray: [Libs] = []

    let contentOne = Constants.Licenses.ONE
    let contentTwo = Constants.Licenses.TWO
    let contentThree = Constants.Licenses.THREE
    let contentFour = Constants.Licenses.FOUR
    let contentFive = Constants.Licenses.FIVE
    let contentSix = Constants.Licenses.SIX
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        byLine.textContainerInset = UIEdgeInsets.zero
        byLine.textContainer.lineFragmentPadding = 0
        configureNavBar()
        
        libArray = [Libs(sectionName: "FBSDKLoginKit", sectionContent: [contentOne]), Libs(sectionName: "FBSDKCoreKit", sectionContent: [contentTwo]), Libs(sectionName: "MBProgressHUD", sectionContent: [contentThree]), Libs(sectionName: "HTHorizontalSelectionList", sectionContent: [contentFour]), Libs(sectionName: "NVActivityIndicatorView", sectionContent: [contentFive]), Libs(sectionName: "Kingfisher", sectionContent: [contentSix])]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func configureNavBar() {
        
        if let navHeight = navigationController?.navigationBar.frame.size.height {
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: navHeight / 2))
        navLogo.contentMode = .scaleAspectFill
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(-3.0, for: .default)
        self.navigationItem.titleView = navLogo
        self.navigationItem.setHidesBackButton(false, animated: false)
        let backImage = UIImage(named: Constants.Images.BackButton)
        
        let newBackButton = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.goBack))
        newBackButton.tintColor = UIColor.primary()
        navigationItem.leftBarButtonItem = newBackButton
        }
        
    }
    
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
  
}


extension LicensesViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return libArray[section].sectionContent.count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return libArray.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return libArray[section].sectionName
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    
    let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    header.contentView.backgroundColor = UIColor.smokeWhite()
    header.textLabel!.textColor = UIColor.primaryText()
    header.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
    
  }

}

extension LicensesViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.LicenseIdentifier, for: indexPath as IndexPath) as UITableViewCell
    cell.textLabel?.text = libArray[indexPath.section].sectionContent[indexPath.row]
    cell.textLabel?.textColor = UIColor.secondaryText()
    cell.textLabel?.font = UIFont.systemFont(ofSize: 13.0)
    
    cell.contentView.setNeedsLayout()
    cell.contentView.layoutIfNeeded()
    
    return cell
  }

}
