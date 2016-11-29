//
//  UIStoryboard.swift
//  Yaknak
//
//  Created by Sascha Melcher on 27/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit


extension UIStoryboard {
    static func instantiateViewController(_ storyboard: String, identifier: String) -> UIViewController {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}
