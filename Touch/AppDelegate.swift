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
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let menuViewController = window?.rootViewController as! MenuViewController

        menuViewController.game = Game()

        menuViewController.remoteGameService = RemoteGameService()

        return true
    }
}

