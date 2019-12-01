//
//  AppDelegate.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 22.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        
        let controller = RootAssembly().presentationAssembly.loginViewController()
        window?.rootViewController = controller
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    

}

