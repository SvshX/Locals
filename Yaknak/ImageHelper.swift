//
//  ImageHelper.swift
//  Yaknak
//
//  Created by Sascha Melcher on 16/02/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import UIKit
import Nuke


class ImageHelper {
    
    
   class func loadImage(with request: Request, into target: Target, completion: @escaping (Void) -> Void) {

        Nuke.loadImage(with: request, into: target) { [weak target] in
            target?.handle(response: $0, isFromMemoryCache: $1)
            completion()
        }
    }



}
