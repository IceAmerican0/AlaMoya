//
//  Cancellable.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/25.
//

import Dispatch

public protocol Cancellable {
    var isCancelled: Bool { get }
    
    func cancel()
}

internal class CancellableWrapper: Cancellable {
    internal var innerCancellable: Cancellable = SimpleCancellable()
    
    var isCancelled: Bool { innerCancellable.isCancelled }
    
    internal func cancel() {
        innerCancellable.cancel()
    }
}

internal class SimpleCancellable: Cancellable {
    var isCancelled = false
    func cancel() {
        isCancelled = true
    }
}

public final class CancellableToken: Cancellable, CustomDebugStringConvertible {
    let cancelAction: () -> Void
    let request: Request?
    
    public fileprivate(set) var isCancelled = false
    
    fileprivate var lock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public func cancel() {
        _ = lock.wait(timeout: DispatchTime.distantFuture)
        defer { lock.signal() }
        guard !isCancelled else { return }
        isCancelled = true
        cancelAction()
    }
    
    public init(action: @escaping () -> Void) {
        self.cancelAction = action
        self.request = nil
    }
    
    init(request: Request) {
        self.request = request
        self.cancelAction = {
            request.cancel()
        }
    }
    
    public var debugDescription: String {
        guard let _ = self.request else {
            return "Empty Request"
        }
        
        return "Cancellable -> request debugDescription"
    }
}
