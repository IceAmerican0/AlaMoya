//
//  NetworkProvider.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/25.
//

import Foundation
import Combine

public typealias Completion = (_ result: Result<Response, NetworkError>) -> Void

public typealias ProgressBlock = (_ progress: ProgressResponse) -> Void

public typealias Method = HTTPMethod

public struct ProgressResponse {
    public let response: Response?
    public let progressObject: Progress?
    
    public init(response: Response?, progressObject: Progress?) {
        self.response = response
        self.progressObject = progressObject
    }
    
    public var completed: Bool { response != nil }
    
    public var progress: Double {
        if completed {
            return 1.0
        } else if let progressObject = progressObject, progressObject.totalUnitCount > 0 {
            return progressObject.fractionCompleted
        } else {
            return 0.0
        }
    }
}

public protocol NetworkProviderType: AnyObject {
    associatedtype Target: TargetType
    
    func request(_ target: Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion) -> Cancellable
}

open class NetworkProvider<Target: TargetType>: NetworkProviderType {
    public typealias StubClosure = (Target) -> StubBehavior
    public typealias EndpointClosure = (Target) -> Endpoint
    
    public let stubClousure: StubClosure
    public let endpointClosure: EndpointClosure
    public let trackInflights: Bool
    let callbackQueue: DispatchQueue?
    
    public init(callbackQueue: DispatchQueue?) {
        self.callbackQueue = callbackQueue
    }
    
    open func endpoint(_ token: Target) -> Endpoint {
        endpointClosure(token)
    }
    
    func requestPublisher(_ target: Target, callbackQueue: DispatchQueue? = nil) -> AnyPublisher<Response, NetworkError> {
        return NetworkPublisher { [weak self] subscriber in
                return self?.request(target, callbackQueue: callbackQueue, progress: nil) { result in
                    switch result {
                    case let .success(response):
                        _ = subscriber.receive(response)
                        subscriber.receive(completion: .finished)
                    case let .failure(error):
                        subscriber.receive(completion: .failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    open func request(_ target: Target,
                      callbackQueue: DispatchQueue? = .none,
                      progress: ProgressBlock? = .none,
                      completion: @escaping Completion) -> Cancellable {

        let callbackQueue = callbackQueue ?? self.callbackQueue
        return requestNormal(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}

public extension NetworkProvider {
    func requestNormal(_ target: Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion) -> Cancellable {
        let cancellableToken = CancellableWrapper()
        let endpoint = self.endpoint(target)
        let stubBehavior = self.stubClousure(target)
        
        let pluginsWithCompletion: Completion = { result in
            completion(result)
        }
        
        if trackInflights {
            
        }
        
        let performNetworking = { (requestResult: Result<URLRequest, NetworkError>) in
            if cancellableToken.isCancelled {
                Completion(.failure(error))
            }
            
            cancellableToken.innerCancellable = self.performRequest(target, request: request, callbackQueue: callbackQueue, progress: progress, completion: networkCompletion, endpoint: endpoint, stubBehavior: stubBehavior)
        }
        
        return cancellableToken
    }
    
    func sendRequest(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion) -> CancellableToken
    
    private func performRequest(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion, endpoint: Endpoint, stubBehavior: StubBehavior) -> Cancellable {
        switch stubBehavior {
        case .never:
            switch endpoint.task {
            case .requestData:
                return self.sendRequest
            case .requestJSONEncodable(_):
                <#code#>
            }
        default:
            return
        }
    }
}

// MARK: Stubbing

public enum StubBehavior {
    case never
    case immediate
    case delayed(seconds: TimeInterval)
}

public extension NetworkProvider {
    final class func neverStub(_: Target) -> StubBehavior { .never }
    final class func immediatelyStub(_: Target) -> StubBehavior { .immediate }
    final class func delayedStub(seconds : TimeInterval) -> (Target) -> StubBehavior {
        return { _ in .delayed(seconds: seconds) }
    }
}

// MARK: Requestable

internal typealias RequestableCompletion = (HTTPURLResponse?, URLRequest?, Data?, Swift.Error?) -> Void

internal protocol Requestable {
    func response(callbackQueue: DispatchQueue?, completionHandler: @escaping RequestableCompletion) -> Self
}

public func convertResponseToResult(_ response: HTTPURLResponse?, request: URLRequest?, data: Data?, error: Swift.Error?) ->
    Result<Response, NetworkError> {
        switch (response, data, error) {
        case let (.some(response), data, .none):
            let response = Response(statusCode: response.statusCode, data: data ?? Data(), request: request, response: response)
            return .success(response)
        case let (.some(response), _, .some(error)):
            let response = Response(statusCode: response.statusCode, data: data ?? Data(), request: request, response: response)
            return .failure(error as! NetworkError)
        case let (_, _, .some(error)):
            return .failure(error as! NetworkError)
        default:
            return .failure(error as! NetworkError)
        }
}
