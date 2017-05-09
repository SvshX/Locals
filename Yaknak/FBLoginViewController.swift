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


class FBLoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    let dataService = DataService()
    
    
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
        self.signupButton.layer.borderColor = UIColor.tertiaryColor().cgColor
        self.signupButton.layer.borderWidth = 1
        self.loginButton.layer.cornerRadius = 4
        self.loginButton.layer.borderColor = UIColor.tertiaryColor().cgColor
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
                    
                    UserDefaults.standard.setValue(FBSDKAccessToken.current().tokenString, forKey: "accessToken")
                    
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
            //    self.fbLoginButton.isHidden = true
            
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
                    let alertController = UIAlertController()
                    alertController.defaultAlert(title: "Oops!", message: "Please enter correct email and password.")
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
        
        let imagePath = "\(user.uid)/userPic.jpg"
        let imageRef = self.dataService.STORAGE_PROFILE_IMAGE_REF.child(imagePath)
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
                    print("user already exists in database...")
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
                
                var email = String()
                
                if let result = result as? [String: Any] {
                    
                    if let mail = result["email"] as? String {
                        
                        email = mail
                    }
                    else {
                        
                        if let id = result["id"] as? String {
                            email = id + "@facebook.com"
                        }
                    }
                    guard let username = result["name"] as? String else {
                        
                        return
                    }
                    /*
                     guard let userId = result["id"] as? String else {
                     
                     return
                     }
                     */
                    if let picObject = result["picture"] as? [String : Any] {
                        
                        guard let data = picObject["data"] as? [String : Any] else {
                            
                            return
                        }
                        
                        let urlPic = data["url"] as! String
                        
                        
                        
                        if let imageData = NSData(contentsOf: NSURL(string: urlPic) as! URL) {
                            
                            
                            let imagePath = "\(user.uid)/userPic.jpg"
                            let imageRef = self.dataService.STORAGE_PROFILE_IMAGE_REF.child(imagePath)
                            
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
                                            
                                            let userInfo = ["email": email, "name": username, "uid": user.uid, "photoUrl": String(describing: user.photoURL!), "totalLikes": 0, "totalTips": 0, "isActive": true] as [String : Any]
                                            
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
        }
        
    }
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }

}
