//
//  UIColor.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class func primaryColor() -> UIColor {
        return UIColor(red: 227.0/255.0, green: 19.0/255.0, blue: 63.0/255.0, alpha:1);
    }
    
    class func primaryTextColor() -> UIColor {
        return UIColor(red: 41.0/255.0, green: 47.0/255.0, blue: 51.0/255.0, alpha:1);
        
    }
    
    class func secondaryTextColor() -> UIColor {
        return UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 159.0/255.0, alpha:1);
    }
    
    class func tertiaryColor() -> UIColor {
        return UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha:1);
    }
    
    class func smokeWhiteColor() -> UIColor {
        return UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha:1);
    }
    
    class func darkRedColor() -> UIColor {
        return UIColor(red: 136.0/255.0, green: 11.0/255.0, blue: 37.0/255.0, alpha: 1);
        
    }
}

