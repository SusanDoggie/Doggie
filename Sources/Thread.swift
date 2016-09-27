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
import Dispatch
import c11_atomic

public protocol SDAtomicType {
    
    /// Compare and set the value.
    mutating func compareSet(old: Self, new: Self) -> Bool
    
    /// Sets the value, and returns the previous value.
    mutating func fetchStore(new: Self) -> Self
    
    /// Sets the value, and returns the previous value. `block` is called repeatedly until result accepted.
    mutating func fetchStore(block: (Self) throws -> Self) rethrows -> Self
}

public extension SDAtomicType {
    
    public mutating func fetchStore(new: Self) -> Self {
        return self.fetchStore { _ in new }
    }
    
    public mutating func fetchStore(block: (Self) throws -> Self) rethrows -> Self {
        while true {
            let old = self
            if self.compareSet(old: old, new: try block(old)) {
                return old
            }
        }
    }
}

extension Bool : SDAtomicType {
    
    /// Compare and set Int8 with barrier.
    public mutating func compareSet(old: Bool, new: Bool) -> Bool {
        return _AtomicCompareAndSwapBoolBarrier(old, new, &self)
    }
    
    /// Set Int8 with barrier.
    public mutating func fetchStore(new: Bool) -> Bool {
        return _AtomicExchangeBoolBarrier(new, &self)
    }
}

extension Int8 : SDAtomicType {
    
    /// Compare and set Int8 with barrier.
    public mutating func compareSet(old: Int8, new: Int8) -> Bool {
        return _AtomicCompareAndSwap8Barrier(old, new, &self)
    }
    
    /// Set Int8 with barrier.
    public mutating func fetchStore(new: Int8) -> Int8 {
        return _AtomicExchange8Barrier(new, &self)
    }
}

extension Int16 : SDAtomicType {
    
    /// Set Int16 with barrier.
    public mutating func compareSet(old: Int16, new: Int16) -> Bool {
        return _AtomicCompareAndSwap16Barrier(old, new, &self)
    }
    
    /// Set Int16 with barrier.
    public mutating func fetchStore(new: Int16) -> Int16 {
        return _AtomicExchange16Barrier(new, &self)
    }
}

extension Int32 : SDAtomicType {
    
    /// Compare and set Int32 with barrier.
    public mutating func compareSet(old: Int32, new: Int32) -> Bool {
        return _AtomicCompareAndSwap32Barrier(old, new, &self)
    }
    
    /// Set Int32 with barrier.
    public mutating func fetchStore(new: Int32) -> Int32 {
        return _AtomicExchange32Barrier(new, &self)
    }
}

extension Int64 : SDAtomicType {
    
    /// Compare and set Int64 with barrier.
    public mutating func compareSet(old: Int64, new: Int64) -> Bool {
        return _AtomicCompareAndSwap64Barrier(old, new, &self)
    }
    
    /// Set Int64 with barrier.
    public mutating func fetchStore(new: Int64) -> Int64 {
        return _AtomicExchange64Barrier(new, &self)
    }
}

extension Int : SDAtomicType {
    
    /// Compare and set Int with barrier.
    public mutating func compareSet(old: Int, new: Int) -> Bool {
        return _AtomicCompareAndSwapLongBarrier(old, new, &self)
    }
    
    /// Set Int with barrier.
    public mutating func fetchStore(new: Int) -> Int {
        return _AtomicExchangeLongBarrier(new, &self)
    }
}

extension UInt8 : SDAtomicType {
    
    /// Compare and set UInt8 with barrier.
    public mutating func compareSet(old: UInt8, new: UInt8) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UInt8>) -> Bool {
            return theVal.withMemoryRebound(to: Int8.self, capacity: 1) { _AtomicCompareAndSwap8Barrier(Int8(bitPattern: old), Int8(bitPattern: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set UInt8 with barrier.
    public mutating func fetchStore(new: UInt8) -> UInt8 {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UInt8>) -> Int8 {
            return theVal.withMemoryRebound(to: Int8.self, capacity: 1) { _AtomicExchange8Barrier(Int8(bitPattern: new), $0) }
        }
        return UInt8(bitPattern: exchange(&self))
    }
}

extension UInt16 : SDAtomicType {
    
    /// Compare and set UInt16 with barrier.
    public mutating func compareSet(old: UInt16, new: UInt16) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UInt16>) -> Bool {
            return theVal.withMemoryRebound(to: Int16.self, capacity: 1) { _AtomicCompareAndSwap16Barrier(Int16(bitPattern: old), Int16(bitPattern: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set UInt16 with barrier.
    public mutating func fetchStore(new: UInt16) -> UInt16 {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UInt16>) -> Int16 {
            return theVal.withMemoryRebound(to: Int16.self, capacity: 1) { _AtomicExchange16Barrier(Int16(bitPattern: new), $0) }
        }
        return UInt16(bitPattern: exchange(&self))
    }
}

extension UInt32 : SDAtomicType {
    
    /// Compare and set UInt32 with barrier.
    public mutating func compareSet(old: UInt32, new: UInt32) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UInt32>) -> Bool {
            return theVal.withMemoryRebound(to: Int32.self, capacity: 1) { _AtomicCompareAndSwap32Barrier(Int32(bitPattern: old), Int32(bitPattern: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set UInt32 with barrier.
    public mutating func fetchStore(new: UInt32) -> UInt32 {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UInt32>) -> Int32 {
            return theVal.withMemoryRebound(to: Int32.self, capacity: 1) { _AtomicExchange32Barrier(Int32(bitPattern: new), $0) }
        }
        return UInt32(bitPattern: exchange(&self))
    }
}

extension UInt64 : SDAtomicType {
    
    /// Compare and set UInt64 with barrier.
    public mutating func compareSet(old: UInt64, new: UInt64) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UInt64>) -> Bool {
            return theVal.withMemoryRebound(to: Int64.self, capacity: 1) { _AtomicCompareAndSwap64Barrier(Int64(bitPattern: old), Int64(bitPattern: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set UInt64 with barrier.
    public mutating func fetchStore(new: UInt64) -> UInt64 {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UInt64>) -> Int64 {
            return theVal.withMemoryRebound(to: Int64.self, capacity: 1) { _AtomicExchange64Barrier(Int64(bitPattern: new), $0) }
        }
        return UInt64(bitPattern: exchange(&self))
    }
}

extension UInt : SDAtomicType {
    
    /// Compare and set UInt with barrier.
    public mutating func compareSet(old: UInt, new: UInt) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UInt>) -> Bool {
            return theVal.withMemoryRebound(to: Int.self, capacity: 1) { _AtomicCompareAndSwapLongBarrier(Int(bitPattern: old), Int(bitPattern: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set UInt with barrier.
    public mutating func fetchStore(new: UInt) -> UInt {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UInt>) -> Int {
            return theVal.withMemoryRebound(to: Int.self, capacity: 1) { _AtomicExchangeLongBarrier(Int(bitPattern: new), $0) }
        }
        return UInt(bitPattern: exchange(&self))
    }
}

extension UnsafePointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafePointer, new: UnsafePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(mutating: old), UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(new: UnsafePointer) -> UnsafePointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return UnsafePointer(exchange(&self).assumingMemoryBound(to: Pointee.self))
    }
}

extension UnsafeMutablePointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeMutablePointer, new: UnsafeMutablePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(old), UnsafeMutableRawPointer(new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(new: UnsafeMutablePointer) -> UnsafeMutablePointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(new), $0) }
        }
        return exchange(&self).assumingMemoryBound(to: Pointee.self)
    }
}
extension UnsafeRawPointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeRawPointer, new: UnsafeRawPointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(mutating: old), UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(new: UnsafeRawPointer) -> UnsafeRawPointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return UnsafeRawPointer(exchange(&self))
    }
}

extension UnsafeMutableRawPointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeMutableRawPointer, new: UnsafeMutableRawPointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(old, new, $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(new: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(new, $0) }
        }
        return exchange(&self)
    }
}

extension OpaquePointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: OpaquePointer, new: OpaquePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<OpaquePointer>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(old), UnsafeMutableRawPointer(new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(new: OpaquePointer) -> OpaquePointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<OpaquePointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(new), $0) }
        }
        return OpaquePointer(exchange(&self))
    }
}

private class AtomicBase<Instance> {
    
    let value: Instance
    
    init(value: Instance) {
        self.value = value
    }
}

public struct Atomic<Instance> {
    
    fileprivate var base: AtomicBase<Instance>
    
    public init(value: Instance) {
        self.base = AtomicBase(value: value)
    }
    
    public var value : Instance {
        get {
            return base.value
        }
        set {
            base = AtomicBase(value: newValue)
        }
    }
}

extension Atomic : SDAtomicType {
    
    @_transparent
    fileprivate mutating func compareSet(old: AtomicBase<Instance>, new: AtomicBase<Instance>) -> Bool {
        let _old = Unmanaged.passUnretained(old)
        let _new = Unmanaged.passRetained(new)
        @_transparent
        func cas(theVal: UnsafeMutablePointer<AtomicBase<Instance>>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(_old.toOpaque(), _new.toOpaque(), $0) }
        }
        let result = cas(theVal: &base)
        if result {
            _old.release()
        } else {
            _new.release()
        }
        return result
    }
    
    /// Compare and set Object with barrier.
    public mutating func compareSet(old: Atomic, new: Atomic) -> Bool {
        return compareSet(old: old.base, new: new.base)
    }
}

extension Atomic {
    
    /// Sets the value, and returns the previous value.
    public mutating func fetchStore(new: Instance) -> Instance {
        return self.fetchStore { _ in new }
    }
    
    /// Sets the value.
    public mutating func fetchStore(block: (Instance) throws -> Instance) rethrows -> Instance {
        while true {
            let old = self.base
            if self.compareSet(old: old, new: AtomicBase(value: try block(old.value))) {
                return old.value
            }
        }
    }
}

extension Atomic: CustomStringConvertible {
    
    public var description: String {
        return "Atomic(\(value))"
    }
}

extension Atomic : Equatable, Hashable {
    
    @_transparent
    fileprivate var identifier: ObjectIdentifier {
        return ObjectIdentifier(base)
    }
    
    public var hashValue: Int {
        return identifier.hashValue
    }
}

public func == <Instance>(lhs: Atomic<Instance>, rhs: Atomic<Instance>) -> Bool {
    return lhs.identifier == rhs.identifier
}

public func == <Instance: Equatable>(lhs: Atomic<Instance>, rhs: Atomic<Instance>) -> Bool {
    return lhs.value == rhs.value
}

private let SDThreadDefaultDispatchQueue = DispatchQueue(label: "com.SusanDoggie.Thread", attributes: .concurrent)

// MARK: Lockable

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

// MARK: Spin Lock

public struct SDSpinLock {
    
    fileprivate var base: Bool
    
    public init() {
        base = false
    }
}

extension SDSpinLock {
    
    public mutating func lock() {
        while !trylock() {
            sched_yield()
        }
    }
    public mutating func unlock() {
        base = false
    }
    public mutating func trylock() -> Bool {
        return base.compareSet(old: false, new: true)
    }
}

extension SDSpinLock {
    
    @discardableResult
    public mutating func synchronized<R>(block: () throws -> R) rethrows -> R {
        self.lock()
        defer { self.unlock() }
        return try block()
    }
}

// MARK: Condition Lock

public class SDConditionLock : SDLock {
    
    fileprivate var _cond = pthread_cond_t()
    
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
    
    public func signal() {
        super.synchronized {
            pthread_cond_signal(&_cond)
        }
    }
    public func broadcast() {
        super.synchronized {
            pthread_cond_broadcast(&_cond)
        }
    }
    public func wait(for predicate: @autoclosure () -> Bool) {
        while !predicate() {
            pthread_cond_wait(&_cond, &_mtx)
        }
    }
    @discardableResult
    public func wait(for predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        var _timespec = date.timespec
        while !predicate() {
            if pthread_cond_timedwait(&_cond, &_mtx, &_timespec) != 0 {
                return predicate()
            }
        }
        return true
    }
}

extension SDConditionLock {
    
    public func lock(for predicate: @autoclosure () -> Bool) {
        super.lock()
        self.wait(for: predicate)
    }
    @discardableResult
    public func lock(for predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        super.lock()
        if self.wait(for: predicate, until: date) {
            return true
        }
        super.unlock()
        return false
    }
    @discardableResult
    public func trylock(for predicate: @autoclosure () -> Bool) -> Bool {
        if super.trylock() {
            if self.wait(for: predicate, until: Date.distantPast) {
                return true
            }
            super.unlock()
        }
        return false
    }
}

extension SDConditionLock {
    
    @discardableResult
    public func synchronized<R>(for predicate: @autoclosure () -> Bool, block: () throws -> R) rethrows -> R {
        self.lock(for: predicate)
        defer { self.unlock() }
        return try block()
    }
    @discardableResult
    public func synchronized<R>(for predicate: @autoclosure () -> Bool, until date: Date, block: () throws -> R) rethrows -> R? {
        if self.lock(for: predicate, until: date) {
            defer { self.unlock() }
            return try block()
        }
        return nil
    }
}

// MARK: SDAtomic

open class SDAtomic {
    
    fileprivate let queue: DispatchQueue
    fileprivate let block: (SDAtomic) -> Void
    fileprivate var flag: Int32
    
    public init(queue: DispatchQueue, block: @escaping (SDAtomic) -> Void) {
        self.queue = queue
        self.block = block
        self.flag = 0
    }
    public init(block: @escaping (SDAtomic) -> Void) {
        self.queue = SDThreadDefaultDispatchQueue
        self.block = block
        self.flag = 0
    }
}

extension SDAtomic {
    
    public func signal() {
        if flag.fetchStore(new: 2) == 0 {
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
    
    fileprivate var _value: Instance?
    fileprivate var spinlck: SDSpinLock = SDSpinLock()
    fileprivate let block: () -> Instance
    
    /// Create a SDSingleton.
    public init(block: @escaping () -> Instance) {
        self.block = block
    }
}

extension SDSingleton {
    
    public func signal() {
        if !isValue {
            synchronized(self) {
                let result = self._value ?? self.block()
                self.spinlck.synchronized { self._value = result }
            }
        }
    }
    
    public var isValue : Bool {
        return spinlck.synchronized { self._value != nil }
    }
    
    public var value: Instance {
        self.signal()
        return self._value!
    }
}

// MARK: SDTask

public class SDTask<Result> : SDAtomic {
    
    fileprivate var _notify: [(Result) -> Void] = []
    
    fileprivate var spinlck = SDSpinLock()
    fileprivate let condition = SDConditionLock()
    
    fileprivate var _result: Result?
    
    fileprivate init(queue: DispatchQueue, suspend: ((Result) -> Bool)?, block: @escaping () -> Result) {
        super.init(queue: queue, block: SDTask.createBlock(suspend, block))
    }
    
    /// Create a SDTask and compute block with specific queue.
    public init(queue: DispatchQueue, block: @escaping () -> Result) {
        super.init(queue: queue, block: SDTask.createBlock(nil, block))
        self.signal()
    }
    
    /// Create a SDTask and compute block with default queue.
    public init(block: @escaping () -> Result) {
        super.init(block: SDTask.createBlock(nil, block))
        self.signal()
    }
}

private extension SDTask {
    
    @_transparent
    static func createBlock(_ suspend: ((Result) -> Bool)?, _ block: @escaping () -> Result) -> (SDAtomic) -> Void {
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
    func _apply<R>(_ queue: DispatchQueue, suspend: ((R) -> Bool)?, block: @escaping (Result) -> R) -> SDTask<R> {
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
    public var completed: Bool {
        return spinlck.synchronized { _result != nil }
    }
    
    /// Result of task.
    public var result: Result {
        if self.completed {
            return self._result!
        }
        return condition.synchronized(for: self.completed) { self._result! }
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

/// Create a SDTask and compute block with default queue.
@discardableResult
public func async<Result>(block: @escaping () -> Result) -> SDTask<Result> {
    return SDTask(block: block)
}

/// Create a SDTask and compute block with specific queue.
@discardableResult
public func async<Result>(queue: DispatchQueue, _ block: @escaping () -> Result) -> SDTask<Result> {
    return SDTask(queue: queue, block: block)
}
