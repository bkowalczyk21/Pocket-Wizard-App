//
//  AppDelegate.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/12/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//

import UIKit
import Amplify
import AmplifyPlugins
import UserNotifications
import AWSPinpoint
 

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FirmwareRetrievalDelegate {
    
    func didRetrieveNewFirmwareUpdate(firmwareUpdate: FirmwareUpdate, unupdatedPocketWizards: [String]) {
        DispatchQueue.main.async {
        var unupdatedString = ""
        unupdatedPocketWizards.forEach { (pocketWizard) in
            unupdatedString.append(pocketWizard)
            if pocketWizard != unupdatedPocketWizards.last {
                unupdatedString.append(", ")
            }
        }
        let alert = UIAlertController(title: "Firmware Update Available",
                                      message: "Firmware update " + firmwareUpdate.version + " is available for " + unupdatedString + ".",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        
            UIApplication.shared.keyWindow?.rootViewController?.present(
                alert, animated: true, completion: nil
            )
        }
    }
    
    func failedToRetrieveNewFirmware(userMessage: String) {
        let alert = UIAlertController(title: "New Firmware Check Failed",
                                      message: userMessage.description,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(
            alert, animated: true, completion: nil
        )
    }
    

    var window: UIWindow?
    var pinpoint: AWSPinpoint?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //AWSDDLog.sharedInstance.logLevel = .verbose
        //AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        /*
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSPinpointAnalyticsPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured with storage plugin")
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }
        
        let pinpointConfiguration = AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions)
        pinpointConfiguration.debug = false
        pinpoint = AWSPinpoint(configuration: pinpointConfiguration)
        registerForPushNotifications()
        */
        FirmwareManager.instance.checkForNewFirmware(delegate: self)
        return true
    }
    
    // MARK: Remote Notifications Lifecycle
    func application(_: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")

        // Register the device token with Pinpoint as the endpoint for this user
        pinpoint!.notificationManager
            .interceptDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(_: UIApplication,
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication,
                    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                        -> Void) {
        // if the app is in the foreground, create an alert modal with the contents
        if application.applicationState == .active {
            let alert = UIAlertController(title: "Notification Received",
                                          message: userInfo.description,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            UIApplication.shared.keyWindow?.rootViewController?.present(
                alert, animated: true, completion: nil
            )
        }

        // Pass this remote notification event to pinpoint SDK to keep track of notifications produced by AWS Pinpoint campaigns.
        pinpoint!.notificationManager.interceptDidReceiveRemoteNotification(
            userInfo, fetchCompletionHandler: completionHandler
        )
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
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }

            // Only get the notification settings if user has granted permissions
            self?.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }

            DispatchQueue.main.async {
                // Register with Apple Push Notification service
                UIApplication.shared.registerForRemoteNotifications()
                print("registered for push notifications")
            }
        }
    }
}

