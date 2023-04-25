//
//  Request.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/25.
//

import Foundation

public class Request {
    public enum State {
        case initialized
        case resumed
        case suspended
        case cancelled
        case finished
        
        func canTransitionTo(_ state: State) -> Bool {
            switch (self, state) {
            case (.initialized, _):
                return true
            case (_, .initialized), (.cancelled, _), (.finished, _):
                return false
            case (.resumed, .cancelled), (.suspended, .cancelled), (.resumed, .suspended), (.suspended, .resumed):
                return true
            case (.suspended, .suspended), (.resumed, .resumed):
                return false
            case (_, .finished):
                return true
            }
        }
    }
    
    struct MutableState {
        var state: State = .initialized
        var downloadPrgressHandler: (handler: ProgressHandler, queue: DispatchQueue)?
        var requests: [URLRequest] = []
        var tasks: [URLSessionTask] = []
        var retryCount = 0
        var error: NetworkError?
        var isFinishing = false
        var finishHandlers: [() -> Void] = []
    }
    
    @Protected
    fileprivate var mutableState = MutableState()
    
    
    
    
    public typealias ProgressHandler = (Progress) -> Void
    
    public let downloadProgress = Progress(totalUnitCount: 0)
}
