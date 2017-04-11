//
//  Double.swift
//  Yaknak
//
//  Created by Sascha Melcher on 23/03/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
    

}
