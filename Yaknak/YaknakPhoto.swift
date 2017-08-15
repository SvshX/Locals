//
//  YaknakPhoto.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import Photos

open class YaknakPhoto: YaknakBasePermission, YaknakPermissionProtocol {
  open var identifier: String = "YaknakPhoto"
  
  public init() {
    super.init(identifier: self.identifier)
  }
  
  public override init(configuration: YaknakConfiguration? = nil,  initialPopupData: YaknakPopupData? = nil, reEnablePopupData: YaknakPopupData? = nil) {
    super.init(configuration: configuration, initialPopupData: initialPopupData, reEnablePopupData: reEnablePopupData)
  }
  
  open func status(completion: @escaping YaknakPermissionResponse) {
    switch PHPhotoLibrary.authorizationStatus() {
    case .notDetermined:
      return completion(.notDetermined)
    case .restricted, .denied:
      return completion(.denied)
    case.authorized:
      return completion(.authorized)
    }
  }
  
  open func askForPermission(completion: @escaping YaknakPermissionResponse) {
    PHPhotoLibrary.requestAuthorization { (status) in
      switch status {
      case .notDetermined:
        print("🌅 permission not determined 🤔")
        return completion(.notDetermined)
      case .restricted, .denied:
        print("🌅 permission denied by user ⛔️")
        return completion(.denied)
      case.authorized:
        print("🌅 permission authorized by user ✅")
        return completion(.authorized)
      }
    }
  }
}
