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
        
        if let id = FIRAuth.auth()?.currentUser?.uid {
            return USER_REF.child("\(id)")
        }
        else {
            if (UserDefaults.standard.object(forKey: "uid") != nil) {
                if let id = UserDefaults.standard.value(forKey: "uid") as? String {
                    return USER_REF.child("\(id)")
                }
            }
        }
        //   return USER_REF.child("\(id!)")
        
        /*
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
         */
        return FIRDatabaseReference()
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
    
    
    // MARK: - Account Related
    
    // ---- Signing in the User
    func signIn(_ email: String, _ password: String, completion: @escaping (Bool, FIRUser?) -> ()) {
        
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: password)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            
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
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
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
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
            
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
    
    private func setUserInfo(_ user: FIRUser!, _ name: String, _ password: String, _ data: NSData!, completion: @escaping (Bool) -> ()) {
        
        //Create Path for the User Image
        let imagePath = "\(user.uid)/userPic.jpg"
        
        
        // Create image Reference
        
        let imageRef = STORAGE_PROFILE_IMAGE_REF.child(imagePath)
        
        // Create Metadata for the image
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        // Save the user Image in the Firebase Storage File
        
        imageRef.put(data as Data, metadata: metaData) { (metaData, error) in
            
            if let err = error {
                print(err.localizedDescription)
            }
            else {
                let changeRequest = user.profileChangeRequest()
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
    
    private func saveInfo(_ user: FIRUser, _ name: String, _ password: String, completion: @escaping (Bool) -> ()) {
        
        // create user dictionary info
        if let email = user.email {
            if let url = user.photoURL {
                
                let userInfo = ["email": email, "name": name, "uid": user.uid, "photoUrl": url, "totalLikes": 0, "totalTips": 0, "isActive": true] as [String : Any]
                
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
    func getCurrentUser(_ completion: @escaping (User) -> Void) {
        CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            completion(User(snapshot: snapshot))
        })
    }
    
    /** Gets the User object for the specified user id */
    func getUser(_ userID: String, completion: @escaping (User) -> Void) {
        USER_REF.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(User(snapshot: snapshot))
        })
    }
    
    
    // MARK: - Request System Functions
    
    /** Update current user's tips */
    func updateUsersTips(_ userID: String, _ photoUrl: String, completion: @escaping (Bool) -> Void) {
    TIP_REF.queryOrdered(byChild: "addedByUser").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshot) in
        
        for tip in snapshot.children.allObjects as! [FIRDataSnapshot] {
        
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
    
    
    func handleLikeCount(_ tip: Tip, completion: @escaping (Bool, Bool, Error?) -> ()) {
        
        let tipListRef = CURRENT_USER_REF.child("tipsLiked")
        CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let key = tip.key {
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
            }
        
        })
    }
    
    
    private func incrementTip(_ tip: Tip, completion: @escaping (Bool, Error?) -> ()) {
        
        if let key = tip.key {
            TIP_REF.child(key).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                
                if var data = currentData.value as? [String : Any] {
                    var count = data["likes"] as! Int
                    
                    count += 1
                    data["likes"] = count
                    
                    currentData.value = data
                    
                    return FIRTransactionResult.success(withValue: currentData)
                }
                return FIRTransactionResult.success(withValue: currentData)
                
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
                    self.runTransactionOnUser(tip, completion: { (success) in
                        
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
        
    }
    
    
    private func runTransactionOnUser(_ tip: Tip, completion: @escaping (Bool) -> Void) {
        
        if let userId = tip.addedByUser {
            self.USER_REF.child(userId).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                
                if var data = currentData.value as? [String : Any] {
                    var count = data["totalLikes"] as! Int
                    
                    count += 1
                    data["totalLikes"] = count
                    
                    currentData.value = data
                    
                    return FIRTransactionResult.success(withValue: currentData)
                }
                return FIRTransactionResult.success(withValue: currentData)
                
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
    
    
    // MARK: - Request Geo Functions
    
    
    /** Set user's location */
    func setUserLocation(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees, _ key: String) {
        let geoFire = GeoFire(firebaseRef: GEO_USER_REF)
        geoFire?.setLocation(CLLocation(latitude: lat, longitude: lon), forKey: key)
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
    
    
    /** Gets tips within given radius */
    func getNearbyTips(_ radius: Double, completion: @escaping (Bool, [String], Error?) -> Void) {
        
    if let geoRef = GeoFire(firebaseRef: self.GEO_USER_REF) {
    
         var keys = [String]()
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
        geoRef.getLocationForKey(uid, withCallback: { (location, error) in
            
            if let err = error {
            completion(false, keys, err)
            }
            else {
                if let geoTipRef = GeoFire(firebaseRef: self.GEO_TIP_REF) {
                    if let circleQuery = geoTipRef.query(at: location, withRadius: radius) {
                        
                        circleQuery.observe(.keyEntered, with: { (key, location) in
                            
                            if let key = key {
                            keys.append(key)
                            }
                        })
                        
                        circleQuery.observeReady({
                            completion(true, keys, nil)
                        })
                }
                }
            }
            
        })
        
        }
    }
    }
    
    /** Gets all tips regardless category */
    func getAllTips(_ keys: [String], completion: @escaping (Bool, [Tip]) -> Void) {
    
         var tipArray = [Tip]()
        
        TIP_REF.queryOrdered(byChild: "likes").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChildren() {
                print("Number of tips: \(snapshot.childrenCount)")
                for tip in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
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
            
            if keys.count > 0 && snapshot.hasChildren() {
                print("Number of tips: \(snapshot.childrenCount)")
                for tip in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
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
        
        if let userId = FIRAuth.auth()?.currentUser?.uid {
            //Create Path for the User Image
            let imagePath = "\(userId)/userPic.jpg"
            
            // Create image Reference
            
            let imageRef = STORAGE_PROFILE_IMAGE_REF.child(imagePath)
            
            // Create Metadata for the image
            
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            // Save the user Image in the Firebase Storage File
            
            let uploadTask = imageRef.put(data as Data, metadata: metaData) { (metaData, error) in
                
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
