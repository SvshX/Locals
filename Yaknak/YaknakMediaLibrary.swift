//
//  YaknakMediaLibrary.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import MediaPlayer

open class YaknakMediaLibrary: YaknakBasePermission, YaknakPermissionProtocol {
  open var identifier: String = "YaknakMediaLibrary"
  
  public init() {
    super.init(identifier: self.identifier)
  }
  
  public override init(configuration: YaknakConfiguration? = nil,  initialPopupData: YaknakPopupData? = nil, reEnablePopupData: YaknakPopupData? = nil) {
    super.init(configuration: configuration, initialPopupData: initialPopupData, reEnablePopupData: reEnablePopupData)
  }
  
  open func status(completion: @escaping YaknakPermissionResponse) {
    if #available(iOS 9.3, *) {
      let status = MPMediaLibrary.authorizationStatus()
      switch status {
      case .authorized:
        return completion(.authorized)
      case .restricted, .denied:
        return completion(.denied)
      case .notDetermined:
        return completion(.notDetermined)
      }
    } else {
      return completion(.notAvailable)
    }
  }
  
  open func askForPermission(completion: @escaping YaknakPermissionResponse) {
    if #available(iOS 9.3, *) {
      MPMediaLibrary.requestAuthorization { status in
        switch status {
        case .authorized:
          print("💽 permission authorized by user ✅")
          return completion(.authorized)
        case .restricted, .denied:
          print("💽 permission denied by user ⛔️")
          return completion(.denied)
        case .notDetermined:
          print("💽 permission not determined 🤔")
          return completion(.notDetermined)
        }
      }
    } else {
      print("💽 permission denied by iOS ⛔️")
      return completion(.notAvailable)
    }
  }
}
