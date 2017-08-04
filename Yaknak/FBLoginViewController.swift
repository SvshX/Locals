//
//  FBLoginViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 17/03/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FBSDKCoreKit


class FBLoginViewController: UIViewController {

    
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    let dataService = DataService()
    let fbHelper = FBHelper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.initLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initLayout() {
        self.signupButton.layer.cornerRadius = 4
        self.signupButton.layer.borderColor = UIColor.tertiary().cgColor
        self.signupButton.layer.borderWidth = 1
        self.loginButton.layer.cornerRadius = 4
        self.loginButton.layer.borderColor = UIColor.tertiary().cgColor
        self.loginButton.layer.borderWidth = 1
        self.fbButton.layer.cornerRadius = 4
        self.fbButton.backgroundColor = UIColor(red: 56/255, green: 89/255, blue: 152/255, alpha: 1)
        self.fbButton.setBackgroundColor(color: UIColor(red: 33/255, green: 53/255, blue: 91/255, alpha: 1), forState: .highlighted)
    }
    
    
    @IBAction func helpTapped(_ sender: Any) {
        let popUpVC = UIStoryboard(name: "Help", bundle: nil).instantiateViewController(withIdentifier: "HelpPopUp") as! HelpPopUpViewController
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    
    
    @IBAction func loginTapped(_ sender: Any) {
        
        fbHelper.load(viewController: self, onError: {
            
        }) { (token) in
            
            let fbCredential = FacebookAuthProvider.credential(withAccessToken: token)
            
            Auth.auth().signIn(with: fbCredential, completion: { (user, error) in
                
                if let error = error {
                    
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        
                        switch errCode {
                        case .invalidEmail:
                            print("Invalid email")
                        case .emailAlreadyInUse:
                            print("Email already in use")
                            self.promptForCredentials(fbCredential)
                            
                        default:
                            print("Create User Error: \(error.localizedDescription)")
                        }
                    }
                    
                }
                else {
                    if let user = user {
                        print("Successfully logged in with Facebook...")
                        print("User's email: " + user.email!)
                    }
                }
            })
            
        }
        
    }
   

    
    private func linkWithEmailAccount(_ user: User, _ fbCredential: AuthCredential) {
        
        user.link(with: fbCredential, completion: { (user, error) in
            
            if let err = error {
                print(err.localizedDescription)
            }
            else {
                if let user = user {
                    print("Successfully linked email account with Facebook...")
                    print("User's email: " + user.email!)
                }
            }
        })
        
    }
    
    
    private func promptForCredentials(_ fbCredential: AuthCredential) {
        
        let title = "Please enter your email and password in order to link your Facebook account with your previous account"
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter email"
            textField.keyboardType = .emailAddress
            textField.returnKeyType = .done
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter password"
            textField.isSecureTextEntry = true
            textField.returnKeyType = .done
        }
        
        let saveAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            alert -> Void in
            
            let email = alertController.textFields![0] as UITextField
            let password = alertController.textFields![1] as UITextField
            
            let credential = EmailAuthProvider.credential(withEmail: email.text!, password: password.text!)
            
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                
                if error != nil {
                    let alertController = UIAlertController()
                    alertController.defaultAlert(Constants.Notifications.GenericFailureTitle, "Please enter correct email and password.")
                }
                else {
                    // link with account
                    if let user = user {
                    self.linkWithEmailAccount(user, fbCredential)
                    }
                }
                
            })
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }

}
