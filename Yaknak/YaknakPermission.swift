//
//  YaknakPermission.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import UIKit


public typealias YaknakPermissionResponse = (YaknakPermissionStatus) -> Void

public protocol YaknakPermissionProtocol {
  var identifier: String { get }
  /**
   This is the key method to know if a permission has been authorized or denied.
   
   Parameter completion: this closure is invoked with the current permission status (ArekPermissionStatus)
   */
  func status(completion: @escaping YaknakPermissionResponse)
  
  /**
   This is the key method to manage the request for a permission.
   
   The behaviour is based on the ArekConfiguration set in the permission during the initialization phase.
   
   
   Parameter completion: this closure is invoked with the current permission status (ArekPermissionStatus)
   */
  func manage(completion: @escaping YaknakPermissionResponse)
  func askForPermission(completion: @escaping YaknakPermissionResponse)
}

/**
 ArekBasePermission is a root class and each permission inherit from it.
 
 Don't instantiate ArekBasePermission directly.
 */
open class YaknakBasePermission {
  var configuration: YaknakConfiguration = YaknakConfiguration(frequency: .Always, presentInitialPopup:
    true, presentReEnablePopup: true)
  var initialPopupData: YaknakPopupData = YaknakPopupData()
  var reEnablePopupData: YaknakPopupData = YaknakPopupData()
  
  public init(identifier: String) {
    let data = YaknakLocalizationManager(permission: identifier)
    
    self.initialPopupData = YaknakPopupData(title: data.initialTitle,
                                          message: data.initialMessage,
                                          image: data.image,
                                          allowButtonTitle: data.allowButtonTitle,
                                          denyButtonTitle: data.denyButtonTitle)
    self.reEnablePopupData = YaknakPopupData(title: data.reEnableTitle,
                                           message:  data.reEnableMessage,
                                           image: data.image,
                                           allowButtonTitle: data.allowButtonTitle,
                                           denyButtonTitle: data.denyButtonTitle)
    
    
  }
  /**
   Base init shared among each permission provided by Arek
   
   - Parameters:
   - configuration: ArekConfiguration object used to define the behaviour of the pre-iOS popup and the re-enable permission popup
   - initialPopupData: title and message related to pre-iOS popup
   - reEnablePopupData: title and message related to re-enable permission popup
   */
  public init(configuration: YaknakConfiguration? = nil, initialPopupData: YaknakPopupData? = nil, reEnablePopupData: YaknakPopupData? = nil) {
    self.configuration = configuration ?? self.configuration
    self.initialPopupData = initialPopupData ?? self.initialPopupData
    self.reEnablePopupData = reEnablePopupData ?? self.reEnablePopupData
  }
  
  private func manageInitialPopup(completion: @escaping YaknakPermissionResponse) {
    if self.configuration.presentInitialPopup {
      self.presentInitialPopup(title: self.initialPopupData.title, message: self.initialPopupData.message, image: self.initialPopupData.image,allowButtonTitle: self.initialPopupData.allowButtonTitle, denyButtonTitle: self.initialPopupData.denyButtonTitle, completion: completion)
    } else {
      (self as? YaknakPermissionProtocol)?.askForPermission(completion: completion)
    }
  }
  
  private func presentInitialPopup(title: String, message: String, image: String? = nil, allowButtonTitle: String, denyButtonTitle: String, completion: @escaping YaknakPermissionResponse) {
    switch self.initialPopupData.type as YaknakPopupType {
    case .native:
      self.presentInitialNativePopup(title: title, message: message, allowButtonTitle: allowButtonTitle, denyButtonTitle: denyButtonTitle, completion: completion)
      break
    default:
      break
    }
  }
  
  
  private func presentInitialNativePopup(title: String, message: String, allowButtonTitle: String, denyButtonTitle: String, completion: @escaping YaknakPermissionResponse) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let allow = UIAlertAction(title: allowButtonTitle, style: .default) { (action) in
      (self as? YaknakPermissionProtocol)?.askForPermission(completion: completion)
      alert.dismiss(animated: true, completion: nil)
    }
    
    let deny = UIAlertAction(title: denyButtonTitle, style: .cancel) { (action) in
      completion(.denied)
      alert.dismiss(animated: true, completion: nil)
    }
    
    alert.addAction(deny)
    alert.addAction(allow)
    
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
      while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
      }
      
      topController.present(alert, animated: true, completion: nil)
    }
  }
  
  private func presentReEnablePopup() {
    if self is YaknakPermissionProtocol && self.configuration.canPresentReEnablePopup(permission: (self as! YaknakPermissionProtocol)) {
      self.presentReEnablePopup(title: self.reEnablePopupData.title, message: self.reEnablePopupData.message, image: self.reEnablePopupData.image, allowButtonTitle: self.reEnablePopupData.allowButtonTitle, denyButtonTitle: self.reEnablePopupData.denyButtonTitle)
    } else {
      print("Yaknak for \(self) present re-enable not allowed")
    }
  }
  
  private func presentReEnablePopup(title: String, message: String, image: String?, allowButtonTitle: String, denyButtonTitle: String) {
    switch self.reEnablePopupData.type as YaknakPopupType {
    case .native:
      self.presentReEnableNativePopup(title: title, message: message, allowButtonTitle: allowButtonTitle, denyButtonTitle: denyButtonTitle)
      break
    default:
      break
    }
  }
  
  private func presentReEnableNativePopup(title: String, message: String, allowButtonTitle: String, denyButtonTitle: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let allow = UIAlertAction(title: allowButtonTitle, style: .default) { (action) in
      alert.dismiss(animated: true, completion: nil)
      let url = NSURL(string: UIApplicationOpenSettingsURLString)! as URL
      if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      } else if #available(iOS 9.0, *) {
        UIApplication.shared.openURL(url)
      }
    }
    
    let deny = UIAlertAction(title: denyButtonTitle, style: .cancel) { (action) in
      alert.dismiss(animated: true, completion: nil)
    }
    
    alert.addAction(deny)
    alert.addAction(allow)
    
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
      while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
      }
      
      topController.present(alert, animated: true, completion: nil)
    }
    
  }
  

  
  open func manage(completion: @escaping YaknakPermissionResponse) {
    (self as? YaknakPermissionProtocol)?.status { (status) in
      self.managePermission(status: status, completion: completion)
    }
  }
  
  internal func managePermission(status: YaknakPermissionStatus, completion: @escaping YaknakPermissionResponse) {
    switch status {
    case .notDetermined:
      self.manageInitialPopup(completion: completion)
      break
    case .denied:
      self.presentReEnablePopup()
      return completion(.denied)
    case .authorized:
      return completion(.authorized)
    case .notAvailable:
      break
    }
  }
}
