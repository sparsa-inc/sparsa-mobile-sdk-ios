//
//  AppDelegate.swift
//  sdk-sample-app
//
//  Created by Grigor Petrosyan on 14.05.24.
//

import UIKit
import SwiftUI
import SparsaSDK
import FirebaseCore
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    @ObservedObject var viewModel: ContainerViewModel = .init()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        //FirebaseApp.configure()
        //Messaging.messaging().delegate = self
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
                }
            }
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            Sparsa.shared.updateDeviceToken(token: fcm)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        Sparsa.shared.handleNotification(userInfo) { [weak self] in
            self?.viewModel.clearState()
            self?.viewModel.updateButtonStates()
        } onError: { [weak self] error in
            self?.viewModel.showAlert(with: error.localizedDescription)
        }
        completionHandler([.sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Sparsa.shared.handleNotification(userInfo) { [weak self] in
            self?.viewModel.clearState()
            self?.viewModel.updateButtonStates()
        } onError: { [weak self] error in
            self?.viewModel.showAlert(with: error.localizedDescription)
        }
        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        return UIBackgroundFetchResult.newData
    }
}

