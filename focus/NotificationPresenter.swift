//
//  NotificationPresenter.swift
//  focus
//
//  Created by Adam Cmiel on 3/27/17.
//  Copyright © 2017 Adam Cmiel. All rights reserved.
//

import Foundation
import UserNotifications

protocol NotificationPresenterDelegate {
    mutating func notificationPresenterShouldPresentLocalNotification() -> Bool
    mutating func notificationPresenter(_ presenter: NotificationPresenter, didRecieveNotification notification: Notification)
}

final class NotificationPresenter: NSObject {
    
    let identifier = "com.ad.mc.app.focus.phone.down"
    
    var delegate: NotificationPresenterDelegate!
    
    var cPointer: UnsafeRawPointer {
        get { return UnsafeRawPointer(Unmanaged<NotificationPresenter>.passUnretained(self).toOpaque()) }
    }
    
    fileprivate var center: UNUserNotificationCenter!
    
    override init() {
        center = UNUserNotificationCenter.current()
        super.init()
        center.delegate = self
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            if !granted {
                print("not given notification permissions")
            }
        }
    }
    
    func enqueue(_ notification: Notification) {
        delegate.notificationPresenter(self, didRecieveNotification: notification)
        if (delegate.notificationPresenterShouldPresentLocalNotification()) {
            self.present()
        }
    }
    
    fileprivate func present() {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "Put down your phone"
            content.body = "Remember to focus"
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: self.identifier + String(describing: NSDate()), content: content, trigger: trigger)
            self.center.add(request, withCompletionHandler: nil)
        }
    }
}

extension NotificationPresenter : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // do nothing
        completionHandler()
    }
    
}
