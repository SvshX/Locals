//
//  YaknakNotifications.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation

import UIKit
import UserNotifications

open class YaknakNotifications: YaknakBasePermission, YaknakPermissionProtocol {
  open var identifier: String = "YaknakNotifications"
  
  public init() {
    super.init(identifier: self.identifier)
  }
  
  public override init(configuration: YaknakConfiguration? = nil,  initialPopupData: YaknakPopupData? = nil, reEnablePopupData: YaknakPopupData? = nil) {
    super.init(configuration: configuration, initialPopupData: initialPopupData, reEnablePopupData: reEnablePopupData)
  }
  
  open func status(completion: @escaping YaknakPermissionResponse) {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().getNotificationSettings { (settings) in
        switch settings.authorizationStatus {
        case .notDetermined:
          return completion(.notDetermined)
        case .denied:
          return completion(.denied)
        case .authorized:
          return completion(.authorized)
        }
      }
    } else if #available(iOS 9.0, *) {
      if let types = UIApplication.shared.currentUserNotificationSettings?.types {
        if types.isEmpty {
          return completion(.notDetermined)
        }
      }
      
      return completion(.authorized)
    }
  }
  
  open func askForPermission(completion: @escaping YaknakPermissionResponse) {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (granted, error) in
        if let error = error {
          print("Push notifications permission not determined 🤔, error: \(error)")
          return completion(.notDetermined)
        }
        if granted {
          self.registerForRemoteNotifications()
          
          print("Push notifications permission authorized by user ✅")
          return completion(.authorized)
        }
        print("Push notifications permission denied by user ⛔️")
        return completion(.denied)
      }
    } else if #available(iOS 9.0, *) {
      UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
      self.registerForRemoteNotifications()
    }
  }
  
  fileprivate func registerForRemoteNotifications() {
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }
  }
}
