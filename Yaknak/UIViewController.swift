//
//  UIViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 27/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

extension UIViewController {
    
    
    public var isVisible: Bool {
        if isViewLoaded {
            return view.window != nil
        }
        return false
    }
    
    public var isTopViewController: Bool {
        if self.navigationController != nil {
            return self.navigationController?.visibleViewController === self
        } else if self.tabBarController != nil {
            return self.tabBarController?.selectedViewController == self && self.presentedViewController == nil
        } else {
            return self.presentedViewController == nil && self.isVisible
        }
    }
    
            
func topMostViewController() -> UIViewController {
    // Handling Modal views
    if let presentedViewController = self.presentedViewController {
        return presentedViewController.topMostViewController()
    }
        // Handling UIViewController's added as subviews to some other views.
    else {
        for view in self.view.subviews
        {
            // Key property which most of us are unaware of / rarely use.
            if let subViewController = view.next {
                if subViewController is UIViewController {
                    let viewController = subViewController as! UIViewController
                    return viewController.topMostViewController()
                }
            }
        }
        return self
    }
}
    
    
    func hideKeyboardOnTap(_ selector: Selector) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

}
