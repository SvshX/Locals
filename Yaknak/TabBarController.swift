//
//  TabBarController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Firebase


class TabBarController: UITabBarController {
    
    @IBInspectable var defaultIndex: Int = 2
    
    var button: UIButton = UIButton()
  //  var handle: UInt!
    var user: MyUser!
    var tips = [Tip]()
    var friends = [MyUser]()
    let dataService = DataService()
    var finishedLoading = false
    var profileUpdated = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let centerImage = UIImage(named: Constants.Images.AppIcon) {
        addCenterButtonWithImage(buttonImage: centerImage)
        }
        changeTabToCenterTab(button)
        self.setupAppearance()
        self.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tipsUpdated),
                                               name: NSNotification.Name(rawValue: "tipsUpdated"),
                                               object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func preloadViews() {
        self.setupUser(completion: { (success) in
        
            if success {
            //    _ = self.viewControllers?[4].view
                self.finishedLoading = true
            if let navController = self.viewControllers?[1] as? UINavigationController {
                    navController.topViewController?.view
                }
                
                if self.profileUpdated {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProfile"), object: nil)
                    self.profileUpdated = false
                }
            }
    })
    }
    
    func tipsUpdated() {
    self.finishedLoading = false
    self.profileUpdated = true
    self.preloadViews()
    }
    
    
    private func setupUser(completion: @escaping (Bool) -> ()) {
        
        self.dataService.getCurrentUser { (user) in
            self.user = user
            
            if let tips = user.totalTips {
                
                if let uid = user.key {
                
                if tips > 0 {
                    
                    var tipArray = [Tip]()
                    
                    self.dataService.USER_TIP_REF.child(uid).observeSingleEvent(of: .value, with: { (tipSnap) in
                        
                        for tip in tipSnap.children.allObjects as! [DataSnapshot] {
                            
                            let tipObject = Tip(snapshot: tip)
                            tipArray.append(tipObject)
                            
                        }
                        if !self.finishedLoading {
                            self.tips = tipArray.reversed()
                            self.dataService.getFriends(user, completion: { (friends) in
                                if let friends = friends {
                                    self.friends = friends
                                    completion(true)
                                }
                                else {
                                    completion(false)
                                }
                            })
                        }
                        
                    }, withCancel: { (error) in
                        print(error.localizedDescription)
                    })
                    
                }
                else {
                    if self.tips.count > 0 {
                        self.tips.removeAll()
                    }
                    self.dataService.getFriends(user, completion: { (friends) in
                        if let friends = friends {
                            self.friends = friends
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    })
                    
                }
                
            }
        }
        }
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
                item.title = ""
                item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
            }
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
