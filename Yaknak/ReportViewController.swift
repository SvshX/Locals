//
//  ReportViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import MBProgressHUD


class ReportViewController: UITableViewController, UITextViewDelegate {

    var data: Tip?
    var reportTypeArray = [String]()
    
    
    
    
    @IBOutlet weak var optionalMessage: UITextView!
    @IBOutlet weak var cell2: UITableViewCell!
    @IBOutlet weak var cell1: UITableViewCell!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    let PLACEHOLDER_TEXT = "Give us some feedback on your report..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.optionalMessage.delegate = self
        self.sendButton.tintColor = UIColor.primaryColor()
        self.cancelButton.tintColor = UIColor.primaryColor()
        self.sendButton.isEnabled = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        applyPlaceholderStyle(aTextview: self.optionalMessage, placeholderText: PLACEHOLDER_TEXT)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelTapped(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
  /*
    @IBAction func sendTapped(sender: AnyObject) {
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.label.text = Constants.Notifications.LoadingNotificationText
        
        
        let query = Tip.query()
        query?.getObjectInBackgroundWithId((data?.objectId)!, block: { (object: PFObject?, error: NSError?) in
            
            if (error == nil) {
                
                if let object = object {
                    object.addObject(self.reportTypeArray[0], forKey: "reportType")
                    if (!self.optionalMessage.text.isEmpty) {
                        object.addObject(self.optionalMessage.text, forKey: "reportMessage")
                    }
                    
                    object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                        
                        if (success) {
                            print("success")
                        }
                        else {
                            print("error")
                        }
                    })
                    
                    
                    
                }
                
                
            }
                
            else {
                print("error")
            }
            
            
        })
        loadingNotification.hide(animated: true)
        
        self.showReportSuccess()
        
        
    }
  */
    
    private func showReportSuccess() {
        
        
        let userMessage = Constants.Notifications.ReportAlertMessage
        let alert = UIAlertController(title: Constants.Notifications.ReportAlertTitle, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: Constants.Notifications.AlertConfirmation, style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.backToMain()})
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    private func backToMain() {
        self.dismiss(animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 2
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
        /*
         
         let section = indexPath.section
         let numberOfRows = tableView.numberOfRowsInSection(section)
         for row in 0..<numberOfRows {
         if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) {
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
         cell.accessoryType = row == indexPath.row ? .Checkmark : .None
         reportTypeArray.append((cell.textLabel?.text)!)
         cell.tintColor = UIColor.primaryColor()
         self.sendButton.enabled = true
         
         }
         else {
         //     let indexToDelete = reportTypeArray.indexOf((cell.textLabel?.text)!)
         //     reportTypeArray.removeAtIndex(indexToDelete!)
         }
         }
         
         */
        
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
