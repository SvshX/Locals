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
    
    
    convenience init(_ hex: UInt) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func primary() -> UIColor {
        return UIColor(red: 227.0/255.0, green: 19.0/255.0, blue: 63.0/255.0, alpha:1);
    }
    
    class func primaryText() -> UIColor {
        return UIColor(red: 41.0/255.0, green: 47.0/255.0, blue: 51.0/255.0, alpha:1);
        
    }
    
    class func secondaryText() -> UIColor {
        return UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 159.0/255.0, alpha:1);
    }
    
    class func tertiary() -> UIColor {
        return UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha:1);
    }
    
    class func smokeWhite() -> UIColor {
        return UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha:1);
    }
    
    class func darkRed() -> UIColor {
        return UIColor(red: 136.0/255.0, green: 11.0/255.0, blue: 37.0/255.0, alpha: 1);
        
    }
    
    
    class func randomColor() -> UIColor {
        
        let hue = CGFloat(arc4random_uniform(100)) / 100
        let saturation = CGFloat(arc4random_uniform(100)) / 100
        let brightness = CGFloat(arc4random_uniform(100)) / 100
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    
    
    class func routeColor(with category: String) -> UIColor {
        
        var color = UIColor()
        
        switch (category) {
            
        case "eat":
            color = RouteColors.eat
            break
            
        case "drink":
            color = RouteColors.drink
            break
            
        case "dance":
            color = RouteColors.dance
            break
            
        case "free":
            color = RouteColors.free
            break
            
        case "coffee":
            color = RouteColors.coffee
            break
            
        case "shop":
            color = RouteColors.shop
            break
            
        case "deals":
            color = RouteColors.deals
            break
            
        case "outdoors":
            color = RouteColors.outdoors
            break
            
        case "watch":
            color = RouteColors.watch
            break
            
        case "special":
            color = RouteColors.special
            break
            
        default:
            break
            
        }
        return color
    }
    
    
struct RouteColors {
    static var eat: UIColor  { return UIColor(red: 151/255, green: 78/255, blue: 255/255, alpha: 1) }
    static var drink: UIColor { return UIColor(red: 0/255, green: 51/255, blue: 204/255, alpha: 1) }
    static var dance: UIColor { return UIColor(red: 0/255, green: 118/255, blue: 255/255, alpha: 1) }
    static var free: UIColor { return UIColor(red: 0/255, green: 176/255, blue: 80/255, alpha: 1) }
    static var coffee: UIColor { return UIColor(red: 0/255, green: 174/255, blue: 162/255, alpha: 1) }
    static var shop: UIColor { return UIColor(red: 255/255, green: 150/255, blue: 0/255, alpha: 1) }
    static var deals: UIColor { return UIColor(red: 242/255, green: 204/255, blue: 61/255, alpha: 1) }
    static var outdoors: UIColor { return UIColor(red: 255/255, green: 56/255, blue: 37/255, alpha: 1) }
    static var watch: UIColor { return UIColor(red: 255/255, green: 40/255, blue: 81/255, alpha: 1) }
    static var special: UIColor { return UIColor(red: 41/255, green: 47/255, blue: 51/255, alpha: 1) }
        }
    
    
}

