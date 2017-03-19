//
//  UILabel.swift
//  Yaknak
//
//  Created by Sascha Melcher on 19/03/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import UIKit


extension NSMutableAttributedString {
    func bold(_ text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 13)]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}
