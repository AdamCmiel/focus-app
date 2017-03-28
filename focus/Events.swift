//
//  Events.swift
//  focus
//
//  Created by Adam Cmiel on 3/27/17.
//  Copyright © 2017 Adam Cmiel. All rights reserved.
//

import CoreFoundation

struct Events {
    
    fileprivate let presenter = NotificationPresenter()
    
    fileprivate var queue: [Notification] = []
    
    fileprivate let darwinEventCallBack: CFNotificationCallback = { (_, observer: UnsafeMutableRawPointer?, name: CFNotificationName?, _, _) in
        if let observer = observer,
            let presenter = Optional(Unmanaged<NotificationPresenter>.fromOpaque(observer).takeUnretainedValue()),
            let name = name?.rawValue as String?,
            let notification = Notification(rawValue: name)
        {
            presenter.enqueue(notification)
        }
    }
    
    init() {
        presenter.delegate = self
        Notification.allCases.forEach { self.registerDarwinEventObserver($0 as CFString, callback: self.darwinEventCallBack) }
    }
    
    fileprivate func registerDarwinEventObserver(_ event: CFString, callback: @escaping CFNotificationCallback) {
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            presenter.cPointer,
            callback,
            event as CFString,
            nil,
            .deliverImmediately
        )
    }
    
    fileprivate mutating func flush() {
        queue = []
    }
    
}

extension Events : NotificationPresenterDelegate {
    
    mutating func notificationPresenter(_ presenter: NotificationPresenter, didRecieveNotification notification: Notification) {
        queue.append(notification)
    }
    
    mutating func notificationPresenterShouldPresentLocalNotification() -> Bool {
        guard queue.count > 2 else { return false }
        
        let lastIndex = queue.count - 1
        let lastTwo = [queue[lastIndex], queue[lastIndex - 1]]
        
        if lastTwo == Notification.screenOpened {
            flush()
            return true
        }
        
        return false
    }
    
}
