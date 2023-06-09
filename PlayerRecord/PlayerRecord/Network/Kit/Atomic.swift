//
//  Atomic.swift
//  PlayerRecord
//
//  Created by 박성준 on 2023/05/01.
//

import Foundation

@propertyWrapper
final class Atomic<Value> {
    private var lock: NSRecursiveLock = NSRecursiveLock()
    
    private var value: Value

    var wrappedValue: Value {
        get {
            lock.lock(); defer { lock.unlock() }
            return value
        }
        
        set {
            lock.lock(); defer { lock.unlock() }
            value = newValue
        }
    }
    
    init(wrappedValue value: Value) {
        self.value = value
    }
}
