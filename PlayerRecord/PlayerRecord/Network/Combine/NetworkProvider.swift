//
//  NetworkProvider.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/25.
//

import Foundation
import Combine

open class NetworkProvider {
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
}

internal typealias RequestableCompletion = (HTTPURLResponse?, URLRequest?, Data?, Swift.Error?) -> Void

internal protocol Requestable {
    func response(callbackQueue: DispatchQueue?, completionHandler: @escaping RequestableCompletion) -> Self
}
