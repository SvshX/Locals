//
//  ViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FirebaseDatabase
import FirebaseAuth


class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    
    @IBOutlet weak var emailField: TextField!
    @IBOutlet weak var passwordField: TextField!
    //  @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var helpButton: UIButton!
    //  @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    let dataService = DataService()
//    let fbLoginButton = FBSDKLoginButton()
    let fbLoginButton = UIButton()
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.emailField.borderTop()
        self.passwordField.borderTop()
        
        self.signUpButton.layer.cornerRadius = 4
        self.signUpButton.layer.borderColor = UIColor.tertiaryColor().cgColor
        self.signUpButton.layer.borderWidth = 1
        //  self.fbLoginButton = FBSDKLoginButton()
        self.fbLoginButton.backgroundColor = UIColor.blue
        self.fbLoginButton.setTitleColor(UIColor.white, for: .normal)
        self.fbLoginButton.setTitle("Sign up with Facebook", for: .normal)
        self.view.addSubview(fbLoginButton)
        self.fbLoginButton.translatesAutoresizingMaskIntoConstraints = false
        self.fbLoginButton.addTarget(self, action: #selector(LoginViewController.handleFBLogin), for: .touchUpInside)
   //     self.fbLoginButton.delegate = self
   //     self.fbLoginButton.readPermissions = ["email", "public_profile"]
        self.fbLoginButton.bottomAnchor.constraint(
            equalTo: self.signUpButton.topAnchor,
            constant: -10).isActive = true
        self.fbLoginButton.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        self.fbLoginButton.widthAnchor.constraint(equalTo: self.signUpButton.widthAnchor).isActive = true
        self.fbLoginButton.heightAnchor.constraint(equalTo: self.signUpButton.heightAnchor).isActive = true
        
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
    
    
    @IBAction func helpButtonTapped(_ sender: Any) {
        let popUpVC = UIStoryboard(name: "Help", bundle: nil).instantiateViewController(withIdentifier: "HelpPopUp") as! HelpPopUpViewController
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    
    @IBAction func logInTapped(_ sender: AnyObject) {
        
        if emailField.text == "" || passwordField.text == "" {
            
            AlertViewHelper.promptDefaultAlert(title: "Oops!", message: "Please enter an email and password.")
            
        }
        else if ValidationHelper.isValidEmail(candidate: self.emailField.text!) && ValidationHelper.isPwdLength(password: self.passwordField.text!) {
            
            self.dataService.signIn(email: self.emailField.text!, password: self.passwordField.text!)
            self.logInButton.backgroundColor = UIColor.primaryColor()
            self.logInButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            
        }
        else {
            AlertViewHelper.promptDefaultAlert(title: "Oops!", message: "The password has to be 6 characters long or more.")
            
        }
        
        
        
    }
    
    func logIn() {
        
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user: FIRUser?, error: Error?) in
            
            if error != nil {
                AlertViewHelper.promptDefaultAlert(title: "Oops!", message: (error?.localizedDescription)!)
            }
            else {
                print("User logged in")
                self.emailField.text = ""
                self.passwordField.text = ""
            }
            
            
        })
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.helpButton.isUserInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.helpButton.isUserInteractionEnabled = true
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
    
    
    @IBAction func forgotPasswordTapped(_ sender: AnyObject) {
        
        var loginTextField: UITextField!
        loginTextField.keyboardType = .emailAddress
        
        let alertController = UIAlertController(title: "Password Recovery", message: "Please enter your email address", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            
            guard let email = loginTextField.text else {return}
          
            if (email != "" && ValidationHelper.isValidEmail(candidate: (email))) {
                
                self.dataService.resetPassword(email: (loginTextField?.text)!)
                
            }
            else {
                let alertController = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                alertController.show()
                
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
        }
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    func showErrorAlert(title: String, msg: String) {
        AlertViewHelper.promptDefaultAlert(title: title, message: msg)
        
    }
    
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
       
    }
    
    func handleFBLogin() {
    
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) {
        
        (result, error) in
            
            if (result?.isCancelled)! {
                return
            }
            
            if error != nil {
                print(error)
                return
            }
            else {
                print("Successfully logged in with Facebook...")
               // self.fbLoginButton.isHidden = true
                
                guard let accessToken:FBSDKAccessToken? = FBSDKAccessToken.current() else {
                    return
                }
                
                if accessToken!.tokenString != nil {
                    
                    let fbCredential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    
                    FIRAuth.auth()?.signIn(with: fbCredential, completion: { (user, error) in
                        
                        
                        if error != nil {
                            
                            if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                                
                                switch errCode {
                                case .errorCodeInvalidEmail:
                                    print("invalid email")
                                case .errorCodeEmailAlreadyInUse:
                                    print("in use")
                                    self.promptForCredentials(fbCredential: fbCredential)
                                    //   self.linkWithEmailAccount(user: user!, fbCredential: fbCredential)
                                    
                                default:
                                    print("Create User Error: \(error!)")
                                }
                            }
                            
                        }
                        else {
                            self.finaliseSignUp(user: user!)
                        }
                    })
                    
                }
                
            }
        
        }
    
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if result.isCancelled {
            return
        }
        
        if error != nil {
            print(error)
            return
        }
        else {
            print("Successfully logged in with Facebook...")
            self.fbLoginButton.isHidden = true
            
            guard let accessToken:FBSDKAccessToken? = FBSDKAccessToken.current() else {
                return
            }
            
            if accessToken!.tokenString != nil {
                
                let fbCredential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                FIRAuth.auth()?.signIn(with: fbCredential, completion: { (user, error) in
                    
                    
                    if error != nil {
                        
                        if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                            
                            switch errCode {
                            case .errorCodeInvalidEmail:
                                print("invalid email")
                            case .errorCodeEmailAlreadyInUse:
                                print("in use")
                                self.promptForCredentials(fbCredential: fbCredential)
                                //   self.linkWithEmailAccount(user: user!, fbCredential: fbCredential)
                                
                            default:
                                print("Create User Error: \(error!)")
                            }
                        }
                        
                    }
                    else {
                        self.finaliseSignUp(user: user!)
                    }
                })
                
            }
            
        }
    }
    
    
    private func linkWithEmailAccount(user: FIRUser, fbCredential: FIRAuthCredential) {
        
        user.link(with: fbCredential, completion: { (user, error) in
            
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                self.finaliseSignUp(user: user!)
            }
        })
        
    }
    
    
    private func promptForCredentials(fbCredential: FIRAuthCredential) {
        
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
            
            let credential = FIREmailPasswordAuthProvider.credential(withEmail: email.text!, password: password.text!)
            
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                
                if error != nil {
                    AlertViewHelper.promptDefaultAlert(title: "Oops!", message: "Please enter correct email and password.")
                }
                else {
                    // link with account
                    self.linkWithEmailAccount(user: user!, fbCredential: fbCredential)
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
    
    
    func finaliseSignUp(user: FIRUser) {
        
        let imagePath = "profileImage\(user.uid)/userPic.jpg"
        let imageRef = self.dataService.STORAGE_REF.child(imagePath)
        imageRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (data: Data?, error: Error?) in
            
            if error != nil {
                print("no image stored yet...")
                self.fetchFBDetails(user: user)
            }
            else {
                
                if data == nil {
                    self.fetchFBDetails(user: user)
                }
                else {
                    // image is already stored
                }
            }
        })
        
    }
    
    func fetchFBDetails(user: FIRUser) {
        
        let requestParameters = ["fields": "id, email, name, picture.width(300).height(300).type(large).redirect(false)"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: requestParameters).start { (connection, result, error) in
            
            if error != nil {
                print("Failed to start graph request...", error?.localizedDescription)
                return
            }
            else {
                print(result)
                
                if let result = result as? [String: Any] {
                    
                    guard let email = result["email"] as? String else {
                        
                        return
                    }
                    guard let username = result["name"] as? String else {
                        
                        return
                    }
                    
                    guard let userId = result["id"] as? String else {
                        
                        return
                    }
                    
                    if let picObject = result["picture"] as? [String : Any] {
                        
                        guard let data = picObject["data"] as? [String : Any] else {
                            
                            return
                        }
                        
                        let urlPic = data["url"] as! String
                        
                        
                        
                        if let imageData = NSData(contentsOf: NSURL(string: urlPic) as! URL) {
                            
                            
                            let imagePath = "profileImage\(user.uid)/userPic.jpg"
                            let imageRef = self.dataService.STORAGE_REF.child(imagePath)
                            
                            // Create Metadata for the image
                            
                            let metaData = FIRStorageMetadata()
                            metaData.contentType = "image/jpeg"
                            
                            imageRef.put(imageData as Data, metadata: metaData) { (metaData, error) in
                                if error == nil {
                                    
                                    let changeRequest = user.profileChangeRequest()
                                    changeRequest.displayName = username
                                    changeRequest.photoURL = metaData!.downloadURL()
                                    changeRequest.commitChanges(completion: { (error) in
                                        
                                        if error == nil {
                                            
                                            let userInfo = ["email": email, "name": username, "uid": user.uid, "photoUrl": String(describing: user.photoURL!), "totalLikes": 0, "totalTips": 0] as [String : Any]
                                            
                                            // create user reference
                                            
                                            let userRef = self.dataService.USER_REF.child(user.uid)
                                            
                                            // Save the user info in the Database and in UserDefaults
                                            
                                            // Store the uid for future access - handy!
                                            UserDefaults.standard.setValue(user.uid, forKey: "uid")
                                            
                                            userRef.setValue(userInfo)
                                            
                                            
                                        }
                                    })
                                    
                                    
                                }
                                
                                
                                
                            }
                            
                            
                        }
                    }
                    
                }
            }
            
            /*
             if result != nil {
             
             let userId = result["id"] as AnyObject as! String
             let userFirstName: String? = result["first_name"] as AnyObject as? String
             let userLastName: String? = result["last_name"] as AnyObject as? String
             let email: String? = result["email"] as AnyObject as? String
             
             
             
             DispatchQueue.global(DispatchQueue.GlobalQueuePriority.default, 0).asynchronously() {
             
             // get Facebook profile picture
             
             let userProfilePicture = "https://graph.facebook.com/" + userId + "/picture?type=large"
             
             let profilePictureURL = NSURL(string: userProfilePicture)
             
             let profilePictureData = NSData(contentsOfURL: profilePictureURL!)
             
             if profilePictureData != nil {
             
             
             let file = PFFile(name: "profile_picture", data: profilePictureData!)
             
             file!.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
             if succeeded {
             
             let query = Tip.query()
             query!.whereKey("user", equalTo: User.currentUser()!)
             query!.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
             
             if error == nil {
             
             if let objects = objects {
             
             var totalLikes: Int = 0
             let totalTips: Int = objects.count
             
             for object in objects {
             
             totalLikes += object.objectForKey("likes") as! Int
             
             }
             
             self.saveCurrentUser(file!, userFirstName: userFirstName!, userLastName: userLastName!, totalLikes: totalLikes, totalTips: totalTips, email: email!)
             }
             
             else if let error = error {
             
             print(error)
             }
             
             
             }
             
             
             })
             
             } else if let error = error {
             //3
             self.callback(nil, error)
             print(error)
             }
             }, progressBlock: { percent in
             print("Uploaded: \(percent)%")
             })
             
             
             }
             }
             }
             else {
             // do something
             }
             
             */
        }
        
    }
    
}
