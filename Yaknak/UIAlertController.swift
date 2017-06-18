//
//  UIAlertController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import UIKit
import Firebase


extension UIAlertController {
    
    func defaultAlert(_ title: String?, _ message: String) {
    
      
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
 
        if title != nil {
            if let fullTitle = title {
        let titleMutableString = NSAttributedString(string: fullTitle, attributes: [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
      
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
            }
        }
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])

        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: Constants.Notifications.GenericOKTitle, style: .cancel, handler: nil)
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        alertController.show()
    
    }
    
    
    func tipAddedAlert(_ title: String?, _ message: String, _ showProfile: Bool) {
        
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if title != nil {
            if let fullTitle = title {
                let titleMutableString = NSAttributedString(string: fullTitle, attributes: [
                    NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17),
                    NSForegroundColorAttributeName : UIColor.primaryTextColor()
                    ])
                
                alertController.setValue(titleMutableString, forKey: "attributedTitle")
            }
        }
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: Constants.Notifications.GenericOKTitle, style: .default) { action in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "tipsUpdated"), object: nil)
            self.dismiss(animated: true, completion: nil)
            if showProfile {
            self.tabBarController?.selectedIndex = 1
            }
            
        }
        
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        alertController.show()
        
    }
    
    
    func verificationAlert(title: String, message: String, user: User) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleMutableString = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        let action = UIAlertAction(title: "Yes", style: .default) { (result : UIAlertAction) -> Void in
            
        user.sendEmailVerification(completion: { (error) in
            
            if error == nil {
                let alert = UIAlertController()
                alert.defaultAlert(nil, Constants.Notifications.VerifyEmailMessage)
                
            }
            else {
                if let error = error {
                 print(error.localizedDescription)
                }
               
                
            }
            
        })
        }
        
        let cancelAction = UIAlertAction(title: Constants.Notifications.GenericCancelTitle, style: .cancel, handler: nil)
        action.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        cancelAction.setValue(UIColor.primaryTextColor(), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(action)
        alertController.preferredAction = action
        alertController.show()
    }
    
    func reportAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleMutableString = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: Constants.Notifications.GenericOKTitle, style: .default) { action in
            self.dismiss(animated: true, completion: nil)
            self.tabBarController?.selectedIndex = 2
        }
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        alertController.show()
        
    }
    
    func promptRedirectToSettings(title: String, message: String) {
    
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleMutableString = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: "Go to settings", style: .default) { action in
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
            self.dismiss(animated: true, completion: nil)
            
        }
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        let cancel = UIAlertAction(title: Constants.Notifications.GenericCancelTitle, style: .cancel)
        cancel.setValue(UIColor.primaryTextColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        alertController.addAction(cancel)
        alertController.preferredAction = defaultAction
        alertController.show()

    
    }
    
    func networkAlert(_ message: String) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: Constants.NetworkConnection.RetryText, style: .cancel, handler: nil)
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        alertController.show()
        
    }
    
    
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else
            if let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion)
        }
    }
}
