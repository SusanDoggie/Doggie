//
//  SDThread.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Dispatch

// MARK: SDAtomic

private let SDDefaultDispatchQueue = DispatchQueue(label: "com.SusanDoggie.Thread", attributes: .concurrent)

open class SDAtomic {
    
    fileprivate let queue: DispatchQueue
    fileprivate let block: (SDAtomic) -> Void
    fileprivate var flag: Int8
    
    public init(queue: DispatchQueue = SDDefaultDispatchQueue, block: @escaping (SDAtomic) -> Void) {
        self.queue = queue
        self.block = block
        self.flag = 0
    }
}

extension SDAtomic {
    
    public func signal() {
        if flag.fetchStore(2) == 0 {
            queue.async(execute: dispatchRunloop)
        }
    }
    
    fileprivate func dispatchRunloop() {
        while true {
            flag = 1
            autoreleasepool { self.block(self) }
            if flag.compareSet(old: 1, new: 0) {
                return
            }
        }
    }
}

// MARK: SDSingleton

open class SDSingleton<Instance> {
    
    fileprivate var _value: Atomic<Instance?> = Atomic(value: nil)
    fileprivate let lck = SDLock()
    fileprivate let block: () -> Instance
    
    /// Create a SDSingleton.
    public init(block: @escaping () -> Instance) {
        self.block = block
    }
}

extension SDSingleton {
    
    public func signal() {
        if !isValue {
            lck.synchronized {
                self._value.value = self._value.value ?? self.block()
            }
        }
    }
    
    public var isValue : Bool {
        return self._value.value != nil
    }
    
    public var value: Instance {
        self.signal()
        return self._value.value!
    }
}

// MARK: SDTask

public class SDTask<Result> : SDAtomic {
    
    fileprivate var notify: [(Result) -> Void] = []
    
    fileprivate let lck = SDConditionLock()
    
    fileprivate var storage = Atomic<Result?>(value: nil)
    
    fileprivate init(queue: DispatchQueue, suspend: ((Result) -> Bool)?, block: @escaping () -> Result?) {
        super.init(queue: queue, block: SDTask.createBlock(suspend, block))
    }
    
    /// Create a SDTask and compute block.
    public init(queue: DispatchQueue = SDDefaultDispatchQueue, block: @escaping () -> Result) {
        super.init(queue: queue, block: SDTask.createBlock(nil, block))
        self.signal()
    }
}

private extension SDTask {
    
    @_transparent
    static func createBlock(_ suspend: ((Result) -> Bool)?, _ block: @escaping () -> Result?) -> (SDAtomic) -> Void {
        return { atomic in
            let _self = atomic as! SDTask<Result>
            if !_self.completed {
                guard let result = block() else { return }
                _self.lck.synchronized {
                    _self.storage.value = result
                    _self.lck.broadcast()
                }
            }
            let value = _self.storage.value!
            if suspend?(value) != true {
                _self.notify.forEach { $0(value) }
            }
            _self.notify = []
        }
    }
    
    @_transparent
    func _apply<R>(_ queue: DispatchQueue, suspend: ((R) -> Bool)?, block: @escaping (Result) -> R) -> SDTask<R> {
        var storage: Result?
        let task = SDTask<R>(queue: queue, suspend: suspend) { storage.map(block) }
        return lck.synchronized {
            if !completed {
                notify.append {
                    storage = $0
                    task.signal()
                }
            } else {
                storage = self.storage.value
                task.signal()
            }
            return task
        }
    }
}

extension SDTask {
    
    /// Return `true` iff task is completed.
    public var completed: Bool {
        return storage.value != nil
    }
    
    /// Result of task.
    public var result: Result {
        if completed {
            return storage.value!
        }
        return lck.synchronized(for: completed) { storage.value! }
    }
}

extension SDTask {
    
    /// Run `block` after `self` is completed.
    @discardableResult
    public func then<R>(block: @escaping (Result) -> R) -> SDTask<R> {
        return self.then(queue: queue, block: block)
    }
    
    /// Run `block` after `self` is completed with specific queue.
    @discardableResult
    public func then<R>(queue: DispatchQueue, block: @escaping (Result) -> R) -> SDTask<R> {
        return self._apply(queue, suspend: nil, block: block)
    }
}

extension SDTask {
    
    /// Suspend if `result` satisfies `predicate`.
    @discardableResult
    public func suspend(where predicate: @escaping (Result) -> Bool) -> SDTask<Result> {
        return self.suspend(queue: queue, where: predicate)
    }
    
    /// Suspend if `result` satisfies `predicate` with specific queue.
    @discardableResult
    public func suspend(queue: DispatchQueue, where predicate: @escaping (Result) -> Bool) -> SDTask<Result> {
        return self._apply(queue, suspend: predicate) { $0 }
    }
}

/// Create a SDTask and compute block.
@discardableResult
public func async<Result>(queue: DispatchQueue = SDDefaultDispatchQueue, _ block: @escaping () -> Result) -> SDTask<Result> {
    return SDTask(queue: queue, block: block)
}
