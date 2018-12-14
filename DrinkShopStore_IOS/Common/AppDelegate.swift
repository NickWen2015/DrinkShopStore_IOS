//
//  AppDelegate.swift
//  DrinkShopStore_IOS
//
//  Created by Nick Wen on 2018/10/7.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit
import UserNotifications

extension Notification.Name {
    static let didReceiveNotification = Notification.Name("didReceiveNotification")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationBarAppearace.barTintColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        
        //Ask user's authorization.取得user同意
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (grant, error) in
            if let error = error {
                print("Fail to requestAuthorization: \(error)")
                return
            }
            print("User grant the permission.")
        }
        //Register for remote notification. 發出要求註冊遠端通知, APNS會給一個device token
        application.registerForRemoteNotifications()
        
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


    //MARK: - APNS Support.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {//註冊成功拿到device token
        print("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceToken.description)")
        
        //        let tokenString = deviceToken.map { (byte) -> String in
        //            return String(format: "%02x", byte) //x表16進位,2位數,不足位補0
        //        }.joined()//joined() >> string array to string
        
        let tokenString = deviceToken.map { String(format: "%02x", $0) //closure 簡化寫法
            }.joined()//joined() >> string array to string
        print("tokenString: \(tokenString)")
        
        let member_name = "drinkShop客服人員"
//        if let name = UserDefaults.standard.value(forKey: "member_name") as? String {
//            member_name = name
//        }
        
        ChatCommunicator.shared.update(deviceToken: tokenString, userName: member_name) {
            (result, error) in
            if let error = error {
                print("update deviceToken fail: \(error)")
                return
            } else if let result = result {
                print("update deviceToken OK: \(result)")
            }
            
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {//註冊失敗拿不到device token,可能為網路因素
        print("didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }
    //1.當收到新訊息,且app正在前景運作
    //2.使用者按下通知中心其中一個訊息
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification APNS Payload酬載: \(userInfo)")
        
        let state = application.applicationState
        
        //active(在前景),inactive(電話進來),background(在背景)
        if state == .active {
            NotificationCenter.default.post(name: .didReceiveNotification, object: nil)
            
        } else if state == .background {
            // ...
            completionHandler(.newData)
        }
        
    }
}
