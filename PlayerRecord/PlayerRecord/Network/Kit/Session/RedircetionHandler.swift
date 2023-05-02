//
//  RedircetionHandler.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/05/02.
//

import Foundation

public protocol RedirectHandler {
    func task(_ task: URLSessionTask,
              willBeRedirectedTo request: URLRequest,
              for response: HTTPURLResponse,
              completion: @escaping (URLRequest?) -> Void)
}

public struct Redirector {
    public enum Behavior {
        case follow
        case doNotFollow
        case modify((URLSessionTask, URLRequest, HTTPURLResponse) -> URLRequest?)
    }
    
    public static let follow = Redirector(behavior: .follow)
    public static let doNotFollow = Redirector(behavior: .doNotFollow)
    public let behavior: Behavior
    
    public init(behavior: Behavior) {
        self.behavior = behavior
    }
}

extension Redirector: RedirectHandler {
    public func task(_ task: URLSessionTask,
                     willBeRedirectedTo request: URLRequest,
                     for response: HTTPURLResponse,
                     completion: @escaping (URLRequest?) -> Void) {
        switch behavior {
        case .follow:
            completion(request)
        case .doNotFollow:
            completion(nil)
        case let .modify(closure):
            let request = closure(task, request, response)
            completion(request)
        }
    }
}

extension RedirectHandler where Self == Redirector {
    public static var follow: Redirector { .follow }
    public static var doNotFollow: Redirector { .doNotFollow }
    public static func modify(using closure: @escaping (URLSessionTask, URLRequest, HTTPURLResponse) -> URLRequest?) -> Redirector {
        Redirector(behavior: .modify(closure))
    }
}
