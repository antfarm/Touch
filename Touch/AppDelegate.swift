//
//  AppDelegate.swift
//  Touch
//
//  Created by sean on 07/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let menuVC = window?.rootViewController as! MenuViewController

        let connectivityManager = ConnectivityManager()
        connectivityManager.delegate = menuVC
        
        menuVC.connectivityManager = connectivityManager


        return true
    }
}

