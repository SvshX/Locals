//
//  YaknakContacts.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import Contacts

open class YaknakContacts: YaknakBasePermission, YaknakPermissionProtocol {
  open var identifier: String = "YaknakContacts"
  
  public init() {
    super.init(identifier: self.identifier)
  }
  
  public override init(configuration: YaknakConfiguration? = nil,  initialPopupData: YaknakPopupData? = nil, reEnablePopupData: YaknakPopupData? = nil) {
    super.init(configuration: configuration, initialPopupData: initialPopupData, reEnablePopupData: reEnablePopupData)
  }
  
  open func status(completion: @escaping YaknakPermissionResponse) {
    switch Contacts.CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
    case .authorized:
      return completion(.authorized)
    case .denied, .restricted:
      return completion(.denied)
    case .notDetermined:
      return completion(.notDetermined)
    }
  }
  
  open func askForPermission(completion: @escaping YaknakPermissionResponse) {
    Contacts.CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler:  { (granted, error) in
      if let error = error {
        print("🎫 not determined 🤔 error: \(error)")
        return completion(.notDetermined)
      }
      
      if granted {
        print("🎫 permission authorized by user ✅")
        return completion(.authorized)
      }
      
      print("🎫 denied by user ⛔️")
      return completion(.denied)
    })
  }
}
