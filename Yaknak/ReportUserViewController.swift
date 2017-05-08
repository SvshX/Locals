//
//  ReportUserViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/01/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MBProgressHUD


class ReportUserViewController: UITableViewController, UITextViewDelegate {
    
    
    
    @IBOutlet weak var optionalMessage: UITextView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    
    var userRef : FIRDatabaseReference!
    let dataService = DataService()
    
    var data: Tip!
    var reportTypeArray = [String]()
    
    let PLACEHOLDER_TEXT = "Give us some feedback on your report..."
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.optionalMessage.delegate = self
        self.sendButton.tintColor = UIColor.primaryColor()
        self.cancelButton.tintColor = UIColor.primaryColor()
        self.sendButton.isEnabled = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.userRef = dataService.USER_REF
        applyPlaceholderStyle(aTextview: self.optionalMessage, placeholderText: PLACEHOLDER_TEXT)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        let loadingNotification = MBProgressHUD.showAdded(to: (self.parent?.view)!, animated: true)
        loadingNotification.label.text = Constants.Notifications.LoadingNotificationText
        //    loadingNotification.center = CGPoint(self.width/2, self.height/2)
        loadingNotification.center = (self.parent?.view.center)!
        
        if let userId = self.data.addedByUser {
        
        let reportType = self.reportTypeArray[0]
            
            var message = String()
            if (self.optionalMessage.text == PLACEHOLDER_TEXT) {
                message = "No messaage added"
            }
            else {
                message = self.optionalMessage.text
            }
            
            let updateObject = ["users/\(userId)/isActive" : false, "users/\(userId)/reportType" : reportType, "users/\(userId)/reportMessage" : message] as [String : Any]
            
            self.dataService.BASE_REF.updateChildValues(updateObject, withCompletionBlock: { (error, ref) in
                
                if error == nil {
                     print("User reported...")
                    DispatchQueue.main.async {
                        loadingNotification.hide(animated: true)
                        self.showReportSuccess()
                    }
                }
            })
       
        }
        
}
    
    
    
    private func showReportSuccess() {
        
        //      let alertController = UIAlertController()
        //      alertController.reportAlert(title: Constants.Notifications.ReportAlertTitle, message: Constants.Notifications.ReportAlertMessage)
        
        let title = Constants.Notifications.ReportAlertTitle
        let message = Constants.Notifications.ReportAlertMessage
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleMutableString = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { action in
            self.dismiss(animated: true, completion: nil)
            self.tabBarController?.selectedIndex = 2
        }
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        //    alertController.show()
        
    }
    
    
    
    func textViewShouldBeginEditing(_ aTextView: UITextView) -> Bool
    {
        if aTextView == self.optionalMessage && aTextView.text == PLACEHOLDER_TEXT
        {
            // move cursor to start
            moveCursorToStart(aTextView: aTextView)
        }
        return true
    }
    
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // remove the placeholder text when they start typing
        // first, see if the field is empty
        // if it's not empty, then the text should be black and not italic
        // BUT, we also need to remove the placeholder text if that's the only text
        // if it is empty, then the text should be the placeholder
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 // have text, so don't show the placeholder
        {
            
            if text == "\n"  // Recognizes enter key in keyboard
            {
                textView.resignFirstResponder()
                return false
            }
            
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == self.optionalMessage && textView.text == PLACEHOLDER_TEXT
            {
                if text.utf16.count == 0 // they hit the back button
                {
                    return false // ignore it
                }
                applyNonPlaceholderStyle(aTextview: textView)
                textView.text = ""
            }
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(aTextview: textView, placeholderText: PLACEHOLDER_TEXT)
            moveCursorToStart(aTextView: textView)
            return false
        }
    }

    
    
    
    func moveCursorToStart(aTextView: UITextView)
    {
        DispatchQueue.main.async(execute: {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor.lightGray
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.primaryTextColor()
        aTextview.alpha = 1.0
    }

    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        
        if let selectedRow = tableView.cellForRow(at: indexPath as IndexPath) {
            if selectedRow.accessoryType == .none {
                
                selectedRow.accessoryType = .checkmark
                selectedRow.tintColor = UIColor.primaryColor()
                self.sendButton.isEnabled = true
                reportTypeArray.append((selectedRow.textLabel?.text)!)
            } else {
                selectedRow.accessoryType = .none
                tableView.deselectRow(at: indexPath, animated: true)
                self.sendButton.isEnabled = false
                let indexToDelete = reportTypeArray.index(of: (selectedRow.textLabel?.text)!)
                reportTypeArray.remove(at: indexToDelete!)
                
                //    let indexToDelete = reportTypeArray.indexOf((selectedRow.textLabel?.text)!)
                //    reportTypeArray.removeAtIndex(indexToDelete!)
            }
        }
    
        
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            if (!self.reportTypeArray.isEmpty) {
                let indexToDelete = self.reportTypeArray.index(of: (cell.textLabel?.text)!)
                self.reportTypeArray.remove(at: indexToDelete!)
            }
            
        }
    }
}
