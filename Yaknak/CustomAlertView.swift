//
//  CustomAlertView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 04/12/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class CustomAlertView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = UIColor.primaryTextColor()
        messageLabel.textColor = UIColor.primaryTextColor()
    }
    
    func populate(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }
    
    class func instantiateFromNib() -> CustomAlertView {
        return Bundle.main.loadNibNamed("CustomAlertView", owner: nil, options: nil)!.first as! CustomAlertView
    }

}
