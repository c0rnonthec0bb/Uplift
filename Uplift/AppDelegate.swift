//
//  AppDelegate.swift
//  Uplift
//
//  Created by Adam Cobb on 11/1/15.
//  Copyright © 2015 Adam Cobb. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.enableLocalDatastore()
        let configuration = ParseClientConfiguration {
            $0.isLocalDatastoreEnabled = true
            $0.applicationId = "EbwlSLtJ8MJx5moWg2bOtYhIxVj9MDvn9jCwPGlr"
            $0.clientKey = nil
            //$0.server = "http://uplifteverything.herokuapp.com/parse/"
            $0.server = "http://parseserver-id2t2-env.us-east-1.elasticbeanstalk.com/parse/"
        }
        Parse.initialize(with: configuration)
        PFUser.enableRevocableSessionInBackground()
        
        UNUserNotificationCenter.current().getNotificationSettings(){settings in
            if settings.authorizationStatus == .notDetermined{
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                { (granted, error) in
                    if granted == true{
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        
        if let _ = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            ViewController.context.currentMode = 2;
            ViewController.context.currentSubmode[2] = 0;
            ViewController.context.animate_all();
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ViewController.context.currentMode = 2;
        ViewController.context.currentSubmode[2] = 0;
        ViewController.context.animate_all();
        Refresh.refreshPage(2, 0);
        
        for instance in WindowBase.instances{
            if instance.shown{
                instance.hideFrame(send: false)
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        ViewController.context.onPause()
        ViewController.context.onStop()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        ViewController.context.onStart()
        ViewController.context.onResume()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        OperationQueue.main.cancelAllOperations()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Files.writeData("deviceToken", deviceToken)
        if let installation = PFInstallation.current(){
            installation.setDeviceTokenFrom(deviceToken)
            installation.saveInBackground()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Toast.makeText(ViewController.context, "Uplift failed to register for push notifications due to an unknown error.", Toast.LENGTH_LONG)
    }
}

