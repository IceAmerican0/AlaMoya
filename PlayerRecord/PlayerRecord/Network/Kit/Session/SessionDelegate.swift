//
//  SessionDelegate.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/05/02.
//

import Foundation

open class SessionDelegate: NSObject {
    weak var stateProvider: SessionStateProvider?
    var eventMonitor: EventMonitor?
    
    func request<R: Request>(for task: URLSessionTask, as type: R.Type) -> R? {
        guard let provider = stateProvider else {
            assertionFailure("StateProvider is nil.")
            return nil
        }
        
        return provider.request(for: task) as? R
    }
}

protocol SessionStateProvider: AnyObject {
    func request(for task: URLSessionTask) -> Request?
}
