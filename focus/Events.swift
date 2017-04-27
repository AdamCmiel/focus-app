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
    
}

// MARK: Private Methods
fileprivate extension Events {
    
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
        if queue.count > 3 {
            queue = queue.lastNItems(n: 3)
        }
    }
    
}

extension Events : NotificationPresenterDelegate {
    
    mutating func notificationPresenter(_ presenter: NotificationPresenter, didRecieveNotification notification: Notification) {
        queue.append(notification)
        print(queue)
    }
    
    mutating func shouldPresentLocalNotification() -> Bool {
        guard last(n: 2, itemsMatchPattern: Notification.screenOpened) else { return false }
        
        flush()
        return true
    }
    
    mutating func shouldClearLocalNotifications() -> Bool {
        guard last(n: 3, itemsMatchPattern: Notification.screenLocked) else { return false }
        
        flush()
        return true
    }
    
    private func last(n: Int, itemsMatchPattern pattern: [Notification]) -> Bool {
        return queue.count > n && queue.lastNItems(n: n) == pattern
    }

}

fileprivate extension Array {
    
    func lastNItems(n: Int) -> [Element] {
        let firstIndex = self.endIndex - n
        return Array(self[(firstIndex ..< self.endIndex) as Range<Int>])
    }
    
}
