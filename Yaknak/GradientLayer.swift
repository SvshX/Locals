//
//  GradientLayer.swift
//  Yaknak
//
//  Created by Sascha Melcher on 02/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


class GradientLayer : CAGradientLayer {
    var gradient: GradientType? {
        didSet {
            startPoint = gradient?.x ?? CGPoint.zero
            endPoint = gradient?.y ?? CGPoint.zero
        }
    }
}
