//
//  YaknakPopupData.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation

public enum YaknakPopupType {
  case codeido
  case native
}

public struct YaknakPopupData {
  var title: String!
  var message: String!
  var image: String!
  var allowButtonTitle: String!
  var denyButtonTitle: String!
  var type: YaknakPopupType!
  
  public init(title: String = "", message: String = "", image: String = "", allowButtonTitle: String = "", denyButtonTitle: String = "", type: YaknakPopupType = .native) {
    self.title = title
    self.message = message
    self.image = image
    self.allowButtonTitle = allowButtonTitle
    self.denyButtonTitle = denyButtonTitle
    self.type = type
  }
}
