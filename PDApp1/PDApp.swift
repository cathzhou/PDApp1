//
//  PDApp.swift
//  PDApp1
//
//  Created by Catherine Zhou on 3/22/25.
//


import SwiftUI

@main
struct PDApp1App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("App launched")
        // Perform setup tasks here
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App entered background")
        // Perform background tasks here
    }
}
