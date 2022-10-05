//
//  NotificationService.swift
//  Testing2022
//
//  Created by Fan Wu on 4/14/22.
//

import Foundation
import UIKit

class NotificationService {
    static let shared = NotificationService()
    
    func registerNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications: Authorized.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    func sendNotification(_ title: String, subtitle: String, inSecond: TimeInterval) {
        print("send Notification in \(inSecond) seconds")
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSecond, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
}
