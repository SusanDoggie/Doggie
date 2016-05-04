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

public let DispatchMainQueue = dispatch_get_main_queue()
public let DispatchGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

private let SDThreadDefaultDispatchQueue = dispatch_queue_create("com.SusanDoggie.Thread", DISPATCH_QUEUE_CONCURRENT)

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
    
    func synchronized<R>(@noescape block: () throws -> R) rethrows -> R {
        self.lock()
        defer { self.unlock() }
        return try block()
    }
}

public func synchronized<R>(obj: AnyObject, @noescape block: () throws -> R) rethrows -> R {
    objc_sync_enter(obj)
    defer { objc_sync_exit(obj) }
    return try block()
}

// MARK: LockGroup

public class SDLockGroup : ArrayLiteralConvertible {
    
    private let lck: [Lockable]
    
    public init(_ lck: Lockable ... ) {
        self.lck = lck
    }
    
    public required init(arrayLiteral elements: Lockable ... ) {
        self.lck = elements
    }
}

extension SDLockGroup : Lockable {
    
    private final func _trylock(lck: [Lockable]) -> Int {
        if lck.count == 1 {
            return lck[0].trylock() ? 1 : 0
        } else if lck.count > 1 {
            var count = 0
            while count < lck.count && lck[count].trylock() {
                count += 1
            }
            if count != lck.count {
                for i in 0..<count {
                    lck[i].unlock()
                }
            }
            return count
        }
        return 0
    }

    public final func lock() {
        if lck.count == 1 {
            lck[0].lock()
        } else if lck.count > 1 {
            var first_lock = 0
            while true {
                lck[first_lock].lock()
                var list = lck
                list.removeAtIndex(first_lock)
                var _r = _trylock(list)
                _r = _r < first_lock ? _r : _r + 1
                if _r == lck.count {
                    return
                }
                lck[first_lock].unlock()
                first_lock = _r
            }
        }
    }
    
    public final func unlock() {
        for item in lck {
            item.unlock()
        }
    }
    
    public final func trylock() -> Bool {
        return _trylock(self.lck) == self.lck.count
    }
    
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
    
    public mutating func synchronized<R>(@noescape block: () throws -> R) rethrows -> R {
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
    public final func lock(@autoclosure predicate: () -> Bool) {
        super.lock()
        while !predicate() {
            pthread_cond_wait(&_cond, &_mtx)
        }
    }
    public final func lock(@autoclosure predicate: () -> Bool, time: Double) -> Bool {
        return lock(predicate, date: NSDate(timeIntervalSinceNow: time))
    }
    public final func lock(@autoclosure predicate: () -> Bool, date: NSDate) -> Bool {
        super.lock()
        let _abs_time = date.timeIntervalSince1970
        let sec = __darwin_time_t(_abs_time)
        let nsec = Int((_abs_time - Double(sec)) * 1000000000.0)
        var _timespec = timespec(tv_sec: sec, tv_nsec: nsec)
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
    public func synchronized<R>(@autoclosure predicate: () -> Bool, @noescape block: () throws -> R) rethrows -> R {
        self.lock(predicate)
        defer { self.unlock() }
        return try block()
    }
    public func synchronized<R>(@autoclosure predicate: () -> Bool, time: Double, @noescape block: () throws -> R) rethrows -> R? {
        return try synchronized(predicate, date: NSDate(timeIntervalSinceNow: time), block: block)
    }
    public func synchronized<R>(@autoclosure predicate: () -> Bool, date: NSDate, @noescape block: () throws -> R) rethrows -> R? {
        if self.lock(predicate, date: date) {
            defer { self.unlock() }
            return try block()
        }
        return nil
    }
}

// MARK: Signal

public class SDSignal {
    
    private let sem: dispatch_semaphore_t
    
    public init(_ value: Int) {
        sem = dispatch_semaphore_create(value)
    }
}

extension SDSignal {
    
    public final func wait() {
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
    }
    
    public final func wait(time: Double) -> Bool {
        return dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, max(0, Int64(time * 1000000000.0)))) == 0
    }
    public final func wait(date: NSDate) -> Bool {
        return wait(date.timeIntervalSinceNow)
    }
    public final func signal() {
        dispatch_semaphore_signal(sem)
    }
}

// MARK: SDAtomic

public class SDAtomic {
    
    private let queue: dispatch_queue_t
    private let block: (SDAtomic) -> Void
    private var flag: Int32
    
    public init(queue: dispatch_queue_t, block: (SDAtomic) -> Void) {
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
        if flag.fetchStore(2) == 0 {
            dispatch_async(queue, dispatchRunloop)
        }
    }
    
    private func dispatchRunloop() {
        while true {
            flag = 1
            autoreleasepool { self.block(self) }
            if flag.compareSet(1, 0) {
                return
            }
        }
    }
}

// MARK: SDSingleton

public class SDSingleton<Instance> {
    
    private var token: dispatch_once_t = 0
    private var _value: Instance?
    private let block: () -> Instance
    
    /// Create a SDSingleton.
    public init(block: () -> Instance) {
        self.block = block
    }
}

extension SDSingleton {
    
    public final var value: Instance {
        dispatch_once(&token) {
            self._value = self.block()
        }
        return self._value!
    }
}

// MARK: SDTask

public class SDTask<Result> : SDAtomic {
    
    private let sem: dispatch_semaphore_t = dispatch_semaphore_create(0)
    
    private var _notify: [(Result) -> Void] = []
    
    private var _lck: SDSpinLock = SDSpinLock()
    private var _result: Result?
    
    private init(queue: dispatch_queue_t, suspend: ((Result) -> Bool)?, block: () -> Result) {
        super.init(queue: queue, block: SDTask.createBlock(block, suspend: suspend))
    }
    
    /// Create a SDTask and compute block with specific queue.
    public init(queue: dispatch_queue_t, block: () -> Result) {
        super.init(queue: queue, block: SDTask.createBlock(block, suspend: nil))
        self.signal()
    }
    
    /// Create a SDTask and compute block with default queue.
    public init(block: () -> Result) {
        super.init(block: SDTask.createBlock(block, suspend: nil))
        self.signal()
    }
}

private extension SDTask {
    
    static func createBlock(block: () -> Result, suspend: ((Result) -> Bool)?) -> (SDAtomic) -> Void {
        return { atomic in
            let _self = atomic as! SDTask<Result>
            if let result = _self._result {
                if suspend?(result) != true {
                    _self._notify.forEach { $0(result) }
                }
                _self._notify = []
            } else {
                let result = block()
                _self._lck.synchronized { _self._result = result }
                dispatch_semaphore_signal(_self.sem)
                _self.signal()
            }
        }
    }
    
    func _apply<R>(queue: dispatch_queue_t, suspend: ((R) -> Bool)?, block: (Result) -> R) -> SDTask<R> {
        var storage: Result!
        let task = SDTask<R>(queue: queue, suspend: suspend) { block(storage) }
        return _lck.synchronized {
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
        return _lck.synchronized { _result != nil }
    }
    
    /// Result of task.
    public final var result: Result {
        if !completed {
            dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER)
            defer { dispatch_semaphore_signal(self.sem) }
        }
        return self._result!
    }
}

extension SDTask {
    
    /// Run `block` after `self` is completed.
    public final func then<R>(block: (Result) -> R) -> SDTask<R> {
        return self.then(queue, block: block)
    }
    
    /// Run `block` after `self` is completed with specific queue.
    public final func then<R>(queue: dispatch_queue_t, block: (Result) -> R) -> SDTask<R> {
        return self._apply(queue, suspend: nil, block: block)
    }
}

extension SDTask {
    
    /// Suspend if `result` satisfies `predicate`.
    public final func suspend(predicate: (Result) -> Bool) -> SDTask<Result> {
        return self.suspend(queue, predicate: predicate)
    }
    
    /// Suspend if `result` satisfies `predicate` with specific queue.
    public final func suspend(queue: dispatch_queue_t, predicate: (Result) -> Bool) -> SDTask<Result> {
        return self._apply(queue, suspend: predicate) { $0 }
    }
}

/// Create a SDTask and compute block with default queue.
public func async<Result>(block: () -> Result) -> SDTask<Result> {
    return SDTask(block: block)
}

/// Create a SDTask and compute block with specific queue.
public func async<Result>(queue: dispatch_queue_t, _ block: () -> Result) -> SDTask<Result> {
    return SDTask(queue: queue, block: block)
}
