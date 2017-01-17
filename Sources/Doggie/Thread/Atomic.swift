//
//  Atomic.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

import c11_atomic

public protocol SDAtomicProtocol {
    
    associatedtype Atom
    
    /// Atomic fetch the current value.
    mutating func fetchSelf() -> (current: Self, value: Atom)
    
    /// Compare and set the value.
    mutating func compareSet(old: Self, new: Atom) -> Bool
    
    /// Atomic fetch the current value.
    mutating func fetch() -> Atom
    
    /// Atomic set the value.
    mutating func store(_ new: Atom)
    
    /// Set the value, and returns the previous value.
    mutating func fetchStore(_ new: Atom) -> Atom
    
    /// Set the value, and returns the previous value. `block` is called repeatedly until result accepted.
    @discardableResult
    mutating func fetchStore(block: (Atom) throws -> Atom) rethrows -> Atom
}

public extension SDAtomicProtocol {
    
    /// Atomic fetch the current value.
    public mutating func fetch() -> Atom {
        return self.fetchSelf().value
    }
    
    /// Atomic set the value.
    public mutating func store(_ new: Atom) {
        self.fetchStore { _ in new }
    }
    
    /// Set the value, and returns the previous value.
    public mutating func fetchStore(_ new: Atom) -> Atom {
        return self.fetchStore { _ in new }
    }
    
    /// Set the value, and returns the previous value. `block` is called repeatedly until result accepted.
    @discardableResult
    public mutating func fetchStore(block: (Atom) throws -> Atom) rethrows -> Atom {
        while true {
            let (old, oldVal) = self.fetchSelf()
            if self.compareSet(old: old, new: try block(oldVal)) {
                return oldVal
            }
        }
    }
}

extension Bool : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Bool, value: Bool) {
        let val = _AtomicLoadBoolBarrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Bool) {
        _AtomicStoreBoolBarrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: Bool, new: Bool) -> Bool {
        return _AtomicCompareAndSwapBoolBarrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Bool) -> Bool {
        return _AtomicExchangeBoolBarrier(new, &self)
    }
}

extension Int8 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Int8, value: Int8) {
        let val = _AtomicLoad8Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Int8) {
        _AtomicStore8Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: Int8, new: Int8) -> Bool {
        return _AtomicCompareAndSwap8Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Int8) -> Int8 {
        return _AtomicExchange8Barrier(new, &self)
    }
}

extension Int16 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Int16, value: Int16) {
        let val = _AtomicLoad16Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Int16) {
        _AtomicStore16Barrier(new, &self)
    }
    
    /// Set value with barrier.
    public mutating func compareSet(old: Int16, new: Int16) -> Bool {
        return _AtomicCompareAndSwap16Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Int16) -> Int16 {
        return _AtomicExchange16Barrier(new, &self)
    }
}

extension Int32 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Int32, value: Int32) {
        let val = _AtomicLoad32Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Int32) {
        _AtomicStore32Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: Int32, new: Int32) -> Bool {
        return _AtomicCompareAndSwap32Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Int32) -> Int32 {
        return _AtomicExchange32Barrier(new, &self)
    }
}

extension Int64 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Int64, value: Int64) {
        let val = _AtomicLoad64Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Int64) {
        _AtomicStore64Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: Int64, new: Int64) -> Bool {
        return _AtomicCompareAndSwap64Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Int64) -> Int64 {
        return _AtomicExchange64Barrier(new, &self)
    }
}

extension Int : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Int, value: Int) {
        let val = _AtomicLoadLongBarrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Int) {
        _AtomicStoreLongBarrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: Int, new: Int) -> Bool {
        return _AtomicCompareAndSwapLongBarrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Int) -> Int {
        return _AtomicExchangeLongBarrier(new, &self)
    }
}

extension UInt8 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UInt8, value: UInt8) {
        let val = _AtomicLoadU8Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UInt8) {
        _AtomicStoreU8Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: UInt8, new: UInt8) -> Bool {
        return _AtomicCompareAndSwapU8Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: UInt8) -> UInt8 {
        return _AtomicExchangeU8Barrier(new, &self)
    }
}

extension UInt16 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UInt16, value: UInt16) {
        let val = _AtomicLoadU16Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UInt16) {
        _AtomicStoreU16Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: UInt16, new: UInt16) -> Bool {
        return _AtomicCompareAndSwapU16Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: UInt16) -> UInt16 {
        return _AtomicExchangeU16Barrier(new, &self)
    }
}

extension UInt32 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UInt32, value: UInt32) {
        let val = _AtomicLoadU32Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UInt32) {
        _AtomicStoreU32Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: UInt32, new: UInt32) -> Bool {
        return _AtomicCompareAndSwapU32Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: UInt32) -> UInt32 {
        return _AtomicExchangeU32Barrier(new, &self)
    }
}

extension UInt64 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UInt64, value: UInt64) {
        let val = _AtomicLoadU64Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UInt64) {
        _AtomicStoreU64Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: UInt64, new: UInt64) -> Bool {
        return _AtomicCompareAndSwapU64Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: UInt64) -> UInt64 {
        return _AtomicExchangeU64Barrier(new, &self)
    }
}

extension UInt : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UInt, value: UInt) {
        let val = _AtomicLoadULongBarrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UInt) {
        _AtomicStoreULongBarrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: UInt, new: UInt) -> Bool {
        return _AtomicCompareAndSwapULongBarrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: UInt) -> UInt {
        return _AtomicExchangeULongBarrier(new, &self)
    }
}

extension UnsafePointer : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UnsafePointer, value: UnsafePointer) {
        @_transparent
        func load(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let val = UnsafePointer(load(&self).assumingMemoryBound(to: Pointee.self))
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UnsafePointer) {
        @_transparent
        func store(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) {
            theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicStorePtrBarrier(UnsafeMutableRawPointer(mutating: new), $0) }
        }
        store(&self)
    }
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafePointer, new: UnsafePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(mutating: old), UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(_ new: UnsafePointer) -> UnsafePointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return UnsafePointer(exchange(&self).assumingMemoryBound(to: Pointee.self))
    }
}

extension UnsafeMutablePointer : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UnsafeMutablePointer, value: UnsafeMutablePointer) {
        @_transparent
        func load(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let val = load(&self).assumingMemoryBound(to: Pointee.self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UnsafeMutablePointer) {
        @_transparent
        func store(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) {
            theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicStorePtrBarrier(UnsafeMutableRawPointer(new), $0) }
        }
        store(&self)
    }
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeMutablePointer, new: UnsafeMutablePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(old), UnsafeMutableRawPointer(new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(_ new: UnsafeMutablePointer) -> UnsafeMutablePointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(new), $0) }
        }
        return exchange(&self).assumingMemoryBound(to: Pointee.self)
    }
}
extension UnsafeRawPointer : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UnsafeRawPointer, value: UnsafeRawPointer) {
        @_transparent
        func load(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let val = UnsafeRawPointer(load(&self))
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UnsafeRawPointer) {
        @_transparent
        func store(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) {
            theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicStorePtrBarrier(UnsafeMutableRawPointer(mutating: new), $0) }
        }
        store(&self)
    }
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeRawPointer, new: UnsafeRawPointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(mutating: old), UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(_ new: UnsafeRawPointer) -> UnsafeRawPointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return UnsafeRawPointer(exchange(&self))
    }
}

extension UnsafeMutableRawPointer : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UnsafeMutableRawPointer, value: UnsafeMutableRawPointer) {
        @_transparent
        func load(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let val = load(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UnsafeMutableRawPointer) {
        @_transparent
        func store(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) {
            theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicStorePtrBarrier(new, $0) }
        }
        store(&self)
    }
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeMutableRawPointer, new: UnsafeMutableRawPointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(old, new, $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(_ new: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(new, $0) }
        }
        return exchange(&self)
    }
}

extension OpaquePointer : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: OpaquePointer, value: OpaquePointer) {
        @_transparent
        func load(_ theVal: UnsafeMutablePointer<OpaquePointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let val = OpaquePointer(load(&self))
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: OpaquePointer) {
        @_transparent
        func store(_ theVal: UnsafeMutablePointer<OpaquePointer>) {
            theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicStorePtrBarrier(UnsafeMutableRawPointer(new), $0) }
        }
        store(&self)
    }
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: OpaquePointer, new: OpaquePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<OpaquePointer>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(old), UnsafeMutableRawPointer(new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(_ new: OpaquePointer) -> OpaquePointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<OpaquePointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(new), $0) }
        }
        return OpaquePointer(exchange(&self))
    }
}

private class AtomicBase<Instance> {
    
    var value: Instance!
    
    init(value: Instance! = nil) {
        self.value = value
    }
}

public struct Atomic<Instance> {
    
    fileprivate var base: AtomicBase<Instance>
    
    fileprivate init(base: AtomicBase<Instance>) {
        self.base = base
    }
    
    public init(value: Instance) {
        self.base = AtomicBase(value: value)
    }
    
    public var value : Instance {
        get {
            return base.value
        }
        set {
            _fetchStore(AtomicBase(value: newValue))
        }
    }
}

extension Atomic {
    
    @_transparent
    fileprivate mutating func _fetch() -> AtomicBase<Instance> {
        @_transparent
        func load(theVal: UnsafeMutablePointer<AtomicBase<Instance>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let _old = Unmanaged<AtomicBase<Instance>>.fromOpaque(UnsafeRawPointer(load(theVal: &base)))
        return _old.takeUnretainedValue()
    }
    
    @_transparent
    fileprivate mutating func _compareSet(old: AtomicBase<Instance>, new: AtomicBase<Instance>) -> Bool {
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
    
    @_transparent
    @discardableResult
    fileprivate mutating func _fetchStore(_ new: AtomicBase<Instance>) -> AtomicBase<Instance> {
        let _new = Unmanaged.passRetained(new)
        @_transparent
        func exchange(theVal: UnsafeMutablePointer<AtomicBase<Instance>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(_new.toOpaque(), $0) }
        }
        let _old = Unmanaged<AtomicBase<Instance>>.fromOpaque(UnsafeRawPointer(exchange(theVal: &base)))
        return _old.takeRetainedValue()
    }
}

extension Atomic : SDAtomicProtocol {
    
    /// Atomic fetch the current value.
    public mutating func fetchSelf() -> (current: Atomic, value: Instance) {
        let _base = _fetch()
        return (Atomic(base: _base), _base.value)
    }
    
    /// Compare and set the value.
    public mutating func compareSet(old: Atomic, new: Instance) -> Bool {
        return self._compareSet(old: old.base, new: AtomicBase(value: new))
    }
    
    /// Set the value, and returns the previous value.
    public mutating func fetchStore(_ new: Instance) -> Instance {
        return _fetchStore(AtomicBase(value: new)).value
    }
    
    /// Set the value.
    @discardableResult
    public mutating func fetchStore(block: (Instance) throws -> Instance) rethrows -> Instance {
        let new = AtomicBase<Instance>()
        while true {
            let old = self.base
            new.value = try block(old.value)
            if self._compareSet(old: old, new: new) {
                return old.value
            }
        }
    }
}

extension Atomic where Instance : Equatable {
    
    /// Compare and set the value.
    public mutating func compareSet(old: Instance, new: Instance) -> Bool {
        while true {
            let (current, currentVal) = self.fetchSelf()
            if currentVal != old {
                return false
            }
            if compareSet(old: current, new: new) {
                return true
            }
        }
    }
}

extension Atomic: CustomStringConvertible {
    
    public var description: String {
        return "Atomic(\(base.value))"
    }
}
