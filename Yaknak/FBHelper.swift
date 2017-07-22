//
//  FBHelper.swift
//  Yaknak
//
//  Created by Sascha Melcher on 20/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import UIKit
import Firebase


class FBHelper {
    
    private var _loginManager: FBSDKLoginManager?
    
    private var loginManager: FBSDKLoginManager? {
        get {
            
            if _loginManager == nil {
                _loginManager = FBSDKLoginManager()
            }
            
            return _loginManager
        }
    }
    
    private var currentConnection: FBSDKGraphRequestConnection?
    private var dataService: DataService? {
    return DataService()
    }
    
    private var accessToken: String? {
        return FBSDKAccessToken.current().tokenString
    }

    public init() {}
    
    deinit {
        cancel()
    }
    
    
    func cancel() {
        currentConnection?.cancel()
        currentConnection = nil
    }
    
    private func logOut() {
        loginManager?.logOut()
    }
    
    
    public func load(viewController: UIViewController? = nil, onError: @escaping ()->(), onSuccess: @escaping (String)->()) {
        
        cancel()
        logOut()
        logIn(viewController: viewController, onError: onError, onSuccess: onSuccess)
     //   logInAndLoadUserProfile(viewController: viewController, onError: onError, onSuccess: onSuccess)
    }
    
    
    private func logIn(viewController: UIViewController? = nil, onError: @escaping ()->(), onSuccess: @escaping (String)->()) {
    
        let permissions = ["email", "public_profile", "user_friends"]
        
        loginManager?.logIn(withReadPermissions: permissions, from: viewController) { result, error in
            
            if let error = error {
                print(error.localizedDescription)
                onError()
                return
            }
            else {
                
                if let result = result {
                    
                    if result.isCancelled {
                        onError()
                        return
                    }
                    
                    guard let accessToken = FBSDKAccessToken.current() else {
                        onError()
                        return
                    }
                    
                    if let token = accessToken.tokenString {
                    onSuccess(token)
                    }
                    
                }
                
                
            }
            
        }
    
    
    }
    
  
  /*
    private func logInAndLoadUserProfile(viewController: UIViewController? = nil, onError: @escaping ()->(),
                                         onSuccess: @escaping (FacebookUser)->()) {
        
        let permissions = ["email", "public_profile", "user_friends"]
        
        loginManager?.logIn(withReadPermissions: permissions, from: viewController) { [weak self] result, error in
            
            if let error = error {
                print(error.localizedDescription)
                onError()
                return
            }
            else {
            
                if let result = result {
                
                    if result.isCancelled {
                        onError()
                        return
                    }
                    
                     self?.loadFacebookInfo(onError, onSuccess)
                    
                }
            
            
            }
           
        }
    }
    */
    
    /// Loads user profile information from Facebook.
    public func loadFacebookInfo(_ user: User, _ onError: @escaping ()->(), _ onSuccess: @escaping (FacebookUser?) -> ()) {
        
        let imagePath = "\(user.uid)/userPic.jpg"
        if let imageRef = self.dataService?.STORAGE_PROFILE_IMAGE_REF.child(imagePath) {
        
        imageRef.getData(maxSize: 1 * 1024 * 1024, completion: { (data: Data?, error: Error?) in
            
            if let err = error {
                print("no image stored yet.../" + err.localizedDescription)
              
               self.graphRequest({
                 onError()
               }, { (facebookUser) in
                onSuccess(facebookUser)
               })
                
                
            }
            else {
                
                if let _ = data {
                    
                    print("User already exists in database...")
                   onSuccess(nil)
                }
                else {
                    
                    self.graphRequest({
                        onError()
                    }, { (facebookUser) in
                        onSuccess(facebookUser)
                    })
                    
                }
                
            }
            
        })
    }
    
    }
    
    
    
    private func graphRequest(_ onError: @escaping ()->(), _ onSuccess: @escaping (FacebookUser) -> ()) {
    
        if FBSDKAccessToken.current() == nil {
            onError()
            return
        }
        
        let params = ["fields": "id, email, name, picture.width(300).height(300).type(large).redirect(false), user_friends"]
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        
        currentConnection = graphRequest?.start { [weak self] connection, result, error in
          
            if error != nil {
                onError()
                return
            }
            
            if let userData = result as? NSDictionary, let accessToken = self?.accessToken, let user = FBHelper.parseData(result: userData as! [String : Any], accessToken: accessToken) {
                
                onSuccess(user)
            } else {
                onError()
            }
        }
        
    }
    
    /// Parses user profile dictionary returned by Facebook SDK.
    class func parseData(result: [String : Any], accessToken: String?) -> FacebookUser? {
        if let id = result["id"] as? String {
            if let picObject = result["picture"] as? [String : Any] {
                if let data = picObject["data"] as? [String : Any] {
                if let urlPic = data["url"] as? String {
                    var fbToken = String()
                    var email = String()
                    if let token = accessToken {
                    fbToken = token
                    }
                    else {
                    fbToken = ""
                    }
                    if let mail = result["email"] as? String {
                        
                        email = mail
                    }
                    else {
                        email = id + "@facebook.com"
                    }
                    return FacebookUser(
                        id: id,
                        accessToken: fbToken,
                        email: email,
                        name: result["name"] as? String,
                        picUrl: urlPic)
                }
            }
        }
        }
        return nil
    }
    
    
    /** Stores new Facebook user in database */
    func storeNewFacebookUser(_ url: String, _ user: User, _ fbUser: FacebookUser, completion: @escaping (Bool)->()) {
        
        guard let urlString = URL(string: url), let imageData = NSData(contentsOf: urlString) else {
            return
        }
        
        let imagePath = "\(user.uid)/userPic.jpg"
        if let imageRef = self.dataService?.STORAGE_PROFILE_IMAGE_REF.child(imagePath) {
        
        // Create Metadata for the image
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.putData(imageData as Data, metadata: metaData) { (metaData, error) in
            if error == nil {
                
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = fbUser.name
                changeRequest.photoURL = metaData!.downloadURL()
                changeRequest.commitChanges(completion: { (error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                    }
                        
                    else {
                        
                        guard let url = user.photoURL?.absoluteString, let email = fbUser.email, let name = fbUser.name else {return}
                        
                        let userInfo = ["email": email, "name": name, "facebookId": fbUser.id, "photoUrl": url, "totalLikes": 0, "totalTips": 0, "isActive": true, "showTips": true] as [String : Any]
                        
                        // create user reference
                        
                        if let userRef = self.dataService?.USER_REF.child(user.uid) {
                            if let fbRef = self.dataService?.FB_USER_REF.child(fbUser.id) {
                        
                        // Save the user info in the Database and in UserDefaults
                        
                        // Store the uid for future access - handy!
                        UserDefaults.standard.setValue(user.uid, forKey: "uid")
                        
                        userRef.setValue(userInfo, withCompletionBlock: { (error, ref) in
                            
                            if let err = error {
                                print(err.localizedDescription)
                                completion(false)
                            }
                            else {
                                fbRef.setValue(["uid": user.uid], withCompletionBlock: { (error, ref) in
                                    
                                    if let err = error {
                                        print(err.localizedDescription)
                                        completion(false)
                                    }
                                    else {
                                        print("Facebook user stored in database...")
                                       self.fetchFBFriends({
                                        completion(true)
                                       }, { (friends) in
                                        
                                        if let fbFriends = friends {
                                        var friendsDict = [String : Any]()
                                        
                                        for friend in fbFriends {
                                                friendsDict[friend.id] = true
                                        }
                                            if let userRef = self.dataService?.USER_REF.child(user.uid).child("friends") {
                                            userRef.updateChildValues(friendsDict, withCompletionBlock: { (error, ref) in
                                                
                                                if let err = error {
                                                    print(err.localizedDescription)
                                                    completion(true)
                                                }
                                                else {
                                                    print("FB friends stored in database...")
                                                     completion(true)
                                                }
                                            })
                                        }
                                        }
                                        else {
                                        completion(true)
                                        }
                                        
                                       })
                                    }
                                    
                                })
                            }
                        })
                    }
                }
                    }
                })
                
                
            }
            else {
                completion(false)
            }
            
        }
    }
    
    }
    
    
    private func fetchFBFriends(_ onError: @escaping ()->(), _ onSuccess: @escaping ([FacebookUser]?) -> ()) {
        
        let params = ["fields": "id, email, name, picture.width(480).height(480)"]
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: params)
        
        currentConnection = graphRequest?.start { connection, result, error in
            
            if let err = error {
                print("Failed to start graph request...", err.localizedDescription)
                onError()
                return
            }
            else {
                
                if let result = result as? [String: Any] {
                    if let data = result["data"] as? NSArray {
                        
                        var friends = [FacebookUser]()
                        
                        for i in 0..<data.count {
                        
                        if let userData = data[i] as? NSDictionary, let user = FBHelper.parseData(result: userData as! [String : Any], accessToken: nil) {
                        friends.append(user)
                        }
                        else {
                            onError()
                            }
                        
                    }
                        onSuccess(friends)
                }
                
            }
            
        }
        
    }
}
    
    
    /** Updates user's Facebook data */
    func updateFBStatus(_ user: User, completion: @escaping () -> ()) {
        
        var facebookId = String()
        
        self.dataService?.getUser(user.uid, completion: { (currentUser) in
            
            if currentUser.facebookId == nil || currentUser.facebookId.isEmpty {
                
                for item in user.providerData {
                    if (item.providerID == "facebook.com") {
                        facebookId = item.uid
                        break
                    }
                }
                self.dataService?.USER_REF.child(user.uid).updateChildValues(["facebookId" : facebookId], withCompletionBlock: { (error, ref) in
                    
                    if let err = error {
                        print(err.localizedDescription)
                        completion()
                    }
                    else {
                        print("FacebookId updated...")
                        guard let fbID = currentUser.facebookId else {return}
                        self.dataService?.setFacebookUser(fbID, user.uid, completion: {
                            self.fetchFBFriends({
                                completion()
                            }, { (friends) in
                                
                                if let fbFriends = friends {
                                    var friendsDict = [String : Any]()
                                    
                                    for friend in fbFriends {
                                        friendsDict[friend.id] = true
                                    }
                                    if let userRef = self.dataService?.USER_REF.child(user.uid).child("friends") {
                                        userRef.updateChildValues(friendsDict, withCompletionBlock: { (error, ref) in
                                            
                                            if let err = error {
                                                print(err.localizedDescription)
                                                completion()
                                            }
                                            else {
                                                print("FB friends stored in database...")
                                                completion()
                                            }
                                        })
                                    }
                                }
                                else {
                                    print("None of your Facebook friends use this app...")
                                    completion()
                                }
                                
                            })
                        })
                    }
                })
            }
            else {
                print("FacebookId already stored...")
                guard let fbID = currentUser.facebookId else {return}
                self.dataService?.setFacebookUser(fbID, user.uid, completion: {
                    self.fetchFBFriends({
                        completion()
                    }, { (friends) in
                        
                        if let fbFriends = friends {
                            var friendsDict = [String : Any]()
                            
                            for friend in fbFriends {
                                friendsDict[friend.id] = true
                            }
                            if let userRef = self.dataService?.USER_REF.child(user.uid).child("friends") {
                                userRef.updateChildValues(friendsDict, withCompletionBlock: { (error, ref) in
                                    
                                    if let err = error {
                                        print(err.localizedDescription)
                                        completion()
                                    }
                                    else {
                                        print("FB friends stored in database...")
                                        completion()
                                    }
                                })
                            }
                        }
                        else {
                            print("None of your Facebook friends use this app...")
                            completion()
                        }
                        
                    })
                })
            }
        })
    }

}
