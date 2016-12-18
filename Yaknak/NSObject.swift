//
//  NSObject.swift
//  Yaknak
//
//  Created by Sascha Melcher on 18/12/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

public extension NSObject {
    
    func setAssociatedObject(_ value: AnyObject?, associativeKey: UnsafeRawPointer, policy: objc_AssociationPolicy) {
        if let valueAsAnyObject = value {
            objc_setAssociatedObject(self, associativeKey, valueAsAnyObject, policy)
        }
    }
    
    func getAssociatedObject(_ associativeKey: UnsafeRawPointer) -> Any? {
        guard let valueAsType = objc_getAssociatedObject(self, associativeKey) else {
            return nil
        }
        return valueAsType
    }
}
