//
//  Utils.swift
//  Yaknak
//
//  Created by Sascha Melcher on 13/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


class Utils {

    static func containSameElements<T: Comparable>(_ array1: [T], _ array2: [T]) -> Bool {
        guard array1.count == array2.count else {
            return false // No need to sorting if they already have different counts
        }
        
        return array1.sorted() == array2.sorted()
    }

}
