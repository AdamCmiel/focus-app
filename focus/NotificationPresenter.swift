import Foundation
import UserNotifications

/// Delegate determines conditions for triggering user notifications
protocol NotificationPresenterDelegate {
    
    /// Determine if presenter should fire a local notification
    mutating func shouldPresentLocalNotification() -> Bool
    
    /// Determine if presenter should clear all scheduled notifications
    mutating func shouldClearLocalNotifications() -> Bool
    
    /// Recieve notification from CF Notifications and manage state
    mutating func notificationPresenter(_ presenter: NotificationPresenter, didRecieveNotification notification: Notification)
    
}

/// We need a reference type here that conforms to AnyObject
/// to make a C - pointer to the presenter to hand off to CF Notifications
/// All actual event parsing will happen in the delegate
final class NotificationPresenter: NSObject {
    
    let identifier = "com.ad.mc.app.focus.phone.down"
    
    let delay = 20
    
    var delegate: NotificationPresenterDelegate!
    
    var cPointer: UnsafeRawPointer {
        get { return UnsafeRawPointer(Unmanaged<NotificationPresenter>.passUnretained(self).toOpaque()) }
    }
    
    fileprivate var center: UNUserNotificationCenter!
    
    override init() {
        super.init()
        center = UNUserNotificationCenter.current()
    
        center.delegate = self
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            if !granted {
                print("not given notification permissions")
            }
        }
    }
    
}

// MARK: Internal Methods
extension NotificationPresenter {

    func enqueue(_ notification: Notification) {
        delegate.notificationPresenter(self, didRecieveNotification: notification)
        if (delegate.shouldPresentLocalNotification()) {
            self.present()
            print("presenting")
            return
        }
        
        // TODO: find lock pattern
//        if (delegate.shouldClearLocalNotifications()) {
//            center.removeAllPendingNotificationRequests()
//            print("cancelling")
//        }
    }
    
}

// MARK: Private methods
fileprivate extension NotificationPresenter {
    
    fileprivate func present() {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            self.request(delay: 1.0)
            self.request(delay: 30.0)
        }
    }
    
    fileprivate func request(delay: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Put down your phone"
        content.body = "Remember to focus"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: self.identifier, content: content, trigger: trigger)
        self.center.add(request, withCompletionHandler: nil)
    }
    
}

// MARK: UNUserNotificationCenterDelegate
extension NotificationPresenter : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // do nothing
        completionHandler()
    }
    
}
