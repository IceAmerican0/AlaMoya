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
    
    public typealias RequestModifier = (inout URLRequest) throws -> Void
    
    struct RequestConvertible: URLRequestConvertible {
        let url: URLConvertible
        let method: HTTPMethod
        let parameters: Parameters?
        let encoding: ParameterEncoding
        let headers: HTTPHeaders?
        let requestModifier: RequestModifier?
        
        func asURLRequest() throws -> URLRequest {
            var request = try URLRequest(url: url, method: method, headers: headers)
            try requestModifier?(&request)
            
            return try encoding.encode(request, with: parameters)
        }
    }
    
    open func request(_ convertible: URLConvertible,
                      method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default)
}

extension Session: RequestDelegate {
    public var sessionConfiguration: URLSessionConfiguration {
        session.configuration
    }
    
    public var startImmediately: Bool { startRequestImmediately }
    
    public func cleanup(after request: Request) {
        activeRequests.remove(request)
    }
    
    public func retryResult(for request: Request, dueTo error: NetworkError, completion: @escaping (RetryResult) -> Void) {
        guard let retrier = retrier(for: request) else {
            rootQueue.async { completion(.doNotRetry) }
            return
        }
        
        retrier.retry(request, for: self, dueTo: error) { retryResult in
            self.rootQueue.async {
                guard let retryResultError = retryResult.error else { completion(retryResult); return }
                
                let retryError = NetworkError.requestRetryFailed(retryError: retryResultError, originalError: error)
                completion(.doNotRetryWithError(retryError))
            }
        }
    }
    
    public func retryResult(_ request: Request, withDelay timeDelay: TimeInterval?) {
        
    }
}

// MARK: - SessionStateProvider

extension Session: SessionStateProvider {
    func request(for task: URLSessionTask) -> Request? {
        dispatchPrecondition(condition: .onQueue(rootQueue))
    }
}
