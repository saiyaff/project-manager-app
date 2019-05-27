//
//  NotificationService.swift
//  project-manager-app
//
//  Created by Saiyaff Farouk on 5/27/19.
//  Copyright © 2019 Saiyaff Farouk. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationService {
    static func showNotification(projectName: String, taskName: String){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        content.title = "Project Manager"
        content.subtitle = projectName
        content.body = taskName
        content.sound = UNNotificationSound.default
        content.threadIdentifier = "local-notification temp"
        
        let date = Date(timeIntervalSinceNow: 10)
        let dateComponet = Calendar.current.dateComponents([.year,.month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponet, repeats: false)
        
        let request = UNNotificationRequest(identifier: "content", content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil {
                print(error!)
            }
        }
    }
}
