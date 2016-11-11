//
//  PolicyViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class PolicyViewController: UIViewController {

    
    @IBOutlet weak var policyText: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavBar()
        self.policyText.text = Constants.Blocks.Privacy
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func configureNavBar() {
        
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        navLogo.contentMode = .scaleAspectFit
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        self.navigationItem.titleView = navLogo
        self.navigationItem.setHidesBackButton(false, animated: false)
        let backImage = UIImage(named: Constants.Images.BackButton)
        
        let newBackButton = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(PolicyViewController.goBack))
        newBackButton.tintColor = UIColor.primaryColor()
        navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    func goBack() {
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
