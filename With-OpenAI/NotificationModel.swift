//
//  NotificationModel.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//
import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Permission granted")
        } else if let error = error {
            print("Error requesting permission: \(error.localizedDescription)")
        }
    }
}

func triggerNotification(title: String, body: String, delay: TimeInterval) {
    let center = UNUserNotificationCenter.current()
    
    // Content of the notification
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    // Trigger time for the notification
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
    
    // Create the request
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    // Add the request to the notification center
    center.add(request) { error in
        if let error = error {
            print("Failed to add notification: \(error.localizedDescription)")
        }
    }
}
