//
//  ValidationHelper.swift
//  Yaknak
//
//  Created by Sascha Melcher on 06/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class ValidationHelper: NSObject {
    
    
    class var sharedInstance : ValidationHelper {
        struct Static {
            static let instance : ValidationHelper = ValidationHelper()
        }
        return Static.instance
    }
    
    class func isValidEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    
    class func isPwdLength(password: String) -> Bool {
        if (password.characters.count >= 6) {
            return true
        }
        else {
            return false
        }
    }


}
