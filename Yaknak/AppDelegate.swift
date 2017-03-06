//
//  AppDelegate.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKCoreKit
import PXGoogleDirections
import GoogleMaps


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var splashVC = SplashScreenViewController()
     var directionsAPI: PXGoogleDirections!
    
    
    override init() {
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        directionsAPI = PXGoogleDirections(apiKey: Constants.Config.GoogleAPIKey)
        
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
     //   FIRApp.configure()
     //   FIRDatabase.database().persistenceEnabled = true
     //   GMSServices.provideAPIKey(Constants.Config.GoogleAPIKey)
        application.statusBarStyle = .default
        GMSServices.provideAPIKey(Constants.Config.GoogleAPIKey)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = splashVC
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
  

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func authenticateUser() {
    
        FIRAuth.auth()?.addStateDidChangeListener {
            auth, user in
            
            if user != nil {
                
                // Email verification
                if (user?.isEmailVerified)! {
                    // User is signed in.
                    self.redirectUser()
                }
                else {
                    
                    if let providerData = FIRAuth.auth()?.currentUser?.providerData {
                        for item in providerData {
                            if (item.providerID == "facebook.com") {
                                 self.redirectUser()
                                break
                            }
                            else {
                            self.notSignedInRedirection()
                            }
                        }
                    }
                    else {
                        self.notSignedInRedirection()
                    }

                    
                  /*
                    if (user?.providerData[0].providerID == "facebook.com") {
                    self.signedInRedirection(user: user!)
                    }
                    else {
                    self.notSignedInRedirection()
                    }
                    */
                }
 
            } else {
                self.notSignedInRedirection()
            }
        }
    
    }
    
    
    func notSignedInRedirection() {
        print("User is not signed in...")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.window!.rootViewController = initialViewController
    }
    
    
    func redirectUser() {
        
            let tabController = UIStoryboard.instantiateViewController("Main", identifier: "TabBarController") as! TabBarController
            self.window!.rootViewController = tabController
            print("User has signed in successfully...")
        tabController.preloadViews()
        
    }
    
    func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController()
        alertController.defaultAlert(title: title, message: message)
    }
    
    func dismissViewController() {
        
        guard let rvc = self.window?.rootViewController else {
            return
        }
        
        rvc.topMostViewController().dismiss(animated: true, completion: nil)
 
    }
    
}

