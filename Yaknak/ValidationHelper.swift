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
    
    class func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    
    class func isPwdLength(_ password: String) -> Bool {
        return password.characters.count >= 6
    }

}
