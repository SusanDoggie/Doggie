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
public func synchronized<R>(obj: AnyObject, block: @noescape () throws -> R) rethrows -> R {
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
    
    private final func _trylock(_ lck: [Lockable]) -> Int {
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
                list.remove(at: first_lock)
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
    public final func lock(where predicate: @autoclosure () -> Bool) {
        super.lock()
        while !predicate() {
            pthread_cond_wait(&_cond, &_mtx)
        }
    }
    @discardableResult
    public final func lock(where predicate: @autoclosure () -> Bool, time: Double) -> Bool {
        return lock(where: predicate, date: Date(timeIntervalSinceNow: time))
    }
    @discardableResult
    public final func lock(where predicate: @autoclosure () -> Bool, date: Date) -> Bool {
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
    @discardableResult
    public func synchronized<R>(where predicate: @autoclosure () -> Bool, block: @noescape () throws -> R) rethrows -> R {
        self.lock(where: predicate)
        defer { self.unlock() }
        return try block()
    }
    @discardableResult
    public func synchronized<R>(where predicate: @autoclosure () -> Bool, time: Double, block: @noescape () throws -> R) rethrows -> R? {
        return try synchronized(where: predicate, date: Date(timeIntervalSinceNow: time), block: block)
    }
    @discardableResult
    public func synchronized<R>(where predicate: @autoclosure () -> Bool, date: Date, block: @noescape () throws -> R) rethrows -> R? {
        if self.lock(where: predicate, date: date) {
            defer { self.unlock() }
            return try block()
        }
        return nil
    }
}

// MARK: Signal

public class SDSignal {
    
    private let sem: DispatchSemaphore
    
    public init(_ value: Int) {
        sem = DispatchSemaphore(value: value)
    }
}

extension SDSignal {
    
    public final func wait() {
        sem.wait()
    }
    
    public final func wait(time: Double) -> Bool {
        return sem.wait(timeout: DispatchTime.now() + time) == .Success
    }
    public final func wait(date: Date) -> Bool {
        return wait(time: date.timeIntervalSinceNow)
    }
    public final func signal() {
        sem.signal()
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
    
    private var token: dispatch_once_t = 0
    private var _value: Instance!
    private let block: () -> Instance
    
    /// Create a SDSingleton.
    public init(block: () -> Instance) {
        self.block = block
    }
}

extension SDSingleton {
    
    public final func signal() {
        dispatch_once(&token) {
            self._value = self.block()
        }
    }
    
    public final var isValue : Bool {
        return self._value != nil
    }
    
    public final var value: Instance {
        get {
            self.signal()
            return self._value
        }
        set {
            dispatch_once(&token) { /* do nothing. */ }
            self._value = newValue
        }
    }
}

// MARK: SDTask

public class SDTask<Result> : SDAtomic {
    
    private var _notify: [(Result) -> Void] = []
    
    private let lck = SDLock()
    private var spinlck: SDSpinLock = SDSpinLock()
    
    private let _set: (SDTask) -> Void
    private var _result: Result?
    
    private init(queue: DispatchQueue, suspend: ((Result) -> Bool)?, block: () -> Result) {
        self._set = SDTask.createBlock(block)
        super.init(queue: queue, block: SDTask.createSignalBlock(suspend))
    }
    
    /// Create a SDTask and compute block with specific queue.
    public init(queue: DispatchQueue, block: () -> Result) {
        self._set = SDTask.createBlock(block)
        super.init(queue: queue, block: SDTask.createSignalBlock(nil))
        self.signal()
    }
    
    /// Create a SDTask and compute block with default queue.
    public init(block: () -> Result) {
        self._set = SDTask.createBlock(block)
        super.init(block: SDTask.createSignalBlock(nil))
        self.signal()
    }
}

private extension SDTask {
    
    @_transparent
    static func createBlock(_ block: () -> Result) -> (SDTask) -> Void {
        return { _self in
            _self.lck.synchronized {
                if !_self.completed {
                    let result = block()
                    _self.spinlck.synchronized { _self._result = _self._result ?? result }
                }
            }
        }
    }
    
    @_transparent
    static func createSignalBlock(_ suspend: ((Result) -> Bool)?) -> (SDAtomic) -> Void {
        return { atomic in
            let _self = atomic as! SDTask<Result>
            if let result = _self._result {
                if suspend?(result) != true {
                    _self._notify.forEach { $0(result) }
                }
                _self._notify = []
            } else {
                _self._set(_self)
                _self.signal()
            }
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
        self._set(self)
        return self._result!
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
