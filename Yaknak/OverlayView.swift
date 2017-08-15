//
//  OverlayView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 08/08/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

open class OverlayView: UIView {
  
  open var overlayState: SwipeResultDirection?
  
  open func update(progress: CGFloat) {
    alpha = progress
  }
  
}
