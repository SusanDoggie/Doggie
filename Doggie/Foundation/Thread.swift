//
//  Thread.swift
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

private let SDThreadDefaultDispatchQueue = DispatchQueue(label: "com.SusanDoggie.Thread", attributes: .concurrent)

public typealias thread_id_t = mach_port_t

public func threadID() -> thread_id_t {
    return mach_thread_self()
}

// MARK: Lockable and Lock Guard

public protocol Lockable : class {
    
    func lock()
    func unlock()
    func trylock() -> Bool
}

public extension Lockable {
    
    @discardableResult
    func synchronized<R>(block: @noescape () throws -> R) rethrows -> R {
        self.lock()
        defer { self.unlock() }
        return try block()
    }
}

@discardableResult
public func synchronized<R>(_ obj: AnyObject, block: @noescape () throws -> R) rethrows -> R {
    objc_sync_enter(obj)
    defer { objc_sync_exit(obj) }
    return try block()
}

@discardableResult
public func synchronized<R>(_ lcks: Lockable ... , block: @noescape () throws -> R) rethrows -> R {
    if lcks.count > 1 {
        var waiting = 0
        while true {
            lcks[waiting].lock()
            if let failed = lcks.enumerated().first(where: { $0 != waiting && !$1.trylock() })?.0 {
                for (index, item) in lcks.prefix(upTo: failed).enumerated() where index != waiting {
                    item.unlock()
                }
                lcks[waiting].unlock()
                waiting = failed
            } else {
                break
            }
        }
    } else {
        lcks.first?.lock()
    }
    defer {
        for item in lcks {
            item.unlock()
        }
    }
    return try block()
}

// MARK: Lock

public class SDLock {
    
    private var _mtx = pthread_mutex_t()
    
    public init() {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        pthread_mutex_init(&_mtx, &attr)
        pthread_mutexattr_destroy(&attr)
    }
    
    deinit {
        pthread_mutex_destroy(&_mtx)
    }
}

extension SDLock : Lockable {
    
    public final func lock() {
        pthread_mutex_lock(&_mtx)
    }
    public final func unlock() {
        pthread_mutex_unlock(&_mtx)
    }
    public final func trylock() -> Bool {
        return pthread_mutex_trylock(&_mtx) == 0
    }
}

// MARK: Spin Lock

public struct SDSpinLock {
    
    private var _lck: OSSpinLock
    
    public init() {
        _lck = OS_SPINLOCK_INIT
    }
}

extension SDSpinLock {
    
    public mutating func lock() {
        OSSpinLockLock(&_lck)
    }
    public mutating func unlock() {
        OSSpinLockUnlock(&_lck)
    }
    public mutating func trylock() -> Bool {
        return OSSpinLockTry(&_lck)
    }
}

extension SDSpinLock {
    
    @discardableResult
    public mutating func synchronized<R>(block: @noescape () throws -> R) rethrows -> R {
        self.lock()
        defer { self.unlock() }
        return try block()
    }
}

// MARK: Condition Lock

public class SDConditionLock : SDLock {
    
    private var _cond = pthread_cond_t()
    
    public override init() {
        super.init()
        pthread_cond_init(&_cond, nil)
    }
    
    deinit {
        pthread_cond_destroy(&_cond)
    }
}

private extension Date {
    
    var timespec : timespec {
        let _abs_time = self.timeIntervalSince1970
        let sec = __darwin_time_t(_abs_time)
        let nsec = Int((_abs_time - Double(sec)) * 1000000000.0)
        return Foundation.timespec(tv_sec: sec, tv_nsec: nsec)
    }
}

extension SDConditionLock {
    
    public final func signal() {
        super.synchronized {
            pthread_cond_signal(&_cond)
        }
    }
    public final func broadcast() {
        super.synchronized {
            pthread_cond_broadcast(&_cond)
        }
    }
}

extension SDConditionLock {
    
    public final func lock(where predicate: @autoclosure () -> Bool) {
        super.lock()
        while !predicate() {
            pthread_cond_wait(&_cond, &_mtx)
        }
    }
    @discardableResult
    public final func lock(where predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        super.lock()
        var _timespec = date.timespec
        while !predicate() {
            if pthread_cond_timedwait(&_cond, &_mtx, &_timespec) != 0 {
                if predicate() {
                    return true
                } else {
                    super.unlock()
                    return false
                }
            }
        }
        return true
    }
    @discardableResult
    public final func trylock(where predicate: @autoclosure () -> Bool) -> Bool {
        return lock(where: predicate, until: Date.distantPast)
    }
}

extension SDConditionLock {
    
    @discardableResult
    public func synchronized<R>(where predicate: @autoclosure () -> Bool, block: @noescape () throws -> R) rethrows -> R {
        self.lock(where: predicate)
        defer { self.unlock() }
        return try block()
    }
    @discardableResult
    public func synchronized<R>(where predicate: @autoclosure () -> Bool, until date: Date, block: @noescape () throws -> R) rethrows -> R? {
        if self.lock(where: predicate, until: date) {
            defer { self.unlock() }
            return try block()
        }
        return nil
    }
}

// MARK: SDAtomic

public class SDAtomic {
    
    private let queue: DispatchQueue
    private let block: (SDAtomic) -> Void
    private var flag: Int32
    
    public init(queue: DispatchQueue, block: (SDAtomic) -> Void) {
        self.queue = queue
        self.block = block
        self.flag = 0
    }
    public init(block: (SDAtomic) -> Void) {
        self.queue = SDThreadDefaultDispatchQueue
        self.block = block
        self.flag = 0
    }
}

extension SDAtomic {
    
    public final func signal() {
        if flag.fetchStore(new: 2) == 0 {
            queue.async(execute: dispatchRunloop)
        }
    }
    
    private func dispatchRunloop() {
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

public class SDSingleton<Instance> {
    
    private var _value: Instance?
    private var spinlck: SDSpinLock = SDSpinLock()
    private let block: () -> Instance
    
    /// Create a SDSingleton.
    public init(block: () -> Instance) {
        self.block = block
    }
}

extension SDSingleton {
    
    public final func signal() {
        if !isValue {
            synchronized(self) {
                let result = self._value ?? self.block()
                self.spinlck.synchronized { self._value = result }
            }
        }
    }
    
    public final var isValue : Bool {
        return spinlck.synchronized { self._value != nil }
    }
    
    public final var value: Instance {
        self.signal()
        return self._value!
    }
}

// MARK: SDTask

public class SDTask<Result> : SDAtomic {
    
    private var _notify: [(Result) -> Void] = []
    
    private var spinlck = SDSpinLock()
    private let condition = SDConditionLock()
    
    private var _result: Result?
    
    private init(queue: DispatchQueue, suspend: ((Result) -> Bool)?, block: () -> Result) {
        super.init(queue: queue, block: SDTask.createBlock(suspend, block))
    }
    
    /// Create a SDTask and compute block with specific queue.
    public init(queue: DispatchQueue, block: () -> Result) {
        super.init(queue: queue, block: SDTask.createBlock(nil, block))
        self.signal()
    }
    
    /// Create a SDTask and compute block with default queue.
    public init(block: () -> Result) {
        super.init(block: SDTask.createBlock(nil, block))
        self.signal()
    }
}

private extension SDTask {
    
    @_transparent
    static func createBlock(_ suspend: ((Result) -> Bool)?, _ block: () -> Result) -> (SDAtomic) -> Void {
        return { atomic in
            let _self = atomic as! SDTask<Result>
            if !_self.completed {
                _self.condition.synchronized {
                    let result = _self._result ?? block()
                    _self.spinlck.synchronized { _self._result = result }
                    _self.condition.broadcast()
                }
            }
            if suspend?(_self._result!) != true {
                _self._notify.forEach { $0(_self._result!) }
            }
            _self._notify = []
        }
    }
    
    @_transparent
    func _apply<R>(_ queue: DispatchQueue, suspend: ((R) -> Bool)?, block: (Result) -> R) -> SDTask<R> {
        var storage: Result!
        let task = SDTask<R>(queue: queue, suspend: suspend) { block(storage) }
        return spinlck.synchronized {
            if _result == nil {
                _notify.append {
                    storage = $0
                    task.signal()
                }
            } else {
                storage = _result
                task.signal()
            }
            return task
        }
    }
}

extension SDTask {
    
    /// Return `true` iff task is completed.
    public final var completed: Bool {
        return spinlck.synchronized { _result != nil }
    }
    
    /// Result of task.
    public final var result: Result {
        return condition.synchronized(where: self.completed) { self._result! }
    }
}

extension SDTask {
    
    /// Run `block` after `self` is completed.
    @discardableResult
    public final func then<R>(block: (Result) -> R) -> SDTask<R> {
        return self.then(queue: queue, block: block)
    }
    
    /// Run `block` after `self` is completed with specific queue.
    @discardableResult
    public final func then<R>(queue: DispatchQueue, block: (Result) -> R) -> SDTask<R> {
        return self._apply(queue, suspend: nil, block: block)
    }
}

extension SDTask {
    
    /// Suspend if `result` satisfies `predicate`.
    @discardableResult
    public final func suspend(where predicate: (Result) -> Bool) -> SDTask<Result> {
        return self.suspend(queue: queue, where: predicate)
    }
    
    /// Suspend if `result` satisfies `predicate` with specific queue.
    @discardableResult
    public final func suspend(queue: DispatchQueue, where predicate: (Result) -> Bool) -> SDTask<Result> {
        return self._apply(queue, suspend: predicate) { $0 }
    }
}

/// Create a SDTask and compute block with default queue.
@discardableResult
public func async<Result>(block: () -> Result) -> SDTask<Result> {
    return SDTask(block: block)
}

/// Create a SDTask and compute block with specific queue.
@discardableResult
public func async<Result>(queue: DispatchQueue, _ block: () -> Result) -> SDTask<Result> {
    return SDTask(queue: queue, block: block)
}
