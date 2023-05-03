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
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive data: Data)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse)
    
    func request(_ request: DataRequest, didValidateRequest urlRequest: URLRequest?, response: HTTPURLResponse, data: Data?, withResult result: Request.ValidationResult)
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
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {}
    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {}
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive data: Data) {}
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) {}
    
    public func request(_ request: DataRequest, didValidateRequest urlRequest: URLRequest?, response: HTTPURLResponse, data: Data?, withResult result: Request.ValidationResult) {}
    public func request(_ request: Request, didFailToCreateURLRequestWithError error: NetworkError) {}
    public func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {}
    public func request(_ request: Request, didCreateTask task: URLSessionTask) {}
    public func request(_ request: Request, didResumeTask task: URLSessionTask) {}
    public func request(_ request: Request, didSuspendTask task: URLSessionTask) {}
    public func request(_ request: Request, didCancelTask task: URLSessionTask) {}
    public func requestIsRetrying(_ request: Request) {}
    public func requestDidFinish(_ request: Request) {}
    public func requestDidResume(_ request: Request) {}
    public func requestDidSuspend(_ request: Request) {}
    public func requestDidCancel(_ request: Request) {}
}

public final class CompositeEventMonitor: EventMonitor {
    public let queue = DispatchQueue(label: "NetworkCompositeEventMonitor", qos: .utility)
    
    let monitors: [EventMonitor]
    
    init(monitors: [EventMonitor]) {
        self.monitors = monitors
    }
    
    func performEvent(_ event: @escaping (EventMonitor) -> Void) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { event(monitor) }
            }
        }
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        performEvent { $0.urlSession(session, didBecomeInvalidWithError: error) }
    }
    
    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        performEvent { $0.urlSession(session, taskIsWaitingForConnectivity: task) }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        performEvent { $0.urlSession(session, task: task, didCompleteWithError: error) }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive data: Data) {
        performEvent { $0.urlSession(session, task: task, didReceive: data) }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) {
        performEvent { $0.urlSession(session, dataTask: dataTask, willCacheResponse: proposedResponse) }
    }
    
    public func request(_ request: DataRequest, didValidateRequest urlRequest: URLRequest?, response: HTTPURLResponse, data: Data?, withResult result: Request.ValidationResult) {
        performEvent { $0.request(request, didValidateRequest: urlRequest, response: response, data: data, withResult: result) }
    }
    
    public func request(_ request: Request, didFailToCreateURLRequestWithError error: NetworkError) {
        performEvent { $0.request(request, didFailToCreateURLRequestWithError: error) }
    }
    
    public func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        performEvent { $0.request(request, didCreateURLRequest: urlRequest) }
    }
    
    public func request(_ request: Request, didCreateTask task: URLSessionTask) {
        performEvent { $0.request(request, didCreateTask: task) }
    }
    
    public func request(_ request: Request, didResumeTask task: URLSessionTask) {
        performEvent { $0.request(request, didResumeTask: task) }
    }
    
    public func request(_ request: Request, didSuspendTask task: URLSessionTask) {
        performEvent { $0.request(request, didSuspendTask: task) }
    }
    
    public func request(_ request: Request, didCancelTask task: URLSessionTask) {
        performEvent { $0.request(request, didCancelTask: task) }
    }
    
    public func requestIsRetrying(_ request: Request) {
        performEvent { $0.requestIsRetrying(request) }
    }
    
    public func requestDidFinish(_ request: Request) {
        performEvent { $0.requestDidFinish(request) }
    }
    
    public func requestDidResume(_ request: Request) {
        performEvent { $0.requestDidResume(request) }
    }
    
    public func requestDidSuspend(_ request: Request) {
        performEvent { $0.requestDidSuspend(request) }
    }
    
    public func requestDidCancel(_ request: Request) {
        performEvent { $0.requestDidCancel(request) }
    }
}

// TODO:
open class ClosureEventMonitor: EventMonitor {
    
}
