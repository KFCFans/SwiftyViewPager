//
//  AppDelegate.swift
//  SwiftyViewPager
//
//  Created by lip on 16/12/4.
//  Copyright © 2016年 lip. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        let vc = TestViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        return true
    }



}

