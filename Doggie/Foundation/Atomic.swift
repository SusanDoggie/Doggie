//
//  Atomic.swift
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

public protocol SDAtomicType {
    
    /// Sets the value.
    mutating func compareSet(oldVal: Self, _ newVal: Self) -> Bool
    
    /// Sets the value, and returns the previous value.
    mutating func fetchStore(newVal: Self) -> Self
}

public extension SDAtomicType {
    
    /// Sets the value.
    @_transparent
    public mutating func setValue(@noescape block: (Self) throws -> Self) rethrows -> Self {
        while true {
            let oldVal = self
            if self.compareSet(oldVal, try block(oldVal)) {
                return oldVal
            }
        }
    }
    /// Sets the value, and returns the previous value.
    @_transparent
    public mutating func fetchStore(value: Self) -> Self {
        return self.setValue { _ in value }
    }
}

extension Int32 : SDAtomicType {
    
    /// Compare and set Int32 with barrier.
    @_transparent
    public mutating func compareSet(oldVal: Int32, _ newVal: Int32) -> Bool {
        return OSAtomicCompareAndSwap32Barrier(oldVal, newVal, &self)
    }
}

extension Int64 : SDAtomicType {
    
    /// Compare and set Int64 with barrier.
    @_transparent
    public mutating func compareSet(oldVal: Int64, _ newVal: Int64) -> Bool {
        return OSAtomicCompareAndSwap64Barrier(oldVal, newVal, &self)
    }
}

extension Int : SDAtomicType {
    
    /// Compare and set Int with barrier.
    @_transparent
    public mutating func compareSet(oldVal: Int, _ newVal: Int) -> Bool {
        return OSAtomicCompareAndSwapLongBarrier(oldVal, newVal, &self)
    }
}

extension UInt32 : SDAtomicType {
    
    /// Compare and set UInt32 with barrier.
    @_transparent
    public mutating func compareSet(oldVal: UInt32, _ newVal: UInt32) -> Bool {
        @inline(__always)
        func cas(theVal: UnsafeMutablePointer<UInt32>) -> Bool {
            return OSAtomicCompareAndSwap32Barrier(Int32(bitPattern: oldVal), Int32(bitPattern: newVal), UnsafeMutablePointer(theVal))
        }
        return cas(&self)
    }
}

extension UInt64 : SDAtomicType {
    
    /// Compare and set UInt64 with barrier.
    @_transparent
    public mutating func compareSet(oldVal: UInt64, _ newVal: UInt64) -> Bool {
        @inline(__always)
        func cas(theVal: UnsafeMutablePointer<UInt64>) -> Bool {
            return OSAtomicCompareAndSwap64Barrier(Int64(bitPattern: oldVal), Int64(bitPattern: newVal), UnsafeMutablePointer(theVal))
        }
        return cas(&self)
    }
}

extension UInt : SDAtomicType {
    
    /// Compare and set UInt with barrier.
    @_transparent
    public mutating func compareSet(oldVal: UInt, _ newVal: UInt) -> Bool {
        @inline(__always)
        func cas(theVal: UnsafeMutablePointer<UInt>) -> Bool {
            return OSAtomicCompareAndSwapLongBarrier(Int(bitPattern: oldVal), Int(bitPattern: newVal), UnsafeMutablePointer(theVal))
        }
        return cas(&self)
    }
}

extension UnsafeMutablePointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    @_transparent
    public mutating func compareSet(oldVal: UnsafeMutablePointer, _ newVal: UnsafeMutablePointer) -> Bool {
        @inline(__always)
        func cas(theVal: UnsafeMutablePointer<UnsafeMutablePointer<Memory>>) -> Bool {
            return OSAtomicCompareAndSwapPtrBarrier(oldVal, newVal, UnsafeMutablePointer<UnsafeMutablePointer<Void>>(theVal))
        }
        return cas(&self)
    }
}

public struct AtomicBoolean {
    
    private var val: Int32
    
    public init() {
        self.init(false)
    }
}

extension AtomicBoolean : BooleanLiteralConvertible {
    
    @_transparent
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension AtomicBoolean : BooleanType {
    
    /// Returns the current value of the boolean.
    @_transparent
    public var boolValue: Bool {
        return val != 0
    }
    /// Construct an instance representing the same logical value as
    /// `value`.
    @_transparent
    public init<T : BooleanType>(_ value: T) {
        self.val = value ? 0x80 : 0
    }
}

extension AtomicBoolean : SDAtomicType {
    
    /// Sets the value, and returns the previous value.
    @_transparent
    public mutating func fetchStore<T: BooleanType>(value: T) -> Bool {
        return value ? OSAtomicTestAndSet(0, &val) : OSAtomicTestAndClear(0, &val)
    }
    
    /// Compare and set Bool with barrier.
    @_transparent
    public mutating func compareSet<T: BooleanType>(oldVal: T, _ newVal: T) -> Bool {
        return self.val.compareSet(oldVal ? 0x80 : 0, newVal ? 0x80 : 0)
    }
}

extension AtomicBoolean: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        return self ? "true" : "false"
    }
    
    public var debugDescription: String {
        return self ? "true" : "false"
    }
}

extension AtomicBoolean : Equatable, Hashable {
    /// The hash value.
    ///
    /// **Axiom:** `x == y` implies `x.hashValue == y.hashValue`.
    ///
    /// - Note: the hash value is not guaranteed to be stable across
    ///   different invocations of the same program.  Do not persist the
    ///   hash value across program runs.
    @_transparent
    public var hashValue: Int {
        return boolValue.hashValue
    }
}

public func == (lhs: AtomicBoolean, rhs: AtomicBoolean) -> Bool {
    return lhs.boolValue == rhs.boolValue
}

private final class AtomicBase<Instance> {
    
    var value: Instance
    
    init(value: Instance) {
        self.value = value
    }
}

public final class Atomic<Instance> {
    
    private var base: AtomicBase<Instance>
    
    private init(base: AtomicBase<Instance>) {
        self.base = base
    }
    public init(value: Instance) {
        self.base = AtomicBase(value: value)
    }
    
    public var value : Instance {
        return base.value
    }
}

extension Atomic {
    
    @_transparent
    private func compareSet(oldVal: AtomicBase<Instance>, _ newVal: AtomicBase<Instance>) -> Bool {
        let _oldVal = Unmanaged.passUnretained(oldVal)
        let _newVal = Unmanaged.passRetained(newVal)
        @inline(__always)
        func cas(theVal: UnsafeMutablePointer<AtomicBase<Instance>>) -> Bool {
            return OSAtomicCompareAndSwapPtrBarrier(UnsafeMutablePointer(_oldVal.toOpaque()), UnsafeMutablePointer(_newVal.toOpaque()), UnsafeMutablePointer<UnsafeMutablePointer<Void>>(theVal))
        }
        let result = cas(&base)
        if result {
            _oldVal.release()
        } else {
            _newVal.release()
        }
        return result
    }
    
    /// Compare and set Object with barrier.
    @_transparent
    public func compareSet(oldVal: Atomic, _ newVal: Atomic) -> Bool {
        return compareSet(oldVal.base, newVal.base)
    }
}

extension Atomic {
    
    /// Sets the value.
    @_transparent
    public func setValue(@noescape block: (Instance) throws -> Instance) rethrows -> Instance {
        while true {
            let oldVal = self.base
            if self.compareSet(oldVal, AtomicBase(value: try block(oldVal.value))) {
                return oldVal.value
            }
        }
    }
    
    /// Sets the value, and returns the previous value.
    @_transparent
    public func fetchStore(value: Instance) -> Instance {
        return self.setValue { _ in value }
    }
}

extension Atomic: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        return "Atomic(\(value))"
    }
    
    public var debugDescription: String {
        return "Atomic(\(value))"
    }
}

public extension Int32 {
    
    @_transparent
    mutating func atomicAdd(amount: Int32) -> Int32 {
        return OSAtomicAdd32Barrier(amount, &self) - amount
    }
    
    @_transparent
    mutating func atomicSub(amount: Int32) -> Int32 {
        return self.atomicAdd(-amount)
    }
}

public extension Int64 {
    
    @_transparent
    mutating func atomicAdd(amount: Int64) -> Int64 {
        return OSAtomicAdd64Barrier(amount, &self) - amount
    }
    
    @_transparent
    mutating func atomicSub(amount: Int64) -> Int64 {
        return self.atomicAdd(-amount)
    }
}

public extension UInt32 {
    
    @_transparent
    mutating func atomicAdd(amount: UInt32) -> UInt32 {
        @inline(__always)
        func add(theVal: UnsafeMutablePointer<UInt32>) -> UInt32 {
            return UInt32(bitPattern: OSAtomicAdd32Barrier(Int32(bitPattern: amount), UnsafeMutablePointer(theVal)) - Int32(bitPattern: amount))
        }
        return add(&self)
    }
    
    @_transparent
    mutating func atomicSub(amount: UInt32) -> UInt32 {
        return self.atomicAdd(UInt32(bitPattern: -Int32(bitPattern: amount)))
    }
}

public extension UInt64 {
    
    @_transparent
    mutating func atomicAdd(amount: UInt64) -> UInt64 {
        @inline(__always)
        func add(theVal: UnsafeMutablePointer<UInt64>) -> UInt64 {
            return UInt64(bitPattern: OSAtomicAdd64Barrier(Int64(bitPattern: amount), UnsafeMutablePointer(theVal)) - Int64(bitPattern: amount))
        }
        return add(&self)
    }
    
    @_transparent
    mutating func atomicSub(amount: UInt64) -> UInt64 {
        return self.atomicAdd(UInt64(bitPattern: -Int64(bitPattern: amount)))
    }
}

public extension Int32 {
    
    @_transparent
    mutating func atomicOr(mask: Int32) -> Int32 {
        @inline(__always)
        func or(theVal: UnsafeMutablePointer<Int32>) -> Int32 {
            return OSAtomicOr32OrigBarrier(UInt32(bitPattern: mask), UnsafeMutablePointer(theVal))
        }
        return or(&self)
    }
    
    @_transparent
    mutating func atomicAnd(mask: Int32) -> Int32 {
        @inline(__always)
        func and(theVal: UnsafeMutablePointer<Int32>) -> Int32 {
            return OSAtomicAnd32OrigBarrier(UInt32(bitPattern: mask), UnsafeMutablePointer(theVal))
        }
        return and(&self)
    }
    
    @_transparent
    mutating func atomicXor(mask: Int32) -> Int32 {
        @inline(__always)
        func xor(theVal: UnsafeMutablePointer<Int32>) -> Int32 {
            return OSAtomicXor32OrigBarrier(UInt32(bitPattern: mask), UnsafeMutablePointer(theVal))
        }
        return xor(&self)
    }
}

public extension UInt32 {
    
    @_transparent
    mutating func atomicOr(mask: UInt32) -> UInt32 {
        return UInt32(bitPattern: OSAtomicOr32OrigBarrier(mask, &self))
    }
    @_transparent
    mutating func atomicAnd(mask: UInt32) -> UInt32 {
        return UInt32(bitPattern: OSAtomicAnd32OrigBarrier(mask, &self))
    }
    @_transparent
    mutating func atomicXor(mask: UInt32) -> UInt32 {
        return UInt32(bitPattern: OSAtomicXor32OrigBarrier(mask, &self))
    }
}
