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



public extension Int32 {
    
    /// Sets the value, and returns the previous value.
    @_transparent
    mutating func atomicSet(value: Int32) -> Int32 {
        while true {
            let oldVal = self
            if self.compareAndSet(oldVal, value) {
                return oldVal
            }
        }
    }
    
    /// Compare and set Int32 with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: Int32, _ newVal: Int32) -> Bool {
        return OSAtomicCompareAndSwap32Barrier(oldVal, newVal, &self)
    }
    
    @_transparent
    mutating func atomicAdd(amount: Int32) {
        OSAtomicAdd32Barrier(amount, &self)
    }
    
    @_transparent
    mutating func atomicIncrement() {
        OSAtomicIncrement32Barrier(&self)
    }
    
    @_transparent
    mutating func atomicDecrement() {
        OSAtomicDecrement32Barrier(&self)
    }
    
    @_transparent
    mutating func atomicOr(mask: Int32) -> Int32 {
        @inline(__always)
        func or(mask: Int32, _ theVal: UnsafeMutablePointer<Int32>) -> Int32 {
            return OSAtomicOr32OrigBarrier(UInt32(bitPattern: mask), UnsafeMutablePointer(theVal))
        }
        return or(mask, &self)
    }
    
    @_transparent
    mutating func atomicAnd(mask: Int32) -> Int32 {
        @inline(__always)
        func and(mask: Int32, _ theVal: UnsafeMutablePointer<Int32>) -> Int32 {
            return OSAtomicAnd32OrigBarrier(UInt32(bitPattern: mask), UnsafeMutablePointer(theVal))
        }
        return and(mask, &self)
    }
    
    @_transparent
    mutating func atomicXor(mask: Int32) -> Int32 {
        @inline(__always)
        func xor(mask: Int32, _ theVal: UnsafeMutablePointer<Int32>) -> Int32 {
            return OSAtomicXor32OrigBarrier(UInt32(bitPattern: mask), UnsafeMutablePointer(theVal))
        }
        return xor(mask, &self)
    }
}

public extension Int64 {
    
    /// Sets the value, and returns the previous value.
    @_transparent
    mutating func atomicSet(value: Int64) -> Int64 {
        while true {
            let oldVal = self
            if self.compareAndSet(oldVal, value) {
                return oldVal
            }
        }
    }
    
    /// Compare and set Int64 with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: Int64, _ newVal: Int64) -> Bool {
        return OSAtomicCompareAndSwap64Barrier(oldVal, newVal, &self)
    }
    
    @_transparent
    mutating func atomicAdd(amount: Int64) {
        OSAtomicAdd64Barrier(amount, &self)
    }
    
    @_transparent
    mutating func atomicIncrement() {
        OSAtomicIncrement64Barrier(&self)
    }
    
    @_transparent
    mutating func atomicDecrement() {
        OSAtomicDecrement64Barrier(&self)
    }
}

public extension Int {
    
    /// Sets the value, and returns the previous value.
    @_transparent
    mutating func atomicSet(value: Int) -> Int {
        while true {
            let oldVal = self
            if self.compareAndSet(oldVal, value) {
                return oldVal
            }
        }
    }
    
    /// Compare and set Int with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: Int, _ newVal: Int) -> Bool {
        return OSAtomicCompareAndSwapLongBarrier(oldVal, newVal, &self)
    }
}

public extension UInt32 {
    
    /// Sets the value, and returns the previous value.
    @_transparent
    mutating func atomicSet(value: UInt32) -> UInt32 {
        while true {
            let oldVal = self
            if self.compareAndSet(oldVal, value) {
                return oldVal
            }
        }
    }
    
    /// Compare and set UInt32 with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: UInt32, _ newVal: UInt32) -> Bool {
        @inline(__always)
        func cas(oldVal: Int32, _ newVal: Int32, _ theVal: UnsafeMutablePointer<UInt32>) -> Bool {
            return OSAtomicCompareAndSwap32Barrier(oldVal, newVal, UnsafeMutablePointer(theVal))
        }
        return cas(Int32(bitPattern: oldVal), Int32(bitPattern: newVal), &self)
    }
    
    @_transparent
    mutating func atomicAdd(amount: UInt32) {
        @inline(__always)
        func add(amount: UInt32, _ theVal: UnsafeMutablePointer<UInt32>) {
            OSAtomicAdd32Barrier(Int32(bitPattern: amount), UnsafeMutablePointer(theVal))
        }
        add(amount, &self)
    }
    
    @_transparent
    mutating func atomicIncrement() {
        @inline(__always)
        func increment(theVal: UnsafeMutablePointer<UInt32>) {
            OSAtomicIncrement32Barrier(UnsafeMutablePointer(theVal))
        }
        increment(&self)
    }
    
    @_transparent
    mutating func atomicDecrement() {
        @inline(__always)
        func decrement(theVal: UnsafeMutablePointer<UInt32>) {
            OSAtomicDecrement32Barrier(UnsafeMutablePointer(theVal))
        }
        decrement(&self)
    }
    
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

public extension UInt64 {
    
    /// Sets the value, and returns the previous value.
    @_transparent
    mutating func atomicSet(value: UInt64) -> UInt64 {
        while true {
            let oldVal = self
            if self.compareAndSet(oldVal, value) {
                return oldVal
            }
        }
    }
    
    /// Compare and set UInt64 with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: UInt64, _ newVal: UInt64) -> Bool {
        @inline(__always)
        func cas(oldVal: Int64, _ newVal: Int64, _ theVal: UnsafeMutablePointer<UInt64>) -> Bool {
            return OSAtomicCompareAndSwap64Barrier(oldVal, newVal, UnsafeMutablePointer(theVal))
        }
        return cas(Int64(bitPattern: oldVal), Int64(bitPattern: newVal), &self)
    }
    
    @_transparent
    mutating func atomicAdd(amount: UInt64) {
        @inline(__always)
        func add(amount: UInt64, _ theVal: UnsafeMutablePointer<UInt64>) {
            OSAtomicAdd64Barrier(Int64(bitPattern: amount), UnsafeMutablePointer(theVal))
        }
        add(amount, &self)
    }
    
    @_transparent
    mutating func atomicIncrement() {
        @inline(__always)
        func increment(theVal: UnsafeMutablePointer<UInt64>) {
            OSAtomicIncrement64Barrier(UnsafeMutablePointer(theVal))
        }
        increment(&self)
    }
    
    @_transparent
    mutating func atomicDecrement() {
        @inline(__always)
        func decrement(theVal: UnsafeMutablePointer<UInt64>) {
            OSAtomicDecrement64Barrier(UnsafeMutablePointer(theVal))
        }
        decrement(&self)
    }
}

public extension UInt {
    
    /// Sets the value, and returns the previous value.
    @_transparent
    mutating func atomicSet(value: UInt) -> UInt {
        while true {
            let oldVal = self
            if self.compareAndSet(oldVal, value) {
                return oldVal
            }
        }
    }
    
    /// Compare and set UInt with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: UInt, _ newVal: UInt) -> Bool {
        @inline(__always)
        func cas(oldVal: Int, _ newVal: Int, _ theVal: UnsafeMutablePointer<UInt>) -> Bool {
            return OSAtomicCompareAndSwapLongBarrier(oldVal, newVal, UnsafeMutablePointer(theVal))
        }
        return cas(Int(bitPattern: oldVal), Int(bitPattern: newVal), &self)
    }
}

public extension UnsafeMutablePointer {
    
    /// Sets the value, and returns the previous value.
    @_transparent
    mutating func atomicSet(value: UnsafeMutablePointer) -> UnsafeMutablePointer {
        while true {
            let oldVal = self
            if self.compareAndSet(oldVal, value) {
                return oldVal
            }
        }
    }
    
    /// Compare and set pointers with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: UnsafeMutablePointer, _ newVal: UnsafeMutablePointer) -> Bool {
        @inline(__always)
        func cas(oldVal: UnsafeMutablePointer<Void>, _ newVal: UnsafeMutablePointer<Void>, _ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Memory>>) -> Bool {
            return OSAtomicCompareAndSwapPtrBarrier(oldVal, newVal, UnsafeMutablePointer<UnsafeMutablePointer<Void>>(theVal))
        }
        return cas(oldVal, newVal, &self)
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

public extension AtomicBoolean {
    
    /// Sets the value, and returns the previous value.
    @_transparent
    mutating func set<T: BooleanType>(value: T) -> Bool {
        return value ? OSAtomicTestAndSet(0, &val) : OSAtomicTestAndClear(0, &val)
    }
    
    /// Compare and set Bool with barrier.
    @_transparent
    mutating func compareAndSet<T: BooleanType>(oldVal: T, _ newVal: T) -> Bool {
        return self.val.compareAndSet(oldVal ? 0x80 : 0, newVal ? 0x80 : 0)
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
    public var hashValue: Int {
        return boolValue.hashValue
    }
}

public func == (lhs: AtomicBoolean, rhs: AtomicBoolean) -> Bool {
    return lhs.boolValue == rhs.boolValue
}
