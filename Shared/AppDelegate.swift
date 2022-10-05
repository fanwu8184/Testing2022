//
//  AppDelegate.swift
//  Testing2022
//
//  Created by Fan Wu on 4/12/22.
//

import Foundation
import UIKit
import BackgroundTasks

//https://medium.com/snowdog-labs/managing-background-tasks-with-new-task-scheduler-in-ios-13-aaabdac0d95b
//https://www.spaceotechnologies.com/blog/ios-background-task-framework-app-update/
//https://stackoverflow.com/questions/71271459/bgapprefreshtask-not-executing-swiftui

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("didFinishLaunchingWithOptions: \(launchOptions?[UIApplication.LaunchOptionsKey.bluetoothCentrals] ?? "nil")")
        NotificationService.shared.registerNotifications()
        return true
    }
}
