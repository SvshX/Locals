//
//  ToolTipManager.swift
//  Yaknak
//
//  Created by Sascha Melcher on 19/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


final class ToolTipManager {
    
    let wasLaunchedBefore: Bool
    var wasShownBefore: Bool = false
    var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }
 
    var isFirsPrompt: Bool {
        return !wasShownBefore
    }
    
    
    init(getWasLaunchedBefore: () -> Bool,
         setWasLaunchedBefore: (Bool) -> ()) {
        let wasLaunchedBefore = getWasLaunchedBefore()
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            setWasLaunchedBefore(true)
        }
        self.wasShownBefore = getWasShownBefore()
    }
    
    convenience init(userDefaults: UserDefaults, key: String) {
        self.init(getWasLaunchedBefore: { userDefaults.bool(forKey: key) },
                  setWasLaunchedBefore: { userDefaults.set($0, forKey: key) })
    }
    
    
    func getWasShownBefore() -> Bool {
    return UserDefaults.standard.bool(forKey: "wasShown")
    }
    
    
    func setWasShownBefore() {
    UserDefaults.standard.set(true, forKey: "wasShown")
    self.wasShownBefore = true
    }
    
}

extension ToolTipManager {
    
    static func alwaysFirst() -> ToolTipManager {
        return ToolTipManager(getWasLaunchedBefore: { return false }, setWasLaunchedBefore: { _ in })
    }
    
}
