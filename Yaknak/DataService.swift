//
//  DataService.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
import FirebaseStorage


class DataService {
    
    
    static let dataService = DataService()
    
    
    private var _BASE_REF = FIRDatabase.database().reference(fromURL: Constants.Config.BASE_Url)
    private var _USER_REF = FIRDatabase.database().reference(fromURL: Constants.Config.USER_Url)
    private var _TIP_REF = FIRDatabase.database().reference(fromURL: Constants.Config.TIP_Url)
    private var _CATEGORY_REF = FIRDatabase.database().reference(fromURL: Constants.Config.CATEGORY_Url)
    private var _USER_TIP_REF = FIRDatabase.database().reference(fromURL: Constants.Config.USER_TIPS_Url)
    private var _GEO_REF = FIRDatabase.database().reference(fromURL: Constants.Config.GEO_Url)
    private var _GEO_TIP_REF = FIRDatabase.database().reference(fromURL: Constants.Config.GEO_TIP_Url)
    private var _GEO_USER_REF = FIRDatabase.database().reference(fromURL: Constants.Config.GEO_USER_Url)
    private var _STORAGE_REF = FIRStorage.storage().reference(forURL: Constants.Config.STORAGE_Url)
    private var _STORAGE_PROFILE_IMAGE_REF = FIRStorage.storage().reference(forURL: Constants.Config.STORAGE_PROFILE_IMAGE_Url)
    private var _STORAGE_TIP_IMAGE_REF = FIRStorage.storage().reference(forURL: Constants.Config.STORAGE_TIP_IMAGE_Url)
    
    
    
    var BASE_REF: FIRDatabaseReference {
        return _BASE_REF
    }
    
    var USER_REF: FIRDatabaseReference {
        return _USER_REF
    }
    
    var STORAGE_REF: FIRStorageReference {
        return _STORAGE_REF
    }
    
    var STORAGE_PROFILE_IMAGE_REF: FIRStorageReference {
        return _STORAGE_PROFILE_IMAGE_REF
    }

    var STORAGE_TIP_IMAGE_REF: FIRStorageReference {
        return _STORAGE_TIP_IMAGE_REF
    }

    
    var CURRENT_USER_REF: FIRDatabaseReference {
        var currentUser = FIRDatabaseReference()
        var userId = String()
        if (UserDefaults.standard.object(forKey: "uid") != nil) {
            userId = UserDefaults.standard.value(forKey: "uid") as! String
        }
        else {
            if (FIRAuth.auth()?.currentUser != nil) {
            userId = (FIRAuth.auth()?.currentUser?.uid)!
            UserDefaults.standard.set(userId, forKey: "uid")
            }
            else {
            userId = "placeholderId"
            }
        }
        currentUser = _USER_REF.child(userId)
        
        
        return currentUser
    }
    
    
    var TIP_REF: FIRDatabaseReference {
        return _TIP_REF
    }
    
    var CATEGORY_REF: FIRDatabaseReference {
        return _CATEGORY_REF
    }
    
    var USER_TIP_REF: FIRDatabaseReference {
        return _USER_TIP_REF
    }
    
    var GEO_REF: FIRDatabaseReference {
        return _GEO_REF
    }
    
    var GEO_TIP_REF: FIRDatabaseReference {
        return _GEO_TIP_REF
    }
    
    var GEO_USER_REF: FIRDatabaseReference {
        return _GEO_USER_REF
    }
    
    
    // 4 ---- Signing in the User
    func signIn(email: String, password: String, completion: @escaping (Bool) -> ()) {
        
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: password)
        
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            
            if error == nil {
                
                if user != nil {
                    
                    if (user?.isEmailVerified)! {
                    
                    appDel.redirectUser()
                    completion(true)
                }
                    else {
                        
                        // TODO - different alert
                        let alertController = UIAlertController()
                        alertController.verificationAlert(title: "Info", message: "Sorry! Your email address has not yet been verified. Do you want us to send another verification email?", user: user!)
                        completion(false)
                    }
                }
            }
            else {
                
                let title = "Oops!"
                let message = "Please enter correct email and password."
                appDel.showErrorAlert(title: title, message: message)
                
            }
            
        })
        
    }
    
    
    // We create the User
    
    func signUp(email: String, name: String, password: String, data: NSData, completion: @escaping (Bool) -> ()) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if error == nil {
               
                user?.sendEmailVerification(completion: { (error) in
                    
                    if error == nil {
                         self.setUserInfo(user: user, name: name, password: password, data: data, totalLikes: 0, totalTips: 0)
                        completion(true)
                    
                    }
                    else {
                    print(error?.localizedDescription)
                        completion(false)
                    
                    }
                    
                    
                })
               
               
                
            }
            else {
                print(error!.localizedDescription)
                
                let title = "Oops!"
                let message = "The email address is already in use by another account."
                appDel.showErrorAlert(title: title, message: message)
                completion(false)
                
            }
        })
        
        
    }
    
    
    // Reset Password
    
    func resetPassword(email: String) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
        
            var title = ""
            var message = ""
            
            if error == nil {
                
                title = "Success!"
                message = "Password reset email sent."
                print(message)
            }
            else {
                
                title = "Oops!"
                message = error!.localizedDescription
                print(message)
                
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            alertController.show()
        })
        
    }
    
    
    
    // Set User Info
    
    private func setUserInfo(user: FIRUser!, name: String, password: String, data: NSData!, totalLikes: Int, totalTips: Int) {
        
        //Create Path for the User Image
        let imagePath = "\(user.uid)/userPic.jpg"
        
        
        // Create image Reference
        
        let imageRef = STORAGE_PROFILE_IMAGE_REF.child(imagePath)
        
        // Create Metadata for the image
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        // Save the user Image in the Firebase Storage File
        
        imageRef.put(data as Data, metadata: metaData) { (metaData, error) in
            if error == nil {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = name
                changeRequest.photoURL = metaData!.downloadURL()
                changeRequest.commitChanges(completion: { (error) in
                    
                    if error == nil {
                        
                        self.saveInfo(user: user, name: name, password: password, totalLikes: totalLikes, totalTips: totalTips)
                        
                        
                    }else{
                        print(error!.localizedDescription)
                        
                    }
                })
                
                
            }
            else {
                print(error!.localizedDescription)
                
            }
            
        }
        
        
        
    }
    
    // Saving the user Info in the database
    
    private func saveInfo(user: FIRUser!, name: String, password: String, totalLikes: Int, totalTips: Int) {
        
        // Create our user dictionary info\
        
        let userInfo = ["email": user.email!, "name": name, "uid": user.uid, "photoUrl": String(describing: user.photoURL!), "totalLikes": totalLikes, "totalTips": totalTips] as [String : Any]
        
        // create user reference
        
        let userRef = _USER_REF.child(user.uid)
        
        // Save the user info in the Database and in UserDefaults
        
        // Store the uid for future access - handy!
        UserDefaults.standard.setValue(user.uid, forKey: "uid")
        
        userRef.setValue(userInfo)
  //      self.signIn(email: user.email!, password: password)
        
       /*
        // Email verification
        
        if (user.isEmailVerified) {
        // Signing in the user
        self.signIn(email: user.email!, password: password)
        }
        else {
            let title = "Info"
            let message = "Sorry! Your email address has not yet been verified. Do you want us to send another verification email to \(user.email)?"
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "OK", style: .default) {
                (_) in
                user?.sendEmailVerification(completion: nil)
            }
           
            let titleMutableString = NSAttributedString(string: title, attributes: [
                NSFontAttributeName : UIFont.systemFont(ofSize: 17),
                NSForegroundColorAttributeName : UIColor.primaryTextColor()
                ])
            
            alertVC.setValue(titleMutableString, forKey: "attributedTitle")
            
            let messageMutableString = NSAttributedString(string: message, attributes: [
                NSFontAttributeName : UIFont.systemFont(ofSize: 15),
                NSForegroundColorAttributeName : UIColor.primaryTextColor()
                ])
            
            alertVC.setValue(messageMutableString, forKey: "attributedMessage")

            
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           
            alertActionOkay.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
            alertVC.addAction(alertActionOkay)
            alertVC.addAction(alertActionCancel)
            alertVC.show()
        }
*/
        
    }
    
    
}
