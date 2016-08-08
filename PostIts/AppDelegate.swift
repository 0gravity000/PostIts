//
//  AppDelegate.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/07/27.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit
import StoreKit

//postItsの色定義
enum postItBackgroundColor: Int {
    case yellow = 1
    case blue = 2
    case green = 3
    case orange = 4
    case pink = 5
    case purple = 6
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PostItsPurchaseManagerDelegate {

    var window: UIWindow?

    var selectedPostItColor = postItBackgroundColor.yellow
    var selectedBackgroundImg = 0
    var viewPosX: Float? = nil
    var viewPosY: Float? = nil
    var isPurchasedLimitationReleaseKey: Bool = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //アプリ内課金処理 この場所でいい???他の場所も必要???
        // デリゲート設定
        PostItsPurchaseManager.sharedManager().delegate = self
        // オブザーバー登録
        SKPaymentQueue.defaultQueue().addTransactionObserver(PostItsPurchaseManager.sharedManager())

        //NSUserdefaultsからデータを取得
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        //選択中のBackgroundImg
        let storedBackgroundImg: Int = defaults.integerForKey("selectedBackgroundImg")
        selectedBackgroundImg = storedBackgroundImg

        //選択中のPostItColor
        let storedPostItColor: Int = defaults.integerForKey("selectedPostItColor")
        if (storedPostItColor == postItBackgroundColor.yellow.rawValue) {
            selectedPostItColor = postItBackgroundColor.yellow
        } else if (storedPostItColor == postItBackgroundColor.blue.rawValue) {
            selectedPostItColor = postItBackgroundColor.blue
        } else if (storedPostItColor == postItBackgroundColor.green.rawValue) {
            selectedPostItColor = postItBackgroundColor.green
        } else if (storedPostItColor == postItBackgroundColor.orange.rawValue) {
            selectedPostItColor = postItBackgroundColor.orange
        } else if (storedPostItColor == postItBackgroundColor.pink.rawValue) {
            selectedPostItColor = postItBackgroundColor.pink
        } else if (storedPostItColor == postItBackgroundColor.purple.rawValue) {
            selectedPostItColor = postItBackgroundColor.purple
        }
        
        //制限解除キーの購入状態
        let storedLimitationReleaseKeyState: Bool = defaults.boolForKey("isPurchasedLimitationReleaseKey")
        isPurchasedLimitationReleaseKey = storedLimitationReleaseKeyState
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }


}

