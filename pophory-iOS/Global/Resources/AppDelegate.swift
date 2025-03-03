//
//  AppDelegate.swift
//  ZKFace
//
//  Created by Danna Lee on 2023/05/19.
//
import AuthenticationServices
import UIKit

import Firebase
import Sentry
import GoogleMobileAds
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        setSentry()
        requestTrackingAuthorization()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}

extension AppDelegate {
    
    private func requestTrackingAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { (status) in
                    switch status {
                    case .notDetermined:
                        print("notDetermined") // 결정되지 않음
                    case .restricted:
                        print("restricted") // 제한됨
                    case .denied:
                        print("denied") // 거부됨
                    case .authorized:
                        print("authorized") // 허용됨
                    @unknown default:
                        print("error") // 알려지지 않음
                    }
                }
            }
        }
//        if #available(iOS 14, *) {
//            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
//                ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
//                    // Initialize the Google Mobile Ads SDK.
//                    #if RELEASE
//                    GADMobileAds.sharedInstance().start(completionHandler: nil)
//                    #else
//                    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
//                    [ "89ad6e2f5e35327a7987a9a5dc2a1149" ]      // testID
//                    #endif
//                })
//            }
//        }
    }
    
    
    private func setSentry() {
        SentrySDK.start { options in
            options.dsn = Bundle.sentryDNS
            options.debug = true
            options.tracesSampleRate = 1.0
        }
    }
}
