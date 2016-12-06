//
//  String.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/12/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation

extension String {
    var first: String {
        return String(characters.prefix(1))
    }
    var last: String {
        return String(characters.suffix(1))
    }
    var uppercaseFirst: String {
        return first.uppercased() + String(characters.dropFirst())
    }
}
