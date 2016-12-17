//
//  UIAlertController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import UIKit


extension UIAlertController {
    
    func defaultAlert(title: String, message: String) {
    
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
 
        let titleMutableString = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])

        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        alertController.show()
    
    }
    
    func reportAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleMutableString = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { action in
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
            NSFontAttributeName : UIFont.systemFont(ofSize: 17),
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
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(defaultAction)
        alertController.addAction(cancel)
        alertController.show()

    
    }
    
    func networkAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleMutableString = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
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
