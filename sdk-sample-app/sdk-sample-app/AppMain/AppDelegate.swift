//
//  AppDelegate.swift
//  sdk-sample-app
//
//  Created by Grigor Petrosyan on 14.05.24.
//

import UIKit
import Sparsa
import FirebaseCore
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
        
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { (
                granted,
                error
            ) in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("Permission for push notifications denied.")
                }
            }
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print(
            "Failed to register for remote notifications with error: \(error)"
        )
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            Sparsa.updateDeviceToken(fcm)
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        Sparsa.handleNotification(notification.request.content.userInfo)
        completionHandler([.sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Sparsa.handleNotification(userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        return UIBackgroundFetchResult.newData
    }
}

