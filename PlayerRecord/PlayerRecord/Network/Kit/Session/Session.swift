//
//  Session.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/05/02.
//

import Foundation

open class Session {
    public static let `default` = Session()
    public let session: URLSession
    public let delegate: SessionDelegate
    public let rootQueue: DispatchQueue
    public let startRequestImmediately: Bool
    public let requestQueue: DispatchQueue
    public let serializationQueue: DispatchQueue
    public let interceptor: RequestInterceptor?
    public let serverTrustManager: ServerTrustManager?
    public let redirectHandler: RedirectHandler?
    public let eventMonitor: CompositeEventMonitor
    public let defaultEventMonitors: [EventMonitor] = [Notifications()]
    
    var activeRequests: Set<Request> = []
    var waitingCompletions: [URLSessionTask: () -> Void] = [:]
}

public protocol RequestDelegate: AnyObject {
    var sessionConfiguration: URLSessionConfiguration { get }
    var startImmediately: Bool { get }
    var cleanup(after request )
}

// MARK: - SessionStateProvider

extension Session: SessionStateProvider {
    func request(for task: URLSessionTask) -> Request? {
        dispatchPrecondition(condition: .onQueue(rootQueue))
    }
}
