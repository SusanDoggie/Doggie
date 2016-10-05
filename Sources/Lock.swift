//
//  Lock.swift
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

public protocol Lockable : class {
    
    func lock()
    func unlock()
    func trylock() -> Bool
}

public extension Lockable {
    
    func lock() {
        while !trylock() {
            sched_yield()
        }
    }
}

public extension Lockable {
    
    @discardableResult
    func synchronized<R>(block: () throws -> R) rethrows -> R {
        self.lock()
        defer { self.unlock() }
        return try block()
    }
}

@discardableResult
public func synchronized<R>(_ obj: AnyObject, block: () throws -> R) rethrows -> R {
    objc_sync_enter(obj)
    defer { objc_sync_exit(obj) }
    return try block()
}

@discardableResult
public func synchronized<R>(_ lcks: Lockable ... , block: () throws -> R) rethrows -> R {
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
    
    fileprivate var _mtx = pthread_mutex_t()
    
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

// MARK: Condition

private extension Date {
    
    var timespec : timespec {
        let _abs_time = self.timeIntervalSince1970
        let sec = __darwin_time_t(_abs_time)
        let nsec = Int((_abs_time - Double(sec)) * 1000000000.0)
        return Foundation.timespec(tv_sec: sec, tv_nsec: nsec)
    }
}

public class SDCondition {
    
    fileprivate var _cond = pthread_cond_t()
    
    public init() {
        pthread_cond_init(&_cond, nil)
    }
    
    deinit {
        pthread_cond_destroy(&_cond)
    }
}

extension SDCondition {
    
    public func signal() {
        pthread_cond_signal(&_cond)
    }
    public func broadcast() {
        pthread_cond_broadcast(&_cond)
    }
}

extension SDLock {
    
    public func wait(_ cond: SDCondition, for predicate: @autoclosure () -> Bool) {
        while !predicate() {
            pthread_cond_wait(&cond._cond, &_mtx)
        }
    }
    @discardableResult
    public func wait(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        var _timespec = date.timespec
        while !predicate() {
            if pthread_cond_timedwait(&cond._cond, &_mtx, &_timespec) != 0 {
                return predicate()
            }
        }
        return true
    }
}

extension SDLock {
    
    public func lock(_ cond: SDCondition, for predicate: @autoclosure () -> Bool) {
        self.lock()
        self.wait(cond, for: predicate)
    }
    @discardableResult
    public func lock(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        self.lock()
        if self.wait(cond, for: predicate, until: date) {
            return true
        }
        self.unlock()
        return false
    }
    @discardableResult
    public func trylock(_ cond: SDCondition, for predicate: @autoclosure () -> Bool) -> Bool {
        if self.trylock() {
            if self.wait(cond, for: predicate, until: Date.distantPast) {
                return true
            }
            self.unlock()
        }
        return false
    }
}

extension SDLock {
    
    @discardableResult
    public func synchronized<R>(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, block: () throws -> R) rethrows -> R {
        self.lock(cond, for: predicate)
        defer { self.unlock() }
        return try block()
    }
    @discardableResult
    public func synchronized<R>(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, until date: Date, block: () throws -> R) rethrows -> R? {
        if self.lock(cond, for: predicate, until: date) {
            defer { self.unlock() }
            return try block()
        }
        return nil
    }
}

// MARK: Spin Lock

public class SDSpinLock {
    
    fileprivate var flag: Bool
    fileprivate var recursion_count: Int
    fileprivate var owner_thread: pthread_t?
    
    public init() {
        self.flag = false
        self.recursion_count = 0
        self.owner_thread = nil
    }
}

extension SDSpinLock : Lockable {
    
    public func unlock() {
        guard pthread_equal(owner_thread, pthread_self()) != 0 else {
            if flag {
                fatalError("unlock() is called by different thread.")
            } else {
                fatalError("unlock() is called before lock()")
            }
        }
        if recursion_count == 0 {
            owner_thread = nil
            guard flag.fetchStore(false) else {
                fatalError("unlock() is called before lock()")
            }
        } else {
            recursion_count -= 1
        }
    }
    public func trylock() -> Bool {
        let current_thread = pthread_self()
        if flag.compareSet(old: false, new: true) {
            owner_thread = current_thread
            recursion_count = 0
            return true
        } else if pthread_equal(owner_thread, current_thread) != 0 {
            recursion_count += 1
            return true
        }
        return false
    }
}

// MARK: Condition Lock

public class SDConditionLock : SDLock {
    
    fileprivate var cond = SDCondition()
}

extension SDConditionLock {
    
    public func signal() {
        super.synchronized {
            cond.signal()
        }
    }
    public func broadcast() {
        super.synchronized {
            cond.broadcast()
        }
    }
    public func wait(for predicate: @autoclosure () -> Bool) {
        self.wait(cond, for: predicate)
    }
    @discardableResult
    public func wait(for predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        return self.wait(cond, for: predicate, until: date)
    }
}

extension SDConditionLock {
    
    public func lock(for predicate: @autoclosure () -> Bool) {
        self.lock(cond, for: predicate)
    }
    @discardableResult
    public func lock(for predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        return self.lock(cond, for: predicate, until: date)
    }
    @discardableResult
    public func trylock(for predicate: @autoclosure () -> Bool) -> Bool {
        return self.trylock(cond, for: predicate)
    }
}

extension SDConditionLock {
    
    @discardableResult
    public func synchronized<R>(for predicate: @autoclosure () -> Bool, block: () throws -> R) rethrows -> R {
        return try self.synchronized(cond, for: predicate, block: block)
    }
    @discardableResult
    public func synchronized<R>(for predicate: @autoclosure () -> Bool, until date: Date, block: () throws -> R) rethrows -> R? {
        return try self.synchronized(cond, for: predicate, until: date, block: block)
    }
}
