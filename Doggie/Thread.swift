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
    
    func synchronized<R>(@noescape block: () -> R) -> R {
        self.lock()
        defer { self.unlock() }
        return block()
    }
}

public func synchronized<R>(obj: AnyObject, @noescape block: () -> R) -> R {
    objc_sync_enter(obj)
    defer { objc_sync_exit(obj) }
    return block()
}

// MARK: LockGroup

/// returns count of locks if successful. Otherwise, returns the index of the lock which failed to be locked.
private func _trylock(lck: [Lockable]) -> Int {
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

private func _lock(lck: [Lockable]) {
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

private func _unlock(lck: [Lockable]) {
    for item in lck {
        item.unlock()
    }
}

/// returns count of locks if successful. Otherwise, returns the index of the lock which failed to be locked.
public func trylock(lck: Lockable ... ) -> Int {
    return _trylock(lck)
}

public func lock(lck: Lockable ... ) {
    _lock(lck)
}

public func unlock(lck: Lockable ... ) {
    _unlock(lck)
}

public final class SDLockGroup : ArrayLiteralConvertible {
    
    private let lck: [Lockable]
    
    public init(_ lck: Lockable ... ) {
        self.lck = lck
    }
    
    public required init(arrayLiteral elements: Lockable ... ) {
        self.lck = elements
    }
}

extension SDLockGroup : Lockable {
    
    public func lock() {
        _lock(self.lck)
    }
    
    public func unlock() {
        _unlock(self.lck)
    }
    
    public func trylock() -> Bool {
        return _trylock(self.lck) == self.lck.count
    }
    
}

extension SDLockGroup: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "SDLockGroup"
    }
    public var debugDescription: String {
        return "SDLockGroup"
    }
}

// MARK: Lock

public final class SDLock {
    
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
    
    public func lock() {
        pthread_mutex_lock(&_mtx)
    }
    public func unlock() {
        pthread_mutex_unlock(&_mtx)
    }
    public func trylock() -> Bool {
        return pthread_mutex_trylock(&_mtx) == 0
    }
}

extension SDLock: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "SDLock"
    }
    public var debugDescription: String {
        return "SDLock"
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
    
    public mutating func synchronized<R>(@noescape block: () -> R) -> R {
        self.lock()
        defer { self.unlock() }
        return block()
    }
}

extension SDSpinLock: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "SDSpinLock"
    }
    public var debugDescription: String {
        return "SDSpinLock"
    }
}

// MARK: Condition Lock

public final class SDConditionLock {
    
    private let lck: SDLock
    private var _cond = pthread_cond_t()
    
    public init() {
        lck = SDLock()
        pthread_cond_init(&_cond, nil)
    }
    
    deinit {
        pthread_cond_destroy(&_cond)
    }
}

extension SDConditionLock : Lockable {
    
    public func lock() {
        lck.lock()
    }
    public func unlock() {
        pthread_cond_signal(&_cond)
        lck.unlock()
    }
    public func trylock() -> Bool {
        return lck.trylock()
    }
}

extension SDConditionLock {
    
    public func signal() {
        lck.synchronized {
            pthread_cond_signal(&_cond)
        }
    }
    public func broadcast() {
        lck.synchronized {
            pthread_cond_broadcast(&_cond)
        }
    }
    public func wait(@autoclosure predicate: () -> Bool) {
        lck.lock()
        while !predicate() {
            pthread_cond_wait(&_cond, &lck._mtx)
        }
    }
    public func wait(time: Double, @autoclosure predicate: () -> Bool) -> Bool {
        return wait(NSDate(timeIntervalSinceNow: time), predicate: predicate)
    }
    public func wait(date: NSDate, @autoclosure predicate: () -> Bool) -> Bool {
        lck.lock()
        let _abs_time = date.timeIntervalSince1970
        let sec = __darwin_time_t(_abs_time)
        let nsec = Int((_abs_time - Double(sec)) * 1000000000.0)
        var _timespec = timespec(tv_sec: sec, tv_nsec: nsec)
        while !predicate() {
            if pthread_cond_timedwait(&_cond, &lck._mtx, &_timespec) != 0 {
                return predicate()
            }
        }
        return true
    }
    public func synchronized<R>(@autoclosure predicate: () -> Bool, @noescape block: () -> R) -> R {
        self.wait(predicate)
        defer { self.unlock() }
        return block()
    }
}

extension SDConditionLock: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "SDConditionLock"
    }
    public var debugDescription: String {
        return "SDConditionLock"
    }
}

// MARK: Signal

public final class SDSignal {
    
    private let sem: dispatch_semaphore_t
    
    public init(_ value: Int) {
        sem = dispatch_semaphore_create(value)
    }
}

extension SDSignal {
    
    public func wait() {
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
    }
    
    public func wait(time: Double) -> Bool {
        return dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, Int64(time * 1000000000.0))) == 0
    }
    public func wait(date: NSDate) -> Bool {
        return dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, Int64(date.timeIntervalSinceNow * 1000000000.0))) == 0
    }
    public func signal() {
        dispatch_semaphore_signal(sem)
    }
}

extension SDSignal: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "SDSignal"
    }
    public var debugDescription: String {
        return "SDSignal"
    }
}

// MARK: SDTask

public let DispatchMainQueue = dispatch_get_main_queue()
public let DispatchGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

private let SDTaskDefaultDispatchQueue = dispatch_queue_create("com.SusanDoggie.SDTask", DISPATCH_QUEUE_CONCURRENT)

public final class SDTask<Result> {
    
    private let sem: dispatch_semaphore_t = dispatch_semaphore_create(0)
    private let group: dispatch_group_t = dispatch_group_create()
    private let queue: dispatch_queue_t
    
    private typealias NotifyType = () -> ()
    private var _lck: SDSpinLock = SDSpinLock()
    private var _notify: [NotifyType] = []
    
    private var _result: Result! = nil
    
    private init(_ queue: dispatch_queue_t) {
        self.queue = queue
    }
    
    /// Create a SDTask and compute block with specific queue.
    public init(_ queue: dispatch_queue_t, _ block: () -> Result) {
        self.queue = queue
        self.submit(block)
    }
    
    /// Create a SDTask and compute block with default queue.
    public convenience init(_ block: () -> Result) {
        self.init(SDTaskDefaultDispatchQueue, block)
    }
}

extension SDTask {
    
    private func notify() {
        self._lck.synchronized {
            self._notify.forEach { $0() }
            self._notify = []
        }
    }
    private func submit(block: () -> Result) {
        dispatch_group_async(group, queue) {
            self._result = block()
            defer { self.signal() }
        }
        dispatch_group_notify(group, queue, self.notify)
    }
    private func signal() {
        dispatch_semaphore_signal(self.sem)
    }
    
    /// Return `true` iff task is completed.
    public var completed: Bool {
        return _result != nil
    }
    
    /// Result of task.
    public var result: Result {
        if self._result == nil {
            dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER)
            defer { dispatch_semaphore_signal(self.sem) }
        }
        return self._result
    }
}

extension SDTask {
    
    /// Run `block` after `self` is completed.
    public func then<R>(block: (Result) -> R) -> SDTask<R> {
        return self.then(queue, block)
    }
    
    /// Run `block` after `self` is completed with specific queue.
    public func then<R>(queue: dispatch_queue_t, _ block: (Result) -> R) -> SDTask<R> {
        return _lck.synchronized {
            if completed {
                return SDTask<R>(queue) { block(self.result) }
            }
            let task = SDTask<R>(queue)
            _notify.append { task.submit { block(self.result) } }
            return task
        }
    }
    
    /// Return `result` if it satisfies `predicate`.
    public func filter(predicate: (Result) -> Bool) -> SDTask<Result?> {
        return self.filter(queue, predicate)
    }
    
    /// Return `result` if it satisfies `predicate` with specific queue.
    public func filter(queue: dispatch_queue_t, _ predicate: (Result) -> Bool) -> SDTask<Result?> {
        return self.then(queue) { predicate($0) ? $0 : nil }
    }
}

extension SDTask {
    
    private func suspend_signal(result: Result, _ predicate: (Result) -> Bool) {
        do {
            self._result = result
            defer { self.signal() }
        }
        dispatch_async(queue) {
            if !predicate(result) {
                self.notify()
            }
        }
    }
    
    /// Suspend if `result` satisfies `predicate`.
    public func suspend(predicate: (Result) -> Bool) -> SDTask<Result> {
        return self.suspend(queue, predicate)
    }
    
    /// Suspend if `result` satisfies `predicate` with specific queue.
    public func suspend(queue: dispatch_queue_t, _ predicate: (Result) -> Bool) -> SDTask<Result> {
        return _lck.synchronized {
            let task = SDTask<Result>(queue)
            if completed {
                dispatch_async(queue) { task.suspend_signal(self.result, predicate) }
            } else {
                _notify.append { task.suspend_signal(self.result, predicate) }
            }
            return task
        }
    }
}

/// Create a SDTask and compute block with default queue.
public func async<Result>(block: () -> Result) -> SDTask<Result> {
    return SDTask(block)
}

/// Create a SDTask and compute block with specific queue.
public func async<Result>(queue: dispatch_queue_t, _ block: () -> Result) -> SDTask<Result> {
    return SDTask(queue, block)
}
