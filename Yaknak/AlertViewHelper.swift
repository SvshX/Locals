//
//  AlertViewHelper.swift
//  Yaknak
//
//  Created by Sascha Melcher on 04/12/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Malert


class AlertViewHelper {
    
    static var alertView: CustomAlertView = {
        return CustomAlertView.instantiateFromNib()
    }()

    class func setUpCustomMalertViewConfig() -> MalertViewConfiguration {
        var malertViewConfig = MalertViewConfiguration()
        malertViewConfig.margin = 16
        malertViewConfig.buttonsAxis = .horizontal
        malertViewConfig.backgroundColor = UIColor.smokeWhiteColor()
        malertViewConfig.textColor = .primaryTextColor()
        malertViewConfig.textAlign = .center
       
        
        return malertViewConfig
    }
    
    class func promptNetworkFail() {
            
            let title = Constants.NetworkConnection.NetworkPromptTitle
            let message = Constants.NetworkConnection.NetworkPromptMessage
            
            alertView.populate(title: title, message: message)
            alertView.titleLabel.textColor = UIColor.primaryTextColor()
            alertView.messageLabel.textColor = UIColor.primaryTextColor()
            let malertConfig = AlertViewHelper.setUpCustomMalertViewConfig()
            var btConfiguration = MalertButtonConfiguration()
            btConfiguration.tintColor = malertConfig.textColor
            btConfiguration.separetorColor = .smokeWhiteColor()
            btConfiguration.tintColor = UIColor.white
            btConfiguration.backgroundColor = UIColor.primaryColor()
        let dmButton = MalertButtonStruct(title: Constants.NetworkConnection.RetryText, buttonConfiguration: btConfiguration) { 
            MalertManager.shared.dismiss()
        }
            
            MalertManager.shared.show(customView: alertView, buttons: [dmButton], animationType: .modalBottom, malertConfiguration: malertConfig)
            
        
    }
    
    
    class func promptRedirectToSettings() {
    
        let title = "Info"
        let message = "Yaknak needs to get access to your photos"
        alertView.populate(title: title, message: message)
        alertView.titleLabel.textColor = UIColor.primaryTextColor()
        alertView.messageLabel.textColor = UIColor.primaryTextColor()
        let malertConfig = AlertViewHelper.setUpCustomMalertViewConfig()
        var btConfiguration = MalertButtonConfiguration()
        btConfiguration.tintColor = malertConfig.textColor
        btConfiguration.separetorColor = .smokeWhiteColor()
        btConfiguration.tintColor = UIColor.white
        btConfiguration.backgroundColor = UIColor.primaryColor()
        let dmButton = MalertButtonStruct(title: "Cancel", buttonConfiguration: btConfiguration) {
            MalertManager.shared.dismiss()
            
        }
        
        let redirectButton = MalertButtonStruct(title: "Go to Settings", buttonConfiguration: btConfiguration) {
            
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
            
        }
        
        
        MalertManager.shared.show(customView: alertView, buttons: [redirectButton, dmButton], animationType: .modalBottom, malertConfiguration: malertConfig)
    
    }
    
    
    class func promptDefaultAlert(title: String, message: String) {
    
        alertView.populate(title: title, message: message)
        alertView.titleLabel.textColor = UIColor.primaryTextColor()
        alertView.messageLabel.textColor = UIColor.primaryTextColor()
        let malertConfig = AlertViewHelper.setUpCustomMalertViewConfig()
        var btConfiguration = MalertButtonConfiguration()
        btConfiguration.tintColor = malertConfig.textColor
        btConfiguration.separetorColor = .smokeWhiteColor()
        btConfiguration.tintColor = UIColor.white
        btConfiguration.backgroundColor = UIColor.primaryColor()
        let dmButton = MalertButtonStruct(title: "OK", buttonConfiguration: btConfiguration) {
            MalertManager.shared.dismiss()
        }
        
        MalertManager.shared.show(customView: alertView, buttons: [dmButton], animationType: .modalBottom, malertConfiguration: malertConfig)
        
    }
    

}
