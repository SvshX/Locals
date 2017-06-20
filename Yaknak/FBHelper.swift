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
    
    
    public func load(viewController: UIViewController? = nil, onError: @escaping ()->(), onSuccess: @escaping (FacebookUser)->()) {
        
        cancel()
        logOut()
        logInAndLoadUserProfile(viewController: viewController, onError: onError, onSuccess: onSuccess)
    }
    
    
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
    
    
    /// Loads user profile information from Facebook.
    private func loadFacebookInfo(_ onError: @escaping ()->(), _ onSuccess: @escaping (FacebookUser) -> ()) {
        if FBSDKAccessToken.current() == nil {
            onError()
            return
        }
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        
        currentConnection = graphRequest?.start { [weak self] connection, result, error in
            if error != nil {
                onError()
                return
            }
            
            if let userData = result as? NSDictionary, let accessToken = self?.accessToken, let user = FBHelper.parseData(data: userData as! [String : Any], accessToken: accessToken) {
                
                onSuccess(user)
            } else {
                onError()
            }
        }
    }
    
    
    /// Parses user profile dictionary returned by Facebook SDK.
    class func parseData(data: [String : Any], accessToken: String) -> FacebookUser? {
        if let id = data["id"] as? String {
            return FacebookUser(
                id: id,
                accessToken: accessToken,
                email: data["email"] as? String,
                firstName: data["first_name"] as? String,
                lastName: data["last_name"] as? String,
                name: data["name"] as? String)
        }
        
        return nil
    }

}
