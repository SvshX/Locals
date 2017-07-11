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
import GeoFire


class DataService {
    
    
    static let dataService = DataService()
    
    private var _BASE_REF = Database.database().reference(fromURL: Constants.Config.BASE_Url)
    private var _USER_REF = Database.database().reference(fromURL: Constants.Config.USER_Url)
    private var _FB_USER_REF = Database.database().reference(fromURL: Constants.Config.FB_USER_Url)
    private var _TIP_REF = Database.database().reference(fromURL: Constants.Config.TIP_Url)
    private var _CATEGORY_REF = Database.database().reference(fromURL: Constants.Config.CATEGORY_Url)
    private var _USER_TIP_REF = Database.database().reference(fromURL: Constants.Config.USER_TIPS_Url)
    private var _GEO_REF = Database.database().reference(fromURL: Constants.Config.GEO_Url)
    private var _GEO_TIP_REF = Database.database().reference(fromURL: Constants.Config.GEO_TIP_Url)
    private var _GEO_USER_REF = Database.database().reference(fromURL: Constants.Config.GEO_USER_Url)
    private var _STORAGE_REF = Storage.storage().reference(forURL: Constants.Config.STORAGE_Url)
    private var _STORAGE_PROFILE_IMAGE_REF = Storage.storage().reference(forURL: Constants.Config.STORAGE_PROFILE_IMAGE_Url)
    private var _STORAGE_TIP_IMAGE_REF = Storage.storage().reference(forURL: Constants.Config.STORAGE_TIP_IMAGE_Url)
    
    
    var circleQuery = GFCircleQuery()
    
    var BASE_REF: DatabaseReference {
        return _BASE_REF
    }
    
    var USER_REF: DatabaseReference {
        return _USER_REF
    }
    
    var FB_USER_REF: DatabaseReference {
        return _FB_USER_REF
    }
    
    var STORAGE_REF: StorageReference {
        return _STORAGE_REF
    }
    
    var STORAGE_PROFILE_IMAGE_REF: StorageReference {
        return _STORAGE_PROFILE_IMAGE_REF
    }
    
    var STORAGE_TIP_IMAGE_REF: StorageReference {
        return _STORAGE_TIP_IMAGE_REF
    }
    
   
    
    
    var CURRENT_USER_REF: DatabaseReference {
        
        if let id = Auth.auth().currentUser?.uid {
            return USER_REF.child("\(id)")
        }
        else {
            if (UserDefaults.standard.object(forKey: "uid") != nil) {
                if let id = UserDefaults.standard.value(forKey: "uid") as? String {
                    return USER_REF.child("\(id)")
                }
            }
        }
        return DatabaseReference()
    }
    
    
    var TIP_REF: DatabaseReference {
        return _TIP_REF
    }
    
    var CATEGORY_REF: DatabaseReference {
        return _CATEGORY_REF
    }
    
    var USER_TIP_REF: DatabaseReference {
        return _USER_TIP_REF
    }
    
    var GEO_REF: DatabaseReference {
        return _GEO_REF
    }
    
    var GEO_TIP_REF: DatabaseReference {
        return _GEO_TIP_REF
    }
    
    var GEO_USER_REF: DatabaseReference {
        return _GEO_USER_REF
    }
    
    
    // MARK: - Account Related
    
    // ---- Signing in the User
    func signIn(_ email: String, _ password: String, completion: @escaping (Bool, User?) -> ()) {
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            
            if let err = error {
                print(err.localizedDescription)
                completion(false, nil)
            }
            else {
                if let user = user {
                    
                    if (user.isEmailVerified) {
                        completion(true, user)
                    }
                    else {
                        completion(false, user)
                    }
                }
            }
            
        })
        
    }
    
    
    // ---- Creating the User
    func signUp(_ email: String, _ name: String, _ password: String, _ data: NSData, completion: @escaping (Bool) -> ()) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if let err = error {
                print(err.localizedDescription)
                completion(false)
            }
            else {
                
                if let user = user {
                    user.sendEmailVerification(completion: { (error) in
                        
                        if let err = error {
                            print(err.localizedDescription)
                            completion(false)
                        }
                        else {
                            self.setUserInfo(user, name, password, data, completion: { (success) in
                                
                                if success {
                                    completion(true)
                                }
                            })
                        }
                        
                    })
                }
            }
        })
    }
    
    
    // ---- Reset Password
    func resetPassword(_ email: String, completion: @escaping (Bool, String) -> ()) {
        
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            
            if let err = error {
                print(err.localizedDescription)
                completion(false, err.localizedDescription)
            }
            else {
                completion(true, "Password reset email sent")
            }
        })
        
    }
    
    
    
    // ---- Set User Info
    private func setUserInfo(_ user: User!, _ name: String, _ password: String, _ data: NSData!, completion: @escaping (Bool) -> ()) {
        
        //Create Path for the User Image
        let imagePath = "\(user.uid)/userPic.jpg"
        
        
        // Create image Reference
        
        let imageRef = STORAGE_PROFILE_IMAGE_REF.child(imagePath)
        
        // Create Metadata for the image
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        // Save the user Image in the Firebase Storage File
        
        imageRef.putData(data as Data, metadata: metaData) { (metaData, error) in
            
            if let err = error {
                print(err.localizedDescription)
            }
            else {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.photoURL = metaData!.downloadURL()
                changeRequest.commitChanges(completion: { (error) in
                    
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    else {
                        self.saveInfo(user, name, password, completion: { (success) in
                            
                            if success {
                                completion(true)
                            }
                        })
                    }
                })
            }
            
        }
        
        
        
    }
    
    // ---- Saving user info in database
    
    private func saveInfo(_ user: User, _ name: String, _ password: String, completion: @escaping (Bool) -> ()) {
        
        // create user dictionary info
        if let email = user.email {
            if let url = user.photoURL?.absoluteString {
                
                let userInfo = ["email": email, "name": name, "photoUrl": url, "totalLikes": 0, "totalTips": 0, "isActive": true, "showTips": true] as [String : Any]
                
                // create user reference
                let userRef = _USER_REF.child(user.uid)
                
                // Save the user info in the Database and in UserDefaults
                
                // Store the uid for future access - handy!
                UserDefaults.standard.setValue(user.uid, forKey: "uid")
                
                userRef.setValue(userInfo, withCompletionBlock: { (error, ref) in
                    
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    else {
                        completion(true)
                    }
                })
            }
        }
    }
    
    
    // MARK: - User Functions
    
    /** Gets the current User object for the specified user id */
    func getCurrentUser(_ completion: @escaping (MyUser) -> ()) {
        CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            completion(MyUser(snapshot: snapshot))
        })
    }
    
    
    /** Observes current user */
    func observeCurrentUser(_ completion: @escaping (MyUser) -> ()) {
        CURRENT_USER_REF.observe(.value, with: { (snapshot) in
            completion(MyUser(snapshot: snapshot))
        })
    }
    
    
    /** Gets the User object for the specified user id */
    func getUser(_ userID: String, completion: @escaping (MyUser) -> ()) {
        USER_REF.child(userID).keepSynced(true)
        USER_REF.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(MyUser(snapshot: snapshot))
        })
    }
    
    
    /** Gets the FacebookUser object for the specified user id */
    func getFacebookUser(_ facebookID: String, completion: @escaping (_ uid: String?) -> ()) {
    FB_USER_REF.child(facebookID).observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let dict = snapshot.value as? [String : Any] {
            if let uid = dict["uid"] as? String {
                completion(uid)
            }
        }
        else {
        completion(nil)
        }
        
    })
    }
    
    
    /** Sets FacebookUser */
    func setFacebookUser(_ facebookID: String, _ uid: String, completion: @escaping () -> ()) {
        
        FB_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(facebookID) {
                print("User is already a Facebook user...")
                completion()
            }
            else {
                let fbRef = self.FB_USER_REF.child(facebookID)
                fbRef.setValue(["uid": uid], withCompletionBlock: { (error, ref) in
                    
                    if let err = error {
                        print(err.localizedDescription)
                        completion()
                    }
                    else {
                        print("Facebook user stored in database...")
                        completion()
                    }
                    
                })
            }
            
        }) { (error) in
            print(error.localizedDescription)
            completion()
        }
        
    }
    
    
    
    /** Gets the tip object for specified id */
    func getTip(_ tipID: String, completion: @escaping (Tip) -> Void) {
        TIP_REF.child(tipID).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(Tip(snapshot: snapshot))
        })
    }
    
    
    /** Gets user's tips */
    func getUsersTips(_ uid: String, completion: @escaping ([Tip], MyUser?) -> ()) {
    
        self.getUser(uid) { (user) in
            
        if let tips = user.totalTips {
            
            if let uid = user.key {
                
                var userTips = [Tip]()
                
                if tips > 0 {
                    
                    self.USER_TIP_REF.child(uid).keepSynced(true)
                    self.USER_TIP_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                      
                        if snapshot.hasChildren() {
                            
                        var tipArray = [Tip]()
                        
                        for tip in snapshot.children.allObjects as! [DataSnapshot] {
                            
                            let tipObject = Tip(snapshot: tip)
                            tipArray.append(tipObject)
                            
                        }
                          userTips = tipArray.reversed()
                          completion(userTips, user)
                        
                    }
                        else {
                        print("User has no tips...")
                        completion(userTips, user)
                    }
                    })
                    
                }
                else {
                    print("User has no tips...")
                    completion(userTips, user)
                }
                
            }
        }
        
    }
    
    }
    
    
    /** Gets friend's profile */
    func getFriendsProfile(_ uid: String, completion: @escaping (Bool, [Tip], [MyUser]?, Bool) -> ()) {
    
    self.getUsersTips(uid) { (tips, user) in
        
        if let user = user {
        self.getFriends(user, completion: { (friends) in
            
            if let key = user.key, let friends = friends {
            self.getFriendsDefaultHideTips(key, completion: { (success, isHidden) in
                
                if success {
                completion(true, tips, friends, isHidden)
                }
                else {
                completion(true, tips, friends, false)
                }
            })
            }
            else {
            completion(true, tips, nil, false)
            }
        })
        }
        }
    
    
    }
    
    
    func getFriends(_ user: MyUser, completion: @escaping ([MyUser]?) -> ()) {
    
         var friendsArray = [MyUser]()
        
        if let friends = user.friends {
            
            let group = DispatchGroup()
            for friend in friends {
                
                group.enter()
                self.getFacebookUser(friend.key, completion: { (uid) in
                    
                   
                    if let uid = uid {
                    self.getUser(uid, completion: { (userFriend) in
                        friendsArray.append(userFriend)
                        group.leave()
                        
                    })
                }
                    else {
                group.leave()
                }
                
                })
            }
            group.notify(queue: DispatchQueue.main) {
               completion(friendsArray)
            }
            
        }
        else {
        print("Something went wrong...")
            completion(friendsArray)
        }
    
    }
    
    
    /** Sets user's privacy setting */
    func setDefaultHideTips(_ hide: Bool, completion: @escaping (_ success: Bool) -> ()) {
    self.getCurrentUser { (user) in
        
        self.CURRENT_USER_REF.updateChildValues(["hideTips" : hide], withCompletionBlock: { (error, ref) in
            
            if let err = error {
            print(err.localizedDescription)
                completion(false)
            }
            else {
                print("Privacy set...")
            completion(true)
            }
        })
        
        }
    }
    
    
    /** Gets user's privacy setting */
    func getDefaultHideTips(completion: @escaping (_ success: Bool, _ hide: Bool) -> ()) {
    
        self.getCurrentUser { (user) in
            if let hide = user.hideTips {
                completion(true, hide)
            }
            else {
                print("User does not have property 'showTips' yet...")
                completion(false, false)
            }
            
        }
    
    }
    
    
    /** Gets friends's privacy setting */
    func getFriendsDefaultHideTips(_ userID: String, completion: @escaping (_ success: Bool, _ hide: Bool) -> ()) {
    
        self.getUser(userID) { (user) in
            
            if let hide = user.hideTips {
            completion(true, hide)
            }
            else {
            print("Your friend does not have property 'showTips' yet...")
            completion(false, false)
            }
        }
    }
    
    
    // MARK: - Request System Functions
    
    /** Update current user's tips */
    func updateUsersTips(_ userID: String, _ photoUrl: String, completion: @escaping (Bool) -> Void) {
        
    TIP_REF.queryOrdered(byChild: "addedByUser").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshot) in
        
        for tip in snapshot.children.allObjects as! [DataSnapshot] {
        
            self.TIP_REF.observeSingleEvent(of: .value, with: { (tipSnap) in
                
                if tipSnap.hasChild(tip.key) {
                
                    self.USER_TIP_REF.child(userID).observeSingleEvent(of: .value, with: { (userSnap) in
                        
                        if userSnap.hasChild(tip.key) {
                            
                            if let category = (tip.value as! NSDictionary)["category"] as? String {
                                
                                self.CATEGORY_REF.child(category).observeSingleEvent(of: .value, with: { (catSnap) in
                                    
                                    if catSnap.hasChild(tip.key) {
                                    
                                    let updateObject = ["tips/\(tip.key)/userPicUrl" : photoUrl, "userTips/\(userID)/\(tip.key)/userPicUrl" : photoUrl, "categories/\(category)/\(tip.key)/userPicUrl" : photoUrl]
                                        
                                        self.BASE_REF.updateChildValues(updateObject, withCompletionBlock: { (error, ref) in
                                            
                                            if error == nil {
                                            completion(true)
                                            }
                                            else {
                                            completion(false)
                                            }
                                            
                                        })
                                    
                                    }
                                    
                                })
                                
                                
                            }
                            
                        }
                        
                    })
                
                }
                
            })
            
        }
    })
    }
    
    
    /** Adds a profile pic observer */
    func addProfilePicObserver(completion: @escaping (URL) -> ()) {
        
        CURRENT_USER_REF.observe( .value, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String : Any] {
                if let photoUrl = dictionary["photoUrl"] as? String {
                    if let url = URL(string: photoUrl) {
                   completion(url)
                    }
                }
            }
            
        })
        
    }
    
    
    /** Removes current user observer */
    func removeCurrentUserObserver() {
    CURRENT_USER_REF.removeAllObservers()
    }
    
    /** Removes current user tips observer */
    func removeUsersTipsObserver(_ uid: String) {
        USER_TIP_REF.child(uid).removeAllObservers()
    }
    
    
    /** Handles like count on swiping right */
    func handleLikeCount(_ tip: Tip, completion: @escaping (Bool, Bool, Error?) -> ()) {
        
        let tipListRef = CURRENT_USER_REF.child("tipsLiked")
        CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let key = tip.key else {return}
            let likedBefore = snapshot.hasChild("tipsLiked")
            let hasLiked = snapshot.childSnapshot(forPath: "tipsLiked").hasChild(key)
            
                
                if likedBefore && hasLiked {
                    completion(true, false, nil)
                }
                else {
                    tipListRef.updateChildValues([key : true])
                    self.incrementTip(tip, completion: { (success, error) in
                        
                        if success {
                            completion(true, true, nil)
                        }
                        else {
                            completion(false, false, error)
                        }
                    })
                }
        
        })
    }
    
    
    /** Increments tip like count */
    private func incrementTip(_ tip: Tip, completion: @escaping (Bool, Error?) -> ()) {
        
        guard let key = tip.key else {return}
            TIP_REF.child(key).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                
                if var data = currentData.value as? [String : Any] {
                    var count = data["likes"] as! Int
                    
                    count += 1
                    data["likes"] = count
                    
                    currentData.value = data
                    
                    return TransactionResult.success(withValue: currentData)
                }
                return TransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    completion(false, error)
                }
                if committed {
                    
                    if let snap = snapshot?.value as? [String : Any] {
                        
                        if let likes = snap["likes"] as? Int {
                            self.CATEGORY_REF.child(tip.category).child(key).updateChildValues(["likes" : likes])
                            self.USER_TIP_REF.child(tip.addedByUser).child(key).updateChildValues(["likes" : likes])
                            
                        }
                        
                    }
                    
                    if let snapshot = snapshot {
                    let tip = Tip(snapshot: snapshot)
                    self.incrementUser(tip, completion: { (success) in
                        
                        if success {
                        completion(true, nil)
                        }
                        else {
                        completion(false, error)
                        }
                    })
                    }
                }
            }
        
    }
    
    
    /** Increments user like count */
    private func incrementUser(_ tip: Tip, completion: @escaping (Bool) -> Void) {
        
        if let userId = tip.addedByUser {
            self.USER_REF.child(userId).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                
                if var data = currentData.value as? [String : Any] {
                    var count = data["totalLikes"] as! Int
                    
                    count += 1
                    data["totalLikes"] = count
                    
                    currentData.value = data
                    
                    return TransactionResult.success(withValue: currentData)
                }
                return TransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    completion(false)
                    print(error.localizedDescription)
                }
                if committed {
                    completion(true)
                }
            }
        }
    }
    
    
    /** Removes like count */
    func removeTipFromList(tip: Tip, completion: @escaping (Bool, Error?) -> ()) {
        
        let tipListRef = CURRENT_USER_REF.child("tipsLiked")
        tipListRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let key = tip.key {
                let a = snapshot.hasChild(key)
                
                if a {
                    tipListRef.child(key).removeValue()
                    self.decrementTip(tip, completion: { (success, error) in
                        
                        if success {
                        completion(true, error)
                        }
                        else {
                            if let err = error {
                            completion(false, err)
                            }
                        }
                    })
                }
                else {
                    completion(false, nil)
                    print("tip does not exist in list...")
                }
            }
            
        })
    }
    
    
    private func decrementTip(_ tip: Tip, completion: @escaping (Bool, Error?) -> ()) {
        
        if let key = tip.key {
            if let category = tip.category {
                if let userId = tip.addedByUser {
                    
                    TIP_REF.child(key).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                        
                        if var data = currentData.value as? [String : Any] {
                            var count = data["likes"] as! Int
                            
                            count -= 1
                            data["likes"] = count
                            
                            currentData.value = data
                            
                            
                            return TransactionResult.success(withValue: currentData)
                        }
                        return TransactionResult.success(withValue: currentData)
                        
                    }) { (error, committed, snapshot) in
                        if let error = error {
                            completion(false, error)
                            print(error.localizedDescription)
                        }
                        if committed {
                            
                            if let snap = snapshot?.value as? [String : Any] {
                                
                                if let likes = snap["likes"] as? Int {
                                    
                                    
                                    let updateObject = ["userTips/\(userId)/\(key)/likes" : likes, "categories/\(category)/\(key)/likes" : likes]
                                    
                                    self.BASE_REF.updateChildValues(updateObject, withCompletionBlock: { (error, ref) in
                                        
                                        if error == nil {
                                            print("Successfully updated all like counts...")
                                        }
                                        else {
                                            print("Updating failed...")
                                        }
                                    })
                                    
                                }
                                
                            }
                            self.decrementUser(tip, completion: { (success, error) in
                                
                                if success {
                                completion(true, error)
                                }
                                else {
                                    if let err = error {
                                    completion(false, err)
                                    }
                                }
                            })
                            print(Constants.Logs.TipDecrementSuccess)
                        }
                    }
                }
            }
        }
    }
    
    
    private func decrementUser(_ tip: Tip, completion: @escaping (Bool, Error?) -> ()) {
        
        if let uid = tip.addedByUser {
            USER_REF.child(uid).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                
                if var data = currentData.value as? [String : Any] {
                    var count = data["totalLikes"] as! Int
                    
                    count -= 1
                    data["totalLikes"] = count
                    
                    currentData.value = data
                    
                    return TransactionResult.success(withValue: currentData)
                }
                return TransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    completion(false, error)
                }
                if committed {
                    completion(true, error)
                 //   self.showSuccessInUI(tip: tip)
                }
            }
        }
        
        
    }
    
 /*
    /** Upload tip */
    func uploadTip(_ pic: Data, _ description: String, _ category: String, _ placeID: String?, _ coordinates: CLLocationCoordinate2D, completion: @escaping (Bool) -> ()) {
        
        self.getCurrentUser { (user) in
            
            if let uid = user.key {
                
                if let name = user.name {
                    
                    if let url = user.photoUrl {
                        
                        let tipRef = self.TIP_REF.childByAutoId()
                        let key = tipRef.key
                        
                        var placeId = String()
                        if let id = placeID {
                            if id.isEmpty {
                                placeId = ""
                            }
                            else {
                                placeId = id
                            }
                        }
                        
                                self.storeInDB(key, pic, tipRef, uid, name, url, description, category, placeId) { (success) in
                                    
                                    if success {
                                        
                                        self.setTipLocation(coordinates.latitude, coordinates.longitude, key)
                                        
                                        if let tips = user.totalTips {
                                            
                                            var newTipCount = tips
                                            newTipCount += 1
                                            self.CURRENT_USER_REF.updateChildValues(["totalTips" : newTipCount], withCompletionBlock: { (error, ref) in
                                                
                                                if error == nil {
                                                    print("Tip succesfully stored in database...")
                                                    FIRAnalytics.logEvent(withName: "tipAdded", parameters: ["tipId" : key as NSObject, "category" : category as NSObject, "addedByUser" : name as NSObject])
                                                    completion(true)
                                                }
                                                
                                                
                                            })
                                            
                                        }
                                    }
                                    else {
                                        completion(false)
                                        
                                    }
                                    
                                }
                    }
                }
            }
            
        }
        
    }
    
    
    /** store tip in database */
    func storeInDB(_ key: String, _ tipPic: Data, _ tipRef: FIRDatabaseReference, _ userId: String, _ userName: String, _ userPicUrl: String, _ description: String, _ category: String, _ placeID: String, completion: @escaping ((_ success: Bool) -> Void)) {
        
        //Create Path for the tip Image
        let imagePath = "\(key)/tipImage.jpg"
        
        // Create image Reference
        let imageRef = self.STORAGE_TIP_IMAGE_REF.child(imagePath)
        
        // Create Metadata for the image
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let uploadTask = imageRef.put(tipPic as Data, metadata: metaData) { (metaData, error) in
            if error == nil {
                
                if let photoUrl = metaData?.downloadURL()?.absoluteString {
                    
                    let tip = Tip(category.lowercased(), description.censored(), 0, userName, userId, userPicUrl, photoUrl, true, placeID)
                    
                    tipRef.setValue(tip.toAnyObject(), withCompletionBlock: { (error, ref) in
                        
                        if error == nil {
                            
                            self.CATEGORY_REF.child(category.lowercased()).child(key).setValue(tip.toAnyObject(), withCompletionBlock: { (error, ref) in
                                
                                if error == nil {
                                    
                                    
                                    self.USER_TIP_REF.child(userId).child(key).setValue(tip.toAnyObject(), withCompletionBlock: { (error, ref) in
                                        
                                        if error == nil {
                                            print("Tip succesfully stored in database...")
                                        }
                                        else {
                                            print("Tip could not be stored in database...")
                                        }
                                        
                                        
                                    })
                                    
                                    
                                }
                            })
                        }
                        
                        
                    })
                    
                }
            }
            else {
                completion(false)
            }
            
        }
        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
            print(progress)
            
            let percentageComplete = 100.0 * Double(progress.completedUnitCount)
                / Double(progress.totalUnitCount)
            
            ProgressOverlay.updateProgress(receivedSize: progress.completedUnitCount, totalSize: progress.totalUnitCount, percentageComplete: percentageComplete)
            }
            
        }
        
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            completion(true)
        }
        
    }
    */
    
    // MARK: - Request Geo Functions
    
    
    /** Set user's location */
    func setUserLocation(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees) {
        
        self.getCurrentUser { (user) in
            guard let uid = user.key, let geoFire = GeoFire(firebaseRef: self.GEO_USER_REF) else {return}
            geoFire.setLocation(CLLocation(latitude: lat, longitude: lon), forKey: uid)
        }
       
    }
    
    /** Set tip location */
    func setTipLocation(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees, _ key: String) {
        let geoFire = GeoFire(firebaseRef: GEO_TIP_REF)
        geoFire?.setLocation(CLLocation(latitude: lat, longitude: lon), forKey: key)
    }
    
    /** Get tip location */
    func getTipLocation(_ key: String, completion: @escaping (CLLocation?, Error?) -> ()) {
        let geo = GeoFire(firebaseRef: self.GEO_TIP_REF)
        geo?.getLocationForKey(key, withCallback: { (location, error) in
            completion(location, error)
        })
    }
    
    
    /** Get user location */
    func getUserLocation(completion: @escaping (CLLocation?, Error?) -> ()) {
        
        self.getCurrentUser { (user) in
            guard let uid = user.key, let geoFire = GeoFire(firebaseRef: self.GEO_USER_REF) else  {return}
        
        geoFire.getLocationForKey(uid, withCallback: { (location, error) in
            completion(location, error)
        })
        }
    }
    
    
    /** Gets tips within given radius */
    func getNearbyTips(_ radius: Double, completion: @escaping (_ success: Bool, _ keys: [String], _ error: Error?) -> Void) {
        
     //   let geofence = GeofenceModel()
     //   geofence.keys = []
        var keys = [String]()
        
        
                    if let geoTipRef = GeoFire(firebaseRef: self.GEO_TIP_REF) {
                        
                    circleQuery = geoTipRef.query(at: Location.lastLocation.last, withRadius: radius) 
                            
                            circleQuery.observe(.keyEntered, with: { (key, location) in
                                
                                if let key = key {
                                    
                                  //  geofence.keys?.add(key)
                                  //  geofence.keys?.append(key)
                                    keys.append(key)
                                }
                            })
                            
                            circleQuery.observe(.keyExited, with: { (key, location) in

                            print("Key:  \(String(describing: key)) Location:  \(String(describing: location))")
                            
                            })
                            
                            circleQuery.observeReady({
                              //  geofence.keys = keys
                                completion(true, keys, nil)
                            })
                    
                }
            
    
    }
    
    /** Gets all tips regardless category */
    func getAllTips(_ keys: [String], completion: @escaping (Bool, [Tip]) -> Void) {
    
         var tipArray = [Tip]()
        
        TIP_REF.queryOrdered(byChild: "likes").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChildren() {
                print("Number of tips: \(snapshot.childrenCount)")
                for tip in snapshot.children.allObjects as! [DataSnapshot] {
                    
               //     guard let keys = geofence.keys else {return}
                    if (keys.contains(tip.key)) {
                            let tipObject = Tip(snapshot: tip)
                            tipArray.append(tipObject)
                    }
                    }
                if tipArray.count > 0 {
                    completion(true, tipArray)
                }
                else {
                    completion(false, tipArray)
                }
                }
            else {
                completion(false, tipArray)
            }
        })
    }
    
    
    /** Gets tips in requested category */
    func getCategoryTips(_ keys: [String], _ category: String, completion: @escaping (Bool, [Tip]) -> Void) {
    
        var tipArray = [Tip]()
        
        CATEGORY_REF.child(category).queryOrdered(byChild: "likes").observeSingleEvent(of: .value, with: { (snapshot) in
            
         //   guard let keys = geofence.keys else {return}
            if keys.count > 0 && snapshot.hasChildren() {
                print("Number of tips: \(snapshot.childrenCount)")
                for tip in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if (keys.contains(tip.key)) {
                        let tipObject = Tip(snapshot: tip)
                        tipArray.append(tipObject)
                    }
                    
                }
                if tipArray.count > 0 {
                    completion(true, tipArray)
                }
                else {
                    completion(false, tipArray)
                }
                
            }
            else {
                completion(false, tipArray)
            }
            
        })
    }
    
    
    // MARK: - Storage functions
    
    /** Upload profile pic */
    func uploadProfilePic(_ data: Data, completion: @escaping (Bool) -> ()) {
        
        if let userId = Auth.auth().currentUser?.uid {
            //Create Path for the User Image
            let imagePath = "\(userId)/userPic.jpg"
            
            // Create image Reference
            
            let imageRef = STORAGE_PROFILE_IMAGE_REF.child(imagePath)
            
            // Create Metadata for the image
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            // Save the user Image in the Firebase Storage File
            
            let uploadTask = imageRef.putData(data as Data, metadata: metaData) { (metaData, error) in
                
                if error == nil {
                    
                    if let photoUrl = metaData?.downloadURL()?.absoluteString {
                        self.CURRENT_USER_REF.updateChildValues(["photoUrl": photoUrl], withCompletionBlock: { (error, ref) in
                            
                            if error == nil {
                                
                                self.updateUsersTips(userId, photoUrl, completion: { (success) in
                                    
                                    if success {
                                    // Do nothing
                                    }
                                })
                            }
                            else {
                                completion(false)
                            }
                        })
                        
                    }
                    
                }
                
            }
            uploadTask.observe(.progress) { snapshot in
                if let progress = snapshot.progress {
                print(progress)
                }
            }
            
            uploadTask.observe(.success) { snapshot in
                completion(true)
            }
            
        }
    }
    
}
