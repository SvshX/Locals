//
//  TermsViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    
    
    @IBOutlet weak var termsView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        self.termsView.text = Constants.Blocks.Terms
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
