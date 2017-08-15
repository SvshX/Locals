//
//  AgreementViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/01/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

class AgreementViewController: UIViewController {
    
    
    @IBOutlet weak var agreementText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
      
        configureNavBar()
        agreementText.text = Constants.Blocks.Agreement
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavBar() {
      
      guard let navC = navigationController else {return}
         let navHeight = navC.navigationBar.frame.size.height
            let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: navHeight / 2))
            navLogo.contentMode = .scaleAspectFill
            let image = UIImage(named: Constants.Images.NavImage)
            navLogo.image = image
            navC.navigationBar.setTitleVerticalPositionAdjustment(-3.0, for: .default)
            navigationItem.titleView = navLogo
            navigationItem.setHidesBackButton(false, animated: false)
            let backImage = UIImage(named: Constants.Images.BackButton)
            
            let newBackButton = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
            newBackButton.tintColor = UIColor.primary()
            navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }

}
