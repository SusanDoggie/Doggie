//
//  Atomic.swift
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

public protocol SDAtomicProtocol {
    
    associatedtype Atom
    
    mutating func isLockFree() -> Bool
    
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

extension SDAtomicProtocol {
    
    /// Atomic fetch the current value.
    @_transparent
    public mutating func fetch() -> Atom {
        return self.fetchSelf().value
    }
    
    /// Atomic set the value.
    @_transparent
    public mutating func store(_ new: Atom) {
        self.fetchStore { _ in new }
    }
    
    /// Set the value, and returns the previous value.
    @_transparent
    public mutating func fetchStore(_ new: Atom) -> Atom {
        return self.fetchStore { _ in new }
    }
    
    /// Set the value, and returns the previous value. `block` is called repeatedly until result accepted.
    @_transparent
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

extension SDAtomicProtocol where Atom : Equatable {
    
    /// Compare and set the value.
    @_transparent
    public mutating func compareSet(old: Atom, new: Atom) -> Bool {
        let (current, value) = self.fetchSelf()
        return value == old && self.compareSet(old: current, new: new)
    }
}

extension Bool : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _AtomicBoolIsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: Bool, value: Bool) {
        let val = _AtomicLoadBoolBarrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: Bool) {
        _AtomicStoreBoolBarrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    @_transparent
    public mutating func compareSet(old: Bool, new: Bool) -> Bool {
        return _AtomicCompareAndSwapBoolBarrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: Bool) -> Bool {
        return _AtomicExchangeBoolBarrier(new, &self)
    }
}

extension Int8 : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _Atomic8IsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: Int8, value: Int8) {
        let val = _AtomicLoad8Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: Int8) {
        _AtomicStore8Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    @_transparent
    public mutating func compareSet(old: Int8, new: Int8) -> Bool {
        return _AtomicCompareAndSwap8Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: Int8) -> Int8 {
        return _AtomicExchange8Barrier(new, &self)
    }
    
    @_transparent
    @discardableResult
    public mutating func fetchAdd(_ value: Int8) -> Int8 {
        return _AtomicFetchAdd8Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchSub(_ value: Int8) -> Int8 {
        return _AtomicFetchSub8Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchAnd(_ value: Int8) -> Int8 {
        return _AtomicFetchAnd8Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchXor(_ value: Int8) -> Int8 {
        return _AtomicFetchXor8Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchOr(_ value: Int8) -> Int8 {
        return _AtomicFetchOr8Barrier(value, &self)
    }
}

extension Int16 : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _Atomic16IsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: Int16, value: Int16) {
        let val = _AtomicLoad16Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: Int16) {
        _AtomicStore16Barrier(new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func compareSet(old: Int16, new: Int16) -> Bool {
        return _AtomicCompareAndSwap16Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: Int16) -> Int16 {
        return _AtomicExchange16Barrier(new, &self)
    }
    
    @_transparent
    @discardableResult
    public mutating func fetchAdd(_ value: Int16) -> Int16 {
        return _AtomicFetchAdd16Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchSub(_ value: Int16) -> Int16 {
        return _AtomicFetchSub16Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchAnd(_ value: Int16) -> Int16 {
        return _AtomicFetchAnd16Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchXor(_ value: Int16) -> Int16 {
        return _AtomicFetchXor16Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchOr(_ value: Int16) -> Int16 {
        return _AtomicFetchOr16Barrier(value, &self)
    }
}

extension Int32 : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _Atomic32IsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: Int32, value: Int32) {
        let val = _AtomicLoad32Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: Int32) {
        _AtomicStore32Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    @_transparent
    public mutating func compareSet(old: Int32, new: Int32) -> Bool {
        return _AtomicCompareAndSwap32Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: Int32) -> Int32 {
        return _AtomicExchange32Barrier(new, &self)
    }
    
    @_transparent
    @discardableResult
    public mutating func fetchAdd(_ value: Int32) -> Int32 {
        return _AtomicFetchAdd32Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchSub(_ value: Int32) -> Int32 {
        return _AtomicFetchSub32Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchAnd(_ value: Int32) -> Int32 {
        return _AtomicFetchAnd32Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchXor(_ value: Int32) -> Int32 {
        return _AtomicFetchXor32Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchOr(_ value: Int32) -> Int32 {
        return _AtomicFetchOr32Barrier(value, &self)
    }
}

extension Int64 : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _Atomic64IsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: Int64, value: Int64) {
        let val = _AtomicLoad64Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: Int64) {
        _AtomicStore64Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    @_transparent
    public mutating func compareSet(old: Int64, new: Int64) -> Bool {
        return _AtomicCompareAndSwap64Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: Int64) -> Int64 {
        return _AtomicExchange64Barrier(new, &self)
    }
    
    @_transparent
    @discardableResult
    public mutating func fetchAdd(_ value: Int64) -> Int64 {
        return _AtomicFetchAdd64Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchSub(_ value: Int64) -> Int64 {
        return _AtomicFetchSub64Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchAnd(_ value: Int64) -> Int64 {
        return _AtomicFetchAnd64Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchXor(_ value: Int64) -> Int64 {
        return _AtomicFetchXor64Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchOr(_ value: Int64) -> Int64 {
        return _AtomicFetchOr64Barrier(value, &self)
    }
}

extension Int : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _AtomicLongIsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: Int, value: Int) {
        let val = _AtomicLoadLongBarrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: Int) {
        _AtomicStoreLongBarrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    @_transparent
    public mutating func compareSet(old: Int, new: Int) -> Bool {
        return _AtomicCompareAndSwapLongBarrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: Int) -> Int {
        return _AtomicExchangeLongBarrier(new, &self)
    }
    
    @_transparent
    @discardableResult
    public mutating func fetchAdd(_ value: Int) -> Int {
        return _AtomicFetchAddLongBarrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchSub(_ value: Int) -> Int {
        return _AtomicFetchSubLongBarrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchAnd(_ value: Int) -> Int {
        return _AtomicFetchAndLongBarrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchXor(_ value: Int) -> Int {
        return _AtomicFetchXorLongBarrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchOr(_ value: Int) -> Int {
        return _AtomicFetchOrLongBarrier(value, &self)
    }
}

extension UInt8 : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _AtomicU8IsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: UInt8, value: UInt8) {
        let val = _AtomicLoadU8Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: UInt8) {
        _AtomicStoreU8Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    @_transparent
    public mutating func compareSet(old: UInt8, new: UInt8) -> Bool {
        return _AtomicCompareAndSwapU8Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: UInt8) -> UInt8 {
        return _AtomicExchangeU8Barrier(new, &self)
    }
    
    @_transparent
    @discardableResult
    public mutating func fetchAdd(_ value: UInt8) -> UInt8 {
        return _AtomicFetchAddU8Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchSub(_ value: UInt8) -> UInt8 {
        return _AtomicFetchSubU8Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchAnd(_ value: UInt8) -> UInt8 {
        return _AtomicFetchAndU8Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchXor(_ value: UInt8) -> UInt8 {
        return _AtomicFetchXorU8Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchOr(_ value: UInt8) -> UInt8 {
        return _AtomicFetchOrU8Barrier(value, &self)
    }
}

extension UInt16 : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _AtomicU16IsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: UInt16, value: UInt16) {
        let val = _AtomicLoadU16Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: UInt16) {
        _AtomicStoreU16Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    @_transparent
    public mutating func compareSet(old: UInt16, new: UInt16) -> Bool {
        return _AtomicCompareAndSwapU16Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: UInt16) -> UInt16 {
        return _AtomicExchangeU16Barrier(new, &self)
    }
    
    @_transparent
    @discardableResult
    public mutating func fetchAdd(_ value: UInt16) -> UInt16 {
        return _AtomicFetchAddU16Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchSub(_ value: UInt16) -> UInt16 {
        return _AtomicFetchSubU16Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchAnd(_ value: UInt16) -> UInt16 {
        return _AtomicFetchAndU16Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchXor(_ value: UInt16) -> UInt16 {
        return _AtomicFetchXorU16Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchOr(_ value: UInt16) -> UInt16 {
        return _AtomicFetchOrU16Barrier(value, &self)
    }
}

extension UInt32 : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _AtomicU32IsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: UInt32, value: UInt32) {
        let val = _AtomicLoadU32Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: UInt32) {
        _AtomicStoreU32Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    @_transparent
    public mutating func compareSet(old: UInt32, new: UInt32) -> Bool {
        return _AtomicCompareAndSwapU32Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: UInt32) -> UInt32 {
        return _AtomicExchangeU32Barrier(new, &self)
    }
    
    @_transparent
    @discardableResult
    public mutating func fetchAdd(_ value: UInt32) -> UInt32 {
        return _AtomicFetchAddU32Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchSub(_ value: UInt32) -> UInt32 {
        return _AtomicFetchSubU32Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchAnd(_ value: UInt32) -> UInt32 {
        return _AtomicFetchAndU32Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchXor(_ value: UInt32) -> UInt32 {
        return _AtomicFetchXorU32Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchOr(_ value: UInt32) -> UInt32 {
        return _AtomicFetchOrU32Barrier(value, &self)
    }
}

extension UInt64 : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _AtomicU64IsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: UInt64, value: UInt64) {
        let val = _AtomicLoadU64Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: UInt64) {
        _AtomicStoreU64Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    @_transparent
    public mutating func compareSet(old: UInt64, new: UInt64) -> Bool {
        return _AtomicCompareAndSwapU64Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: UInt64) -> UInt64 {
        return _AtomicExchangeU64Barrier(new, &self)
    }
    
    @_transparent
    @discardableResult
    public mutating func fetchAdd(_ value: UInt64) -> UInt64 {
        return _AtomicFetchAddU64Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchSub(_ value: UInt64) -> UInt64 {
        return _AtomicFetchSubU64Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchAnd(_ value: UInt64) -> UInt64 {
        return _AtomicFetchAndU64Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchXor(_ value: UInt64) -> UInt64 {
        return _AtomicFetchXorU64Barrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchOr(_ value: UInt64) -> UInt64 {
        return _AtomicFetchOrU64Barrier(value, &self)
    }
}

extension UInt : SDAtomicProtocol {
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return _AtomicULongIsLockFree(&self)
    }
    
    /// Atomic fetch the current value with barrier.
    @_transparent
    public mutating func fetchSelf() -> (current: UInt, value: UInt) {
        let val = _AtomicLoadULongBarrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    @_transparent
    public mutating func store(_ new: UInt) {
        _AtomicStoreULongBarrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    @_transparent
    public mutating func compareSet(old: UInt, new: UInt) -> Bool {
        return _AtomicCompareAndSwapULongBarrier(old, new, &self)
    }
    
    /// Set value with barrier.
    @_transparent
    public mutating func fetchStore(_ new: UInt) -> UInt {
        return _AtomicExchangeULongBarrier(new, &self)
    }
    
    @_transparent
    @discardableResult
    public mutating func fetchAdd(_ value: UInt) -> UInt {
        return _AtomicFetchAddULongBarrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchSub(_ value: UInt) -> UInt {
        return _AtomicFetchSubULongBarrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchAnd(_ value: UInt) -> UInt {
        return _AtomicFetchAndULongBarrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchXor(_ value: UInt) -> UInt {
        return _AtomicFetchXorULongBarrier(value, &self)
    }
    @_transparent
    @discardableResult
    public mutating func fetchOr(_ value: UInt) -> UInt {
        return _AtomicFetchOrULongBarrier(value, &self)
    }
}

@_fixed_layout
public struct Atomic<Instance> {
    
    @usableFromInline
    var base: Base
    
    @_transparent
    @usableFromInline
    init(base: Base) {
        self.base = base
    }
    
    @_transparent
    public init(value: Instance) {
        self.base = Base(value: value)
    }
    
    @_transparent
    public var value : Instance {
        get {
            return self.base.value
        }
        set {
            self.store(newValue)
        }
    }
}

extension Atomic {
    
    @_fixed_layout
    @usableFromInline
    class Base {
        
        @usableFromInline
        var value: Instance
        
        @usableFromInline
        init(value: Instance) {
            self.value = value
        }
    }
}

extension Atomic : SDAtomicProtocol {
    
    @_transparent
    @usableFromInline
    mutating func withBasePointer<Result, Raw>(_ body: (UnsafeMutablePointer<Raw>) -> Result) -> Result {
        return withUnsafeMutablePointer(to: &base) { $0.withMemoryRebound(to: Raw.self, capacity: 1) { body($0) } }
    }
    
    @_transparent
    public mutating func isLockFree() -> Bool {
        return withBasePointer { _AtomicPtrIsLockFree($0) }
    }
    
    /// Atomic fetch the current value.
    @_transparent
    public mutating func fetchSelf() -> (current: Atomic, value: Instance) {
        let _base = self.base
        return (Atomic(base: _base), _base.value)
    }
    
    /// Atomic set the value.
    @_transparent
    public mutating func store(_ new: Instance) {
        self.base = Base(value: new)
    }
    
    /// Compare and set the value.
    @_transparent
    public mutating func compareSet(old: Atomic, new: Instance) -> Bool {
        let _old = Unmanaged.passUnretained(old.base)
        let _new = Unmanaged.passRetained(Base(value: new))
        let result = withBasePointer { _AtomicCompareAndSwapPtrBarrier(_old.toOpaque(), _new.toOpaque(), $0) }
        if result {
            _old.release()
        } else {
            _new.release()
        }
        return result
    }
    
    @_transparent
    @usableFromInline
    mutating func _compareSetWeak(old: Base, new: Base) -> Bool {
        let _old = Unmanaged.passUnretained(old)
        let _new = Unmanaged.passRetained(new)
        let result = withBasePointer { _AtomicCompareAndSwapWeakPtrBarrier(_old.toOpaque(), _new.toOpaque(), $0) }
        if result {
            _old.release()
        } else {
            _new.release()
        }
        return result
    }
    
    /// Set the value.
    @_transparent
    @discardableResult
    public mutating func fetchStore(block: (Instance) throws -> Instance) rethrows -> Instance {
        let new = Base(value: base.value)
        while true {
            let _base = self.base
            new.value = try block(_base.value)
            if self._compareSetWeak(old: _base, new: new) {
                return _base.value
            }
        }
    }
}

extension Atomic: CustomStringConvertible {
    
    @_transparent
    public var description: String {
        return "Atomic(\(base.value))"
    }
}
