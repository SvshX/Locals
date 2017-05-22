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
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.showLoading(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    
    private func setUI() {
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.emailField.borderTop()
        self.passwordField.borderTop()
    }
    
    
    @IBAction func logInTapped(_ sender: AnyObject) {
        
        if let email = emailField.text {
            if let password = passwordField.text {
            
        if email.isEmpty || password.isEmpty {
            
          self.promptAlert(Constants.Notifications.GenericFailureTitle, Constants.Notifications.NoEmailPasswordMessage)
            self.showLoading(false)
        }
            
        else if ValidationHelper.isValidEmail(email) && ValidationHelper.isPwdLength(password) {
            
            self.showLoading(true)
            
            self.dataService.signIn(email, password, completion: { (success) in
            
                if success {
                self.showLoading(false)
                }
            })
       
        }
        else {
            self.promptAlert(Constants.Notifications.GenericFailureTitle, Constants.Notifications.NoValidPasswordMessage)
            self.showLoading(false)
            
        }
        
            }
        }
        
        
    }
    
    /*
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
    */
    
    private func showLoading(_ loading: Bool) {
        
        if loading {
        self.logInButton.showLoading()
        self.logInButton.backgroundColor = UIColor.primaryColor()
        self.logInButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        }
        else {
            self.logInButton.backgroundColor = UIColor.tertiaryColor()
            self.logInButton.setTitleColor(UIColor.primaryTextColor(), for: UIControlState.normal)
            self.logInButton.hideLoading()
        }
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
        
        let alertController = UIAlertController(title: Constants.Notifications.PasswordResetTitle, message: Constants.Notifications.PasswordResetMessage, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: Constants.Notifications.GenericOKTitle, style: .default, handler: { (action) -> Void in
            
            
            guard let email = loginTextField.text else {return}
          
            if (!email.isEmpty && ValidationHelper.isValidEmail(email)) {
                
                loginTextField.text = ""
                self.dataService.resetPassword(email)
            }
            else {
                let alertController = UIAlertController()
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
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: Constants.Notifications.GenericOKTitle, style: .cancel, handler: nil)
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func showErrorAlert(title: String, msg: String) {
        let alertController = UIAlertController()
        alertController.defaultAlert(title, msg)
    }
    

}
