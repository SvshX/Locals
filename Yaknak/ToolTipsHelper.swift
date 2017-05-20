//
//  ToolTipsHelper.swift
//  Yaknak
//
//  Created by Sascha Melcher on 16/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation


class ToolTipsHelper: NSObject {


    var toolTip = ToolTip()
 //   var timer: Timer? = nil
    
    
    
    class var sharedInstance : ToolTipsHelper {
        struct Static {
            static let instance : ToolTipsHelper = ToolTipsHelper()
        }
        return Static.instance
    }
    
    
    override init() {
        super.init()
        self.initToolTip()
        
        
    }
    
    
    private func initToolTip() {
     //   toolTip.shouldDismissOnTap = true
        //    toolTip.edgeMargin = 5
        //    toolTip.offset = 2
        toolTip.bubbleColor = UIColor.white
        toolTip.edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        toolTip.actionAnimation = .bounce(3)
        
        toolTip.dismissHandler = { _ in
        self.dismissToolTip()
        }
    }
    
    
    func dismissToolTip() {
        self.toolTip.hide()
      //  stopTimer()
    }

    /*
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
   */ 
    
    public func showToolTip(_ message: String, _ inView: UIView, _ from: CGRect, _ direction: ToolTipDirection) {
        let attributes: [String: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.primaryTextColor()]
        let attributedText = NSMutableAttributedString(string: message, attributes: attributes)
        toolTip.show(attributedText: attributedText, direction: direction, maxWidth: 250.0, in: inView, from: from, duration: 5)
        
        /*
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 10000, repeats: false) { (_) in
                self.dismissToolTip()
            }
        } else {
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.dismissToolTip), userInfo: nil, repeats: false)
        }
*/
    
    }

    
    
}
