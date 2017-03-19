//
//  LineView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 18/03/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit


 @IBDesignable
class LineView: UIView {

        
        @IBInspectable var lineWidth: CGFloat = 1.0
        @IBInspectable var lineColor: UIColor? {
            didSet {
                lineCGColor = lineColor?.cgColor
            }
        }
        var lineCGColor: CGColor?
        
        override func draw(_ rect: CGRect) {
            // Draw a line from the top to the bottom at the midpoint of the view's rect height.
            let midpoint = self.bounds.size.height / 2.0
            let context = UIGraphicsGetCurrentContext()
            context!.setLineWidth(lineWidth)
            if let lineCGColor = self.lineCGColor {
                context!.setStrokeColor(lineCGColor)
            }
            else {
                context!.setStrokeColor(UIColor.black.cgColor)
            }
            context?.move(to: CGPoint(0.0, midpoint))
            context?.addLine(to: CGPoint(self.bounds.size.width, midpoint))
            context!.strokePath()
        }

}
