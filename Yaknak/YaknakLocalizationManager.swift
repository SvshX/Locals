//
//  YaknakLocalizationManager.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation

struct YaknakLocalizationManager {
  var initialTitle: String = ""
  var initialMessage: String = ""
  var image: String = ""
  var reEnableTitle: String = ""
  var reEnableMessage: String = ""
  var allowButtonTitle: String = ""
  var denyButtonTitle: String = ""
  
  init(permission: String) {
    self.initialTitle = NSLocalizedString("\(permission)_initial_title", comment: "")
    self.initialMessage = NSLocalizedString("\(permission)_initial_message", comment: "")
    
    self.image = "\(permission)_image"
    
    self.reEnableTitle = NSLocalizedString("\(permission)_reenable_title", comment: "")
    self.reEnableMessage = NSLocalizedString("\(permission)_reenable_message", comment: "")
    
    self.allowButtonTitle = NSLocalizedString("\(permission)_allow_button_title", comment: "")
    self.denyButtonTitle = NSLocalizedString("\(permission)_deny_button_title", comment: "")
  }
}
