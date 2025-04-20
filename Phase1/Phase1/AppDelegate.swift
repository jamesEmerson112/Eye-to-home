//
//  AppDelegate.swift
//  Phase1
//
//  Created by James Emerson Vo on 4/19/25.
//

import UIKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    /*------------------------------------------------------------
     * application(_:didFinishLaunchingWithOptions:)
     * Called when the app has finished launching.
     *
     * Parameters
     * ----------
     *   application – The singleton app object.
     *   launchOptions – A dictionary indicating the reason the app was launched (may be nil).
     *
     * Returns
     * -------
     *   Bool – true if the app launched successfully, false otherwise.
     *----------------------------------------------------------*/
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
        return true
    }

    /*------------------------------------------------------------
     * applicationWillResignActive(_:)
     * Called when the app is about to move from active to inactive state.
     *
     * Parameters
     * ----------
     *   application – The singleton app object.
     *
     * Returns
     * -------
     *   Void
     *----------------------------------------------------------*/
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    /*------------------------------------------------------------
     * applicationDidEnterBackground(_:)
     * Called when the app enters the background.
     *
     * Parameters
     * ----------
     *   application – The singleton app object.
     *
     * Returns
     * -------
     *   Void
     *----------------------------------------------------------*/
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    /*------------------------------------------------------------
     * applicationWillEnterForeground(_:)
     * Called as part of the transition from background to active state.
     *
     * Parameters
     * ----------
     *   application – The singleton app object.
     *
     * Returns
     * -------
     *   Void
     *----------------------------------------------------------*/
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    /*------------------------------------------------------------
     * applicationDidBecomeActive(_:)
     * Called when the app becomes active.
     *
     * Parameters
     * ----------
     *   application – The singleton app object.
     *
     * Returns
     * -------
     *   Void
     *----------------------------------------------------------*/
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}
