//
//  RequestInterceptor.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/05/02.
//

import Foundation

public struct RequestAdapterState {
    public let requestID: UUID
    public let session: Session
}

public protocol RequestAdapter {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void)
    func adapt(_ urlRequest: URLRequest, using state: RequestAdapterState, completion: @escaping (Result<URLRequest, Error>) -> Void)
}

extension RequestAdapter {
    public func adapt(_ urlRequest: URLRequest, using state: RequestAdapterState, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapt(urlRequest, for: state.session, completion: completion)
    }
}

public enum RetryResult {
    case retry
    case retryWithDelay(TimeInterval)
    case doNotRetry
    case doNotRetryWithError(Error)
}

extension RetryResult {
    var retryRequirted: Bool {
        switch self {
        case .retry, .retryWithDelay : return true
        default: return false
        }
    }
    
    var delay: TimeInterval? {
        switch self {
        case let .retryWithDelay(delay): return delay
        default: return nil
        }
    }
    
    var error: Error? {
        guard case let .doNotRetryWithError(error) = self else { return nil }
        return error
    }
}

public protocol RequestRetrier {
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void)
}

public protocol RequestInterceptor: RequestAdapter, RequestRetrier {}

extension RequestInterceptor {
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }

    public func retry(_ request: Request,
                      for session: Session,
                      dueTo error: Error,
                      completion: @escaping (RetryResult) -> Void) {
        completion(.doNotRetry)
    }
}

public typealias AdaptHandler = (URLRequest, Session, _ completion: @escaping (Result<URLRequest, Error>) -> Void) -> Void
public typealias RetryHandler = (Request, Session, Error, _ completion: @escaping (RetryResult) -> Void) -> Void

open class Adapter: RequestInterceptor {
    private let adaptHandler: AdaptHandler
    
    public init(_ adaptHandler: @escaping AdaptHandler) {
        self.adaptHandler = adaptHandler
    }
    
    open func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adaptHandler(urlRequest, session, completion)
    }
    
    open func adapt(_ urlRequest: URLRequest, using state: RequestAdapterState, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adaptHandler(urlRequest, state.session, completion)
    }
}

extension RequestAdapter where Self == Adapter {
    public static func adapter(using closure: @escaping AdaptHandler) -> Adapter {
        Adapter(closure)
    }
}

open class Retrier: RequestInterceptor {
    private let retryHandler: RetryHandler
    
    public init(_ retryHandler: @escaping RetryHandler) {
        self.retryHandler = retryHandler
    }
    
    open func retry(_ request: Request,
                    for session: Session,
                    dueTo error: Error,
                    completion: @escaping (RetryResult) -> Void) {
        retryHandler(request, session, error, completion)
    }
}

extension RequestRetrier where Self == Retrier {
    public static func retrier(using closure: @escaping RetryHandler) -> Retrier {
        Retrier(closure)
    }
}

open class Interceptor: RequestInterceptor {
    public let adapters: [RequestAdapter]
    public let retriers: [RequestRetrier]
    
    public init(adaptHandler: @escaping AdaptHandler, retryHandler: @escaping RetryHandler) {
        adapters = [Adapter(adaptHandler)]
        retriers = [Retrier(retryHandler)]
    }
    
    public init(adapter: RequestAdapter, retrier: RequestRetrier) {
        adapters = [adapter]
        retriers = [retrier]
    }
    
    public init(adapters: [RequestAdapter] = [], retriers: [RequestRetrier] = [], interceptors: [RequestInterceptor] = []) {
        self.adapters = adapters + interceptors
        self.retriers = retriers + interceptors
    }
    
    open func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapt(urlRequest, for: session, using: adapters, completion: completion)
    }
    
    private func adapt(_ urlRequest: URLRequest,
                       for session: Session,
                       using state: [RequestAdapter],
                       completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var pendingAdapters = adapters
        guard !pendingAdapters.isEmpty else { completion(.success(urlRequest)); return }
        let adapter = pendingAdapters.removeFirst()
        
        adapter.adapt(urlRequest, for: session) { result in
            switch result {
            case let .success(urlRequest):
                self.adapt(urlRequest, for: session, using: pendingAdapters, completion: completion)
            case .failure:
                completion(result)
            }
        }
    }
    
    open func adapt(_ urlRequest: URLRequest,
                    using state: RequestAdapterState,
                    completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapt(urlRequest, using: state, adapters: adapters, completion: completion)
    }
    
    private func adapt(_ urlRequest: URLRequest,
                       using state: RequestAdapterState,
                       adapters: [RequestAdapter],
                       completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var pendingAdapters = adapters
        guard !pendingAdapters.isEmpty else { completion(.success(urlRequest)); return }
        let adapter = pendingAdapters.removeFirst()
        
        adapter.adapt(urlRequest, using: state) { result in
            switch result {
            case let .success(urlRequest):
                self.adapt(urlRequest, using: state, adapters: pendingAdapters, completion: completion)
            case .failure:
                completion(result)
            }
        }
    }
    
    open func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        retry(request, for: session, dueTo: error, completion: completion)
    }
    
    private func retry(_ request: Request, for session: Session, dueTo error: Error, using retriers: [RequestRetrier], completion: @escaping (RetryResult) -> Void) {
        var pendingRetriers = retriers
        guard !pendingRetriers.isEmpty else { completion(.doNotRetry); return }
        let retrier = pendingRetriers.removeFirst()

        retrier.retry(request, for: session, dueTo: error) { result in
            switch result {
            case .retry, .retryWithDelay, .doNotRetryWithError:
                completion(result)
            case .doNotRetry:
                self.retry(request, for: session, dueTo: error, using: pendingRetriers, completion: completion)
            }
        }
    }
}

extension RequestInterceptor where Self == Interceptor {
    public static func interceptor(adapter: @escaping AdaptHandler, retrier: @escaping RetryHandler) -> Interceptor {
        Interceptor(adaptHandler: adapter, retryHandler: retrier)
    }
    
    public static func interceptor(adapter: RequestAdapter, retrier: RequestRetrier) -> Interceptor {
        Interceptor(adapter: adapter, retrier: retrier)
    }
    
    public static func interceptor(adapters: [RequestAdapter] = [],
                                   retriers: [RequestRetrier] = [],
                                   interceptors: [RequestInterceptor] = []) -> Interceptor {
        Interceptor(adapters: adapters, retriers: retriers, interceptors: interceptors)
    }
}
