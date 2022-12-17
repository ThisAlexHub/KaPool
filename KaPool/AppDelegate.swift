//
//  AppDelegate.swift
//  KaPool
//
//  Created by Madel Asistio on 3/2/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /* GOOGLE MAPS & GOOGLE PLACES */
        
        GMSServices.provideAPIKey("AIzaSyBJWjJ6M8cIbUKqgs6XsnIoIVRn1Fi7h44")
        GMSPlacesClient.provideAPIKey("AIzaSyC9rD0E5jSLioCIaqA2kFp4-RiWEtmubXk")
        
        /* PARSE */
        Parse.enableLocalDatastore()
        
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = "db9eeca8a04922973124b1e91ea8afb3a0e833a8"
            ParseMutableClientConfiguration.clientKey = "e6557cd377048085e511463d9a786751f7b11897"
            ParseMutableClientConfiguration.server = "http://ec2-54-213-1-146.us-west-2.compute.amazonaws.com:80/parse"
        })
        
        Parse.initialize(with: parseConfiguration)
        
        
        //PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.getPublicReadAccess = true
        
        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
        
        //login()
        
        // color of window
        window?.backgroundColor = .white
        
        //clear user default when app starts
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        
        
        
        
        return true
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

    func login(){
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        if PFUser.current() != nil {
            //let offerRide = storyboard.instantiateViewController(withIdentifier: "offerRide") as! UITabBarController
            //window?.rootViewController = offerRide
            let vc = storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
            
            //vc.tweet = tweetsArray[0]
            
            
            window?.rootViewController = vc
     
        } else {

            let vc = storyboard.instantiateViewController(withIdentifier: "loginPage") as! SigninViewController
        
            window?.rootViewController = vc
            

        }
    }


}

