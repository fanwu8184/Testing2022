//
//  BackgroundTasksService.swift
//  Testing2022
//
//  Created by Fan Wu on 4/13/22.
//

import Foundation
import UIKit
import BackgroundTasks
import SwiftUI

//https://itnext.io/swift-ios-13-backgroundtasks-framework-background-app-refresh-in-4-steps-3da32e65bc3d
//https://swiftuirecipes.com/blog/networking-with-background-tasks-in-ios-13
//https://uynguyen.github.io/2020/09/26/Best-practice-iOS-background-processing-Background-App-Refresh-Task/
//https://stackoverflow.com/questions/64844812/background-fetch-with-bgtaskscheduler-works-perfectly-with-debug-simulations-but
//https://medium.com/@cbartel/ios-scan-and-connect-to-a-ble-peripheral-in-the-background-731f960d520d
//e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.backgroundFetchIdentifier"]
//e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.backgroundProcessIdentifier"]
class BackgroundTasksService {
    static let shared = BackgroundTasksService()
    var bgTask: (() -> ())?
    private let bgFetchIdentifier = "com.example.backgroundFetchIdentifier"
    private let bgProcessIdentifier = "com.example.backgroundProcessIdentifier"
    
    func registerBackgroundTasks() {
        // Declared at the "Permitted background task scheduler identifiers" in info.plist
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: bgFetchIdentifier, using: nil) { (task) in
            print("bgFetchIdentifier is executed NOW!")
            
//            print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
//            task.expirationHandler = {
//                print("bgFetchIdentifier is terminated")
//                task.setTaskCompleted(success: false)n
//            }
//
//            // Do some data fetching and call setTaskCompleted(success:) asap!
//            self.bgTask?()
//            let isFetchingSuccess = true
//            task.setTaskCompleted(success: isFetchingSuccess)
            self.bgTask?()
            self.sendNotification()
            task.setTaskCompleted(success: true)
            self.submitBackgroundTasks()
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: bgProcessIdentifier, using: nil) { (task) in
            print("bgProcessIdentifier is executed NOW!")
            print("Time remaining: \(UIApplication.shared.backgroundTimeRemaining)")
            
            task.expirationHandler = {
                print("bgProcessIdentifier is terminated")
                task.setTaskCompleted(success: false)
            }
            
            // Do some time-consuming tasks
            self.bgTask?()
            task.setTaskCompleted(success: true)
        }
    }
    
    func submitBackgroundTasks() {
        let bgFetchTaskRequest = BGAppRefreshTaskRequest(identifier: bgFetchIdentifier)
        bgFetchTaskRequest.earliestBeginDate = Date().addingTimeInterval(60)
        do {
            try BGTaskScheduler.shared.submit(bgFetchTaskRequest)
            print("Submitted task request")
        } catch {
            print("Failed to submit BGTask")
        }
        
        
//        let request = BGProcessingTaskRequest(identifier: "com.example.backgroundProcessIdentifier")
//        request.requiresNetworkConnectivity = false
//        request.requiresExternalPower = false
//
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 10)
//        do {
//            try BGTaskScheduler.shared.submit(request)
//            print("Submitted process task request")
//        } catch {
//            print("Could not schedule process task: \(error)")
//        }
    }
    
    func checkBackgroundRefreshStatus() {
        switch UIApplication.shared.backgroundRefreshStatus {
        case .available:
            print("Background fetch is enabled")
        case .denied:
            print("Background fetch is explicitly disabled")
        case .restricted:
            print("Background fetch is restricted, e.g. under parental control")
        default:
            print("Unknown property")
        }
    }
    
    func registerNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications: Authorized.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    func sendNotification() {
        print("send Notification in 5 seconds")
        let content = UNMutableNotificationContent()
        content.title = "Feed the cat"
        content.subtitle = "It looks hungry"
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
}
