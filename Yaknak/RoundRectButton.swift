//
//  RoundedButton.swift
//  Yaknak
//
//  Created by Sascha Melcher on 02/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

class RoundRectButton: UIButton {

    /// Corner radius of the background rectangle
    public var roundRectCornerRadius: CGFloat = 14 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// Color of the background rectangle
    public var roundRectColor: UIColor = UIColor.smokeWhiteColor() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // MARK: Overrides
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutRoundRectLayer()
    }
    
    // MARK: Private
    private var roundRectLayer: CAShapeLayer?
    
    private func layoutRoundRectLayer() {
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).cgPath
        shapeLayer.fillColor = roundRectColor.cgColor
        self.layer.insertSublayer(shapeLayer, at: 0)
        self.roundRectLayer = shapeLayer
    }

}
