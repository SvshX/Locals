//
//  TabBarController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher


class TabBarController: UITabBarController {
    
    @IBInspectable var defaultIndex: Int = 2
    
    var button: UIButton = UIButton()
    var handle: UInt!
    var tipRef: FIRDatabaseReference!
    var currentUserRef: FIRDatabaseReference!
    var user: User!
    var tips = [Tip]()
    let dataService = DataService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let centerImage:UIImage = UIImage(named: Constants.Images.AppIcon)!
        addCenterButtonWithImage(buttonImage: centerImage)
        changeTabToCenterTab(button)
        self.tipRef = dataService.TIP_REF
        self.currentUserRef = dataService.CURRENT_USER_REF
        self.setupAppearance()
        self.delegate = self
        
        //    _ = tabBarController?.viewControllers?[1].view
        
        //    if let tab = self.viewControllers?[4] {
        //    tab.view
        //    }
        
        
        //   if let addView = (viewControllers?[4])! as UIViewController {
        //       addView.view
        //   }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func preloadViews() {
        self.setUpProfileDetails(completion:  { (success) in
        
            if success {
                _ = self.viewControllers?[4].view
                
                if let navController = self.viewControllers?[1] as? UINavigationController {
                    navController.topViewController?.view
                }

            }
    })
    }
    
    
    private func setUpProfileDetails(completion: @escaping (Bool) -> ()) {
        
        self.currentUserRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String : Any] {
                
                self.user = User(snapshot: snapshot)
                
                        if let tips = dictionary["totalTips"] as? Int {
                            
                            if tips > 0 {
                                
                                let myGroup = DispatchGroup()
                                var tipArray = [Tip]()
                                
                                
                                self.handle = self.dataService.USER_TIP_REF.child(snapshot.key).observe(.childAdded, with: { (tipSnap) in
                                    
                                    myGroup.enter()
                                    
                                    if (tipSnap.value as? [String : Any]) != nil {
                                        let tipObject = Tip(snapshot: tipSnap)
                                        tipArray.append(tipObject)
                                    }
                                    
                                    myGroup.leave()
                                    
                                    myGroup.notify(queue: DispatchQueue.main, execute: {
                                        self.tips = tipArray.reversed()
                                        if (self.tips.count == tips) {
                                         completion(true)
                                        }
                                    })
                                  
                                    
                                })
                                
                                
                            }
                           
                        }
                
            }
            
        })
        
    }
    
    
    
    func setupAppearance() {
        
        selectedIndex = defaultIndex
        UITabBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().barTintColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
        UITabBar.appearance().selectionIndicatorImage = self.makeImageWithColorAndSize(color: UIColor.smokeWhiteColor(), size: CGSize(tabBar.frame.width/5, tabBar.frame.height))
        UITabBar.appearance().layer.borderWidth = 1
        UITabBar.appearance().layer.borderColor = UIColor.black.cgColor
        tabBar.clipsToBounds = false
        tabBar.isTranslucent = false
        
        if self.tabBar.items != nil {
            // Uses the original colors for images, so they aren't rendered as grey automatically.
            for item in self.tabBar.items! as [UITabBarItem] {
                //     if let image = item.image {
                //         item.image = image.imageWithRenderingMode(.AlwaysOriginal)
                //     }
                item.title = ""
                item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
            }
            
        }
            
        else {
            //  NSLog(Constants.Logs.NoItems)
        }
    }
    
    
    func addCenterButtonWithImage(buttonImage: UIImage) {
        
        let frame = CGRect(0.0, 0.0, buttonImage.size.width/2, buttonImage.size.height/2)
        button = UIButton(frame: frame)
        button.setBackgroundImage(buttonImage, for: UIControlState.normal)
        button.contentMode = .scaleAspectFit
        
        var center: CGPoint = self.tabBar.center
        center.y = center.y - buttonImage.size.height / 2
        center.x = center.x - buttonImage.size.width / 2
        button.center = self.tabBar.center
        button.addTarget(self, action: #selector(TabBarController.changeTabToCenterTab(_:)), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(button)
        
    }
    
    
    func changeTabToCenterTab(_ sender: UIButton) {
        
        tabBarController?.selectedIndex = 2
        sender.isUserInteractionEnabled = false
        
    }
    
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    
}


extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
