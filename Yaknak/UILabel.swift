//
//  UILabel.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


extension UILabel {
    
    func drawLineOnBothSides(labelWidth: CGFloat, color: UIColor) {
        
        let fontAttributes = [NSFontAttributeName: self.font]
        let size = self.text?.size(attributes: fontAttributes)
        let widthOfString = size!.width
        
        let width = CGFloat(1)
        
        let leftLine = UIView(frame: CGRect(x: 0, y: self.frame.height/2 - width/2, width: labelWidth/2 - widthOfString/2 - 10, height: width))
        leftLine.backgroundColor = color
        self.addSubview(leftLine)
        
        let rightLine = UIView(frame: CGRect(x: labelWidth/2 + widthOfString/2 + 10, y: self.frame.height/2 - width/2, width: labelWidth/2 - widthOfString/2 - 10, height: width))
        rightLine.backgroundColor = color
        self.addSubview(rightLine)
    }
}
