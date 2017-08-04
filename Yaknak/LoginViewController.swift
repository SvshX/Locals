//
//  ViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Firebase


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var logInButton: LoadingButton!
    
    let dataService = DataService()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        showLoading(fromTap: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
    }
    
    
    private func setUI() {
        emailField.delegate = self
        passwordField.delegate = self
        emailField.borderTop()
        passwordField.borderTop()
        hideKeyboardOnTap(#selector(dismissKeyboard))
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func logInTapped(_ sender: AnyObject) {
        startLogin()
    }
    
    
    func startLogin() {
        
        if let email = emailField.text {
            if let password = passwordField.text {
                
                if email.isEmpty || password.isEmpty {
                    
                    promptAlert(Constants.Notifications.GenericFailureTitle, Constants.Notifications.NoEmailPasswordMessage)
                    showLoading(fromTap: false)
                    emailField.text = ""
                    passwordField.text = ""
                }
                    
                else if ValidationHelper.isValidEmail(email) && ValidationHelper.isPwdLength(password) {
                    
                    showLoading(fromTap: true)
                    
                    dataService.signIn(withEmail: email, password, completion: { (success, user) in
                        
                       self.showLoading(fromTap: false)
                        if success {
                          guard let _ = user, let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                                    appDelegate.launchDashboard()
                        }
                        else {
                            self.emailField.text = ""
                            self.passwordField.text = ""
                            
                            if let user = user {
                                
                                let alertController = UIAlertController()
                                alertController.verificationAlert(title: "Sorry!", message: "Your email address has not yet been verified. Do you want us to send another verification email?", user: user)
                            }
                            else {
                                self.promptAlert(Constants.Notifications.GenericFailureTitle, Constants.Notifications.IncorrectEmailPasswordMessage)
                            }
                            
                        }
                    })
                    
                }
                else {
                    emailField.text = ""
                    passwordField.text = ""
                    promptAlert(Constants.Notifications.GenericFailureTitle, Constants.Notifications.NoValidPasswordMessage)
                    showLoading(fromTap: false)
                    
                }
                
            }
        }
    }
 
    
    private func showLoading(fromTap loading: Bool) {
        
        if loading {
        logInButton.showLoading()
        logInButton.backgroundColor = UIColor.primary()
        logInButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        }
        else {
            logInButton.backgroundColor = UIColor.tertiary()
            logInButton.setTitleColor(UIColor.primaryText(), for: UIControlState.normal)
            logInButton.hideLoading()
        }
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        if textField == passwordField {
            textField.resignFirstResponder()
            startLogin()
        }
        return true
    }
    
    
    @IBAction func logInCancelled(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func forgotPasswordTapped(_ sender: AnyObject) {
        
        var loginTextField: UITextField!
        
        let alertController = UIAlertController(title: Constants.Notifications.PasswordResetTitle, message: Constants.Notifications.PasswordResetMessage, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: Constants.Notifications.GenericOKTitle, style: .default, handler: { (action) -> Void in
            
            
            guard let email = loginTextField.text else {return}
          
            if (!email.isEmpty && ValidationHelper.isValidEmail(email)) {
                
                loginTextField.text = ""
                let alertController = UIAlertController()
                
                self.dataService.resetPassword(email, completion: { (success, message) in
                    alertController.defaultAlert(nil, message)
                })
            }
            else {
                alertController.defaultAlert(Constants.Notifications.GenericFailureTitle, Constants.Notifications.EmailRequiredMessage)
            }
        
        
        })
        let cancel = UIAlertAction(title: Constants.Notifications.GenericCancelTitle, style: .cancel) { (action) -> Void in
            
        }
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextField { (textField) -> Void in
            // Enter the textfiled customization code here.
            loginTextField = textField
            loginTextField?.placeholder = Constants.Notifications.ForgotPasswordPlaceholder
            loginTextField.keyboardType = .emailAddress
        }
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    func promptAlert(_ title: String, _ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleMutableString = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryText()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryText()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: Constants.Notifications.GenericOKTitle, style: .cancel, handler: nil)
        defaultAction.setValue(UIColor.primary(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    

}
