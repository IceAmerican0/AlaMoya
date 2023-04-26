//
//  NetworkPublisher.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/25.
//

import Foundation
import Combine

internal class NetworkPublisher<Output>: Publisher {
    internal typealias Failure = NetworkError
    
    private class Subscription: Combine.Subscription {
        private let performCall: () -> Cancellable?
        private var cancellable: Cancellable?
        
        init(subscriber: AnySubscriber<Output, NetworkError>, callback: @escaping (AnySubscriber<Output, NetworkError>) -> Cancellable?) {
            performCall = { callback(subscriber) }
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard demand > .none else { return }
            
            cancellable = performCall()
        }
        
        func cancel() {
            cancellable?.cancel()
        }
    }
    
    private let callback: (AnySubscriber<Output, NetworkError>) -> Cancellable?
    
    init(callback: @escaping (AnySubscriber<Output, NetworkError>) -> Cancellable?) {
        self.callback = callback
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: AnySubscriber(subscriber), callback: callback)
        subscriber.receive(subscription: subscription)
    }
}
