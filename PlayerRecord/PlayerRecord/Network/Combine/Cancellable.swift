//
//  Cancellable.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/25.
//

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
