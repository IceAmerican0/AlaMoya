//
//  EventMonitor.swift
//  PlayerRecord
//
//  Created by 박성준 on 2023/05/01.
//

import Foundation

public protocol EventMonitor {
    var queue: DispatchQueue { get }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask)
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive data: Data)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse)
    
    func request(_ request: DataRequest)
    func request(_ request: Request, didFailToCreateURLRequestWithError error: NetworkError)
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest)
    func request(_ request: Request, didCreateTask task: URLSessionTask)
    func request(_ request: Request, didResumeTask task: URLSessionTask)
    func request(_ request: Request, didSuspendTask task: URLSessionTask)
    func request(_ request: Request, didCancelTask task: URLSessionTask)
    func requestIsRetrying(_ request: Request)
    func requestDidFinish(_ request: Request)
    func requestDidResume(_ request: Request)
    func requestDidSuspend(_ request: Request)
    func requestDidCancel(_ request: Request)
}

extension EventMonitor {
    public var queue: DispatchQueue { .main }
    
    
}

public final class CompositeEventMonitor: EventMonitor {
    public let queue = DispatchQueue(label: "NetworkCompositeEventMonitor", qos: .utility)
    
    let monitors: [EventMonitor]
    
    init(monitors: [EventMonitor]) {
        self.monitors = monitors
    }
    
    func perforEvent(_ event: @escaping (EventMonitor) -> Void) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { event(monitor) }
            }
        }
    }
}
