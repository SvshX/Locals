//
//  UITextField.swift
//  Yaknak
//
//  Created by Sascha Melcher on 24/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func borderTop() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.tertiary().cgColor
        border.frame = CGRect(x: 0, y: 1, width:  self.frame.size.width, height: 1)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func borderBottom() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.tertiary().cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width:  self.frame.size.width, height: 1)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

