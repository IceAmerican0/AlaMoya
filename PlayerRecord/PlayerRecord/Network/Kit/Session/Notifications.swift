//
//  Notifications.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/05/02.
//

import Foundation

extension Notification {
    public var request: Request? {
        userInfo?[String.requestKey] as? Request
    }
    
    init(name: Notification.Name, request: Request) {
        self.init(name: name, object: nil, userInfo: [String.requestKey: request])
    }
}

public final class Notifications: EventMonitor {
    
}

extension NotificationCenter {
    func postNotification(named name: Notification.Name, with request: Request) {
        let notification = Notification(name: name, request: request)
        post(notification)
    }
}

extension Request {
    
}

extension String {
    fileprivate static let requestKey = "notification.key.request"
}

public final class NetworkNotifications: EventMonitor {
    
}
