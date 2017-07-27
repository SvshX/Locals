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
import GooglePlaces
import GoogleMaps


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    enum Root: String {
        case Login
        case TabBar
        case Unknown
    }
    
    var window: UIWindow?
    var splashVC = SplashScreenViewController()
    var reachability = Reachability()!
    var isReachable = false
    var firstLaunch: ToolTipManager!
    let fbHelper = FBHelper()

    
    override init() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
                self.isReachable = true
                NoNetworkOverlay.hide()
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            self.isReachable = false
            DispatchQueue.main.async {
                print("Not reachable")
                NoNetworkOverlay.show("Nooo connection :(")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
  
    
    
     //   FIRApp.configure()
     //   FIRDatabase.database().persistenceEnabled = true
     //   GMSServices.provideAPIKey(Constants.Config.GoogleAPIKey)
        application.statusBarStyle = .default
        GMSServices.provideAPIKey(Constants.Config.GoogleAPIKey)
        GMSPlacesClient.provideAPIKey(Constants.Config.GoogleAPIKey)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: Constants.NibNames.MainStoryboard, bundle: nil)
        
        if let _ = Auth.auth().currentUser {
            let tabController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        self.window?.rootViewController = tabController
        }
        else {
            let loginController = storyboard.instantiateViewController(withIdentifier: "FBLoginViewController") as! FBLoginViewController
        self.window?.rootViewController = loginController
        }
        
        self.window?.makeKeyAndVisible()

        self.authenticateUser { (root) in
            
            switch (root) {
            case .Login:
                print("User is not signed in...")
                self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "FBLoginViewController") as! FBLoginViewController
                break
                
            case .TabBar:
                if self.window?.rootViewController is FBLoginViewController {
                    let tabC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                self.window?.rootViewController = tabC
                }
                
                print("User has logged in successfully...")
                break
                
            case .Unknown:
                break
                
            }
        }
        
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
        // Call the 'activate' method to log an app event for use
        // in analytics and advertising reporting.
        // Call the 'activate' method to log an app event for use
        // in analytics and advertising reporting.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func authenticateUser(completion: @escaping ((_ root: Root) -> ())) {
    
        Auth.auth().addStateDidChangeListener {
            auth, user in
            
            if let user = user {
                
                // Email verification
                if user.isEmailVerified {
                    // User is signed in.
                    completion(Root.TabBar)
                   // self.launchDashboard()
                }
                else {
                    
                    if let providerData = Auth.auth().currentUser?.providerData {
                        for item in providerData {
                            if (item.providerID == "facebook.com") {
                                
                                self.fbHelper.loadFacebookInfo(user, {
                                    
                                     print("Something went wrong...")
                                    
                                }, { (facebookUser) in
                                    
                                    if let fbUser = facebookUser {
                                    print("Facebook user: " + fbUser.email!)
                                        
                                        guard let url = fbUser.picUrl else {return}
                                        self.fbHelper.storeNewFacebookUser(url, user, fbUser, completion: { (success) in
                                            
                                            if success {
                                                completion(.TabBar)
                                            }
                                            else {
                                            print("Something went wrong...")
                                            }
                                        })
                                       
                                    }
                                    else {
                                        
                                        self.fbHelper.updateFBStatus(user, completion: {
                                            completion(.TabBar)
                                        })
                                   
                                    }
                                })
                                break
                            }
                            else {
                                completion(.Login)
                            }
                        }
                    }
                    else {
                        completion(.Login)
                    }

                }
 
            } else {
                completion(.Login)
            }
        }
    
    }
    
    
 
    func launchDashboard() {
        
            let tabController = UIStoryboard.instantiateViewController(Constants.NibNames.MainStoryboard, identifier: "TabBarController") as! TabBarController
        
        self.window!.rootViewController = tabController
       // tabController.selectedIndex = 2
        print("User has logged in successfully...")
        
        
        #if DEBUG
        self.firstLaunch = ToolTipManager.alwaysFirst()
        #else
        self.firstLaunch = ToolTipManager(userDefaults: .standard, key: "firstLaunch")
        #endif
        
    }
    
    
    
    func dismissViewController() {
        
        guard let rvc = self.window?.rootViewController else {
            return
        }
        
        rvc.topMostViewController().dismiss(animated: true, completion: nil)
 
    }

}

