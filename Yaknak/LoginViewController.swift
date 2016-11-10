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
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let dataService = DataService()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        let fbLoginButton = FBSDKLoginButton()
        self.view.addSubview(fbLoginButton)
        fbLoginButton.frame = CGRect(x: 16, y: 250, width: view.frame.width - 32, height: 50)
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email", "public_profile"]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    
    @IBAction func logInTapped(_ sender: AnyObject) {
        
        if emailField.text == "" || passwordField.text == "" {
            
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        else if ValidationHelper.isValidEmail(candidate: self.emailField.text!) && ValidationHelper.isPwdLength(password: self.passwordField.text!) {
            
            self.dataService.signIn(email: self.emailField.text!, password: self.passwordField.text!)
            //   self.logIn()
            
        }
        else {
            
            let alertController = UIAlertController(title: "Oops!", message: "The password has to be 6 characters long or more.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    func logIn() {
        
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user: FIRUser?, error: Error?) in
            
            if error != nil {
                let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                
                
            }
            else {
                print("User logged in")
                self.emailField.text = ""
                self.passwordField.text = ""
            }
            
            
        })
        
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
        
        var loginTextField: UITextField?
        loginTextField?.keyboardType = .emailAddress
        let alertController = UIAlertController(title: "Password Recovery", message: "Please enter your email address", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            if loginTextField?.text != "" {
                
                self.dataService.resetPassword(email: (loginTextField?.text)!)
             
            }
            print("textfield is empty")
            
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
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
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
            
            guard let accessToken:FBSDKAccessToken? = FBSDKAccessToken.current() else {
                
                return
            }
            
            if accessToken!.tokenString != nil {
            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            FIRAuth.auth()?.signIn(with: credential, completion: { (user: FIRUser?, error: Error?) in
                
                let imagePath = "profileImage\(user?.uid)/userPic.jpg"
                let imageRef = self.dataService.STORAGE_REF.child(imagePath)
                imageRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (data: Data?, error: Error?) in
                    
                    if error != nil {
                    print("Unable to download image...")
                    }
                    else {
                    
                        if data == nil {
                         self.fetchFBDetails(user: user!)
                        }
                    }
                })
               
                
            })
            }
           
        }
    }
    
    
    func fetchFBDetails(user: FIRUser) {
        
        let requestParameters = ["fields": "id, email, name"]
        
        FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: requestParameters).start { (connection, result, error) in
            
            if error != nil {
                print("Failed to start graph request...", error)
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
                    
                    guard let data = result["data"] as? NSDictionary else {
                    
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