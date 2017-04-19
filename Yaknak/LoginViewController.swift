//
//  ViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var logInButton: LoadingButton!
    
    let dataService = DataService()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.emailField.borderTop()
        self.passwordField.borderTop()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.logInButton.backgroundColor = UIColor.smokeWhiteColor()
        self.logInButton.setTitleColor(UIColor.primaryTextColor(), for: UIControlState.normal)


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    
    
    @IBAction func logInTapped(_ sender: AnyObject) {
        
        if emailField.text == "" || passwordField.text == "" {
            
          self.promptAlert(title: "Oops!", message: "Please enter an email and password.")
      //      let alertController = UIAlertController()
      //      alertController.defaultAlert(title: "Oops!", message: "Please enter an email and password.")
            self.hideLoading()
            
            
        }
        else if ValidationHelper.isValidEmail(candidate: self.emailField.text!) && ValidationHelper.isPwdLength(password: self.passwordField.text!) {
            
            self.showLoading()
            
            self.dataService.signIn(email: self.emailField.text!, password: self.passwordField.text!, completion: { (success) in
            
                    self.hideLoading()
            })
       
        }
        else {
            self.promptAlert(title: "Oops!", message: "The password has to be 6 characters long or more.")
            self.hideLoading()
            
        }
        
        
        
    }
    
    func logIn() {
        
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user: FIRUser?, error: Error?) in
            
            if error != nil {
                self.promptAlert(title: "Oops!", message: (error?.localizedDescription)!)
                
            }
            else {
                print("User logged in")
                self.emailField.text = ""
                self.passwordField.text = ""
            }
            
            
        })
        
    }
    
    
    private func showLoading() {
        self.logInButton.showLoading()
        self.logInButton.backgroundColor = UIColor.primaryColor()
        self.logInButton.setTitleColor(UIColor.white, for: UIControlState.normal)
    }
    
    
    private func hideLoading() {
        self.logInButton.backgroundColor = UIColor.tertiaryColor()
        self.logInButton.setTitleColor(UIColor.primaryTextColor(), for: UIControlState.normal)
        self.logInButton.hideLoading()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
        }
        if textField == self.passwordField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    @IBAction func logInCancelled(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func forgotPasswordTapped(_ sender: AnyObject) {
        
        var loginTextField: UITextField!
        
        let alertController = UIAlertController(title: "Password Recovery", message: "Please enter your email address", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            
            guard let email = loginTextField.text else {return}
          
            if (email != "" && ValidationHelper.isValidEmail(candidate: email)) {
                
                loginTextField.text = ""
                self.dataService.resetPassword(email: email)
                
            }
            else {
                let title = "Oops!"
                let message = "Please enter an email."
                let alertController = UIAlertController()
                alertController.defaultAlert(title: title, message: message)
       
            }
        
        
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            
        }
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextField { (textField) -> Void in
            // Enter the textfiled customization code here.
            loginTextField = textField
            loginTextField?.placeholder = "Enter your email address"
            loginTextField.keyboardType = .emailAddress
        }
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    func promptAlert(title: String, message: String) {
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
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func showErrorAlert(title: String, msg: String) {
        let alertController = UIAlertController()
        alertController.defaultAlert(title: title, message: msg)
    }
    

}
