//
//  AppDelegate.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        initRootViewController()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        requestIDFA()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
}
