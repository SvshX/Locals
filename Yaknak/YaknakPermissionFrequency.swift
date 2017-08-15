//
//  YaknakPermissionFrequency.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation

/*
 * Frequency to ask the user to present the request again
 */
public enum YaknakPermissionFrequency {
  case Always
  case EveryHour
  case OnceADay
  case OnceAWeek
  case JustOnce
}
