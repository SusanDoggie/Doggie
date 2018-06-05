//
//  Lock.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public protocol Lockable : AnyObject {
    
    func lock()
    func unlock()
    func trylock() -> Bool
    
    @discardableResult
    func synchronized<R>(block: () throws -> R) rethrows -> R
}

extension Lockable {
    
    @inlinable
    @discardableResult
    public func synchronized<R>(block: () throws -> R) rethrows -> R {
        self.lock()
        defer { self.unlock() }
        return try block()
    }
}

@inlinable
@discardableResult
public func synchronized<S : Sequence, R>(_ lcks: S, block: () throws -> R) rethrows -> R where S.Element == Lockable {
    let lcks = Array(lcks)
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

@inlinable
@discardableResult
public func synchronized<R>(_ lcks: Lockable ... , block: () throws -> R) rethrows -> R {
    return try synchronized(lcks, block: block)
}

// MARK: Lock

public class SDLock {
    
    fileprivate var _mtx = pthread_mutex_t()
    
    public init() {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, numericCast(PTHREAD_MUTEX_RECURSIVE))
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
    
    fileprivate func _wait(_ cond: SDCondition, for predicate: @autoclosure () -> Bool) {
        while !predicate() {
            pthread_cond_wait(&cond._cond, &_mtx)
        }
    }
    fileprivate func _wait(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, until time: DispatchWallTime) -> Bool {
        let _time = -Int64(bitPattern: time.rawValue)
        let sec = _time / 1000000000
        let nsec = _time % 1000000000
        var _timespec = timespec(tv_sec: Int(sec), tv_nsec: Int(nsec))
        while !predicate() {
            if pthread_cond_timedwait(&cond._cond, &_mtx, &_timespec) != 0 {
                return predicate()
            }
        }
        return true
    }
}

extension SDLock {
    
    public func wait(_ cond: SDCondition, for predicate: @autoclosure () -> Bool) {
        self.synchronized {
            self._wait(cond, for: predicate)
        }
    }
    @discardableResult
    public func wait(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, until time: DispatchWallTime) -> Bool {
        return self.synchronized {
            self._wait(cond, for: predicate, until: time)
        }
    }
}

extension SDLock {
    
    public func lock(_ cond: SDCondition, for predicate: @autoclosure () -> Bool) {
        self.lock()
        self._wait(cond, for: predicate)
    }
    @discardableResult
    public func lock(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, until time: DispatchWallTime) -> Bool {
        self.lock()
        if self._wait(cond, for: predicate, until: time) {
            return true
        }
        self.unlock()
        return false
    }
    @discardableResult
    public func trylock(_ cond: SDCondition, for predicate: @autoclosure () -> Bool) -> Bool {
        if self.trylock() {
            if self._wait(cond, for: predicate, until: .distantFuture) {
                return true
            }
            self.unlock()
        }
        return false
    }
}

extension SDLock {
    
    @inlinable
    @discardableResult
    public func synchronized<R>(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, block: () throws -> R) rethrows -> R {
        self.lock(cond, for: predicate)
        defer { self.unlock() }
        return try block()
    }
    
    @inlinable
    @discardableResult
    public func synchronized<R>(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, until time: DispatchWallTime, block: () throws -> R) rethrows -> R? {
        if self.lock(cond, for: predicate, until: time) {
            defer { self.unlock() }
            return try block()
        }
        return nil
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
    public func wait(for predicate: @autoclosure () -> Bool, until time: DispatchWallTime) -> Bool {
        return self.wait(cond, for: predicate, until: time)
    }
}

extension SDConditionLock {
    
    public func lock(for predicate: @autoclosure () -> Bool) {
        self.lock(cond, for: predicate)
    }
    @discardableResult
    public func lock(for predicate: @autoclosure () -> Bool, until time: DispatchWallTime) -> Bool {
        return self.lock(cond, for: predicate, until: time)
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
    public func synchronized<R>(for predicate: @autoclosure () -> Bool, until time: DispatchWallTime, block: () throws -> R) rethrows -> R? {
        return try self.synchronized(cond, for: predicate, until: time, block: block)
    }
}
