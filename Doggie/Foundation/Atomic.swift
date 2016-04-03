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
    
    /// Compare and set Int32 with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: Int32, _ newVal: Int32) -> Bool {
        return OSAtomicCompareAndSwap32Barrier(oldVal, newVal, &self)
    }
}

public extension Int64 {
    
    /// Compare and set Int64 with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: Int64, _ newVal: Int64) -> Bool {
        return OSAtomicCompareAndSwap64Barrier(oldVal, newVal, &self)
    }
}

public extension Int {
    
    /// Compare and set Int with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: Int, _ newVal: Int) -> Bool {
        return OSAtomicCompareAndSwapLongBarrier(oldVal, newVal, &self)
    }
}

public extension UInt32 {
    
    /// Compare and set UInt32 with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: UInt32, _ newVal: UInt32) -> Bool {
        @inline(__always)
        func cas(oldVal: Int32, _ newVal: Int32, _ theVal: UnsafeMutablePointer<UInt32>) -> Bool {
            return OSAtomicCompareAndSwap32Barrier(oldVal, newVal, UnsafeMutablePointer(theVal))
        }
        return cas(Int32(bitPattern: oldVal), Int32(bitPattern: newVal), &self)
    }
}

public extension UInt64 {
    
    /// Compare and set UInt64 with barrier.
    @_transparent
    mutating func compareAndSet(oldVal: UInt64, _ newVal: UInt64) -> Bool {
        @inline(__always)
        func cas(oldVal: Int64, _ newVal: Int64, _ theVal: UnsafeMutablePointer<UInt64>) -> Bool {
            return OSAtomicCompareAndSwap64Barrier(oldVal, newVal, UnsafeMutablePointer(theVal))
        }
        return cas(Int64(bitPattern: oldVal), Int64(bitPattern: newVal), &self)
    }
}

public extension UInt {
    
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
}

extension AtomicBoolean : BooleanLiteralConvertible, BooleanType {
    
    @_transparent
    public init(booleanLiteral value: Bool) {
        self.val = value ? 0x80 : 0
    }
    
    /// Returns the current value of the boolean.
    @_transparent
    public var boolValue: Bool {
        return val != 0
    }
}

public extension AtomicBoolean {
    
    /// Sets the value, and returns the previous value.
    @_transparent
    mutating func set<Boolean: BooleanType>(value: Boolean) -> Bool {
        return value ? OSAtomicTestAndSet(0, &val) : OSAtomicTestAndClear(0, &val)
    }
    
    /// Compare and set Bool with barrier.
    @_transparent
    mutating func compareAndSet<Boolean: BooleanType>(oldVal: Boolean, _ newVal: Boolean) -> Bool {
        return self.val.compareAndSet(oldVal ? 0x80 : 0, newVal ? 0x80 : 0)
    }
}

/// Atomically adds two 32-bit values with a barrier.
@_transparent
public func AtomicAdd(amount: Int32, inout _ theVal: Int32) {
    OSAtomicAdd32Barrier(amount, &theVal)
}
/// Atomically adds two 64-bit values with a barrier.
@_transparent
public func AtomicAdd(amount: Int64, inout _ theVal: Int64) {
    OSAtomicAdd64Barrier(amount, &theVal)
}
/// Atomically increments a 32-bit value with a barrier.
@_transparent
public func AtomicIncrement(inout theVal: Int32) {
    OSAtomicIncrement32Barrier(&theVal)
}
/// Atomically increments a 64-bit value with a barrier.
@_transparent
public func AtomicIncrement(inout theVal: Int64) {
    OSAtomicIncrement64Barrier(&theVal)
}
/// Atomically increments a 32-bit value with a barrier.
@_transparent
public func AtomicDecrement(inout theVal: Int32) {
    OSAtomicDecrement32Barrier(&theVal)
}
/// Atomically increments a 64-bit value with a barrier.
@_transparent
public func AtomicDecrement(inout theVal: Int64) {
    OSAtomicDecrement64Barrier(&theVal)
}
/// Atomically adds two 32-bit values with a barrier.
@_transparent
public func AtomicAdd(amount: UInt32, inout _ theVal: UInt32) {
    @inline(__always)
    func add(amount: UInt32, _ theVal: UnsafeMutablePointer<UInt32>) {
        OSAtomicAdd32Barrier(Int32(bitPattern: amount), UnsafeMutablePointer(theVal))
    }
    add(amount, &theVal)
}
/// Atomically adds two 64-bit values with a barrier.
@_transparent
public func AtomicAdd(amount: UInt64, inout _ theVal: UInt64) {
    @inline(__always)
    func add(amount: UInt64, _ theVal: UnsafeMutablePointer<UInt64>) {
        OSAtomicAdd64Barrier(Int64(bitPattern: amount), UnsafeMutablePointer(theVal))
    }
    add(amount, &theVal)
}
/// Atomically increments a 32-bit value with a barrier.
@_transparent
public func AtomicIncrement(inout theVal: UInt32) {
    @inline(__always)
    func inc(theVal: UnsafeMutablePointer<UInt32>) {
        OSAtomicIncrement32Barrier(UnsafeMutablePointer(theVal))
    }
    inc(&theVal)
}
/// Atomically increments a 64-bit value with a barrier.
@_transparent
public func AtomicIncrement(inout theVal: UInt64) {
    @inline(__always)
    func inc(theVal: UnsafeMutablePointer<UInt64>) {
        OSAtomicIncrement64Barrier(UnsafeMutablePointer(theVal))
    }
    inc(&theVal)
}
/// Atomically increments a 32-bit value with a barrier.
@_transparent
public func AtomicDecrement(inout theVal: UInt32) {
    @inline(__always)
    func inc(theVal: UnsafeMutablePointer<UInt32>) {
        OSAtomicDecrement32Barrier(UnsafeMutablePointer(theVal))
    }
    inc(&theVal)
}
/// Atomically increments a 64-bit value with a barrier.
@_transparent
public func AtomicDecrement(inout theVal: UInt64) {
    @inline(__always)
    func inc(theVal: UnsafeMutablePointer<UInt64>) {
        OSAtomicDecrement64Barrier(UnsafeMutablePointer(theVal))
    }
    inc(&theVal)
}

/// Atomic bitwise OR of two 32-bit values returning original with barrier.
@_transparent
public func AtomicOr(mask: Int32, inout _ theVal: Int32) -> Int32 {
    @inline(__always)
    func or(mask: Int32, _ theVal: UnsafeMutablePointer<Int32>) -> Int32 {
        return OSAtomicOr32OrigBarrier(UInt32(bitPattern: mask), UnsafeMutablePointer(theVal))
    }
    return or(mask, &theVal)
}
/// Atomic bitwise AND of two 32-bit values returning original with barrier.
@_transparent
public func AtomicAnd(mask: Int32, inout _ theVal: Int32) -> Int32 {
    @inline(__always)
    func and(mask: Int32, _ theVal: UnsafeMutablePointer<Int32>) -> Int32 {
        return OSAtomicAnd32OrigBarrier(UInt32(bitPattern: mask), UnsafeMutablePointer(theVal))
    }
    return and(mask, &theVal)
}
/// Atomic bitwise XOR of two 32-bit values returning original with barrier.
@_transparent
public func AtomicXor(mask: Int32, inout _ theVal: Int32) -> Int32 {
    @inline(__always)
    func xor(mask: Int32, _ theVal: UnsafeMutablePointer<Int32>) -> Int32 {
        return OSAtomicXor32OrigBarrier(UInt32(bitPattern: mask), UnsafeMutablePointer(theVal))
    }
    return xor(mask, &theVal)
}

/// Atomic bitwise OR of two 32-bit values returning original with barrier.
@_transparent
public func AtomicOr(mask: UInt32, inout _ theVal: UInt32) -> UInt32 {
    return UInt32(bitPattern: OSAtomicOr32OrigBarrier(mask, &theVal))
}
/// Atomic bitwise AND of two 32-bit values returning original with barrier.
@_transparent
public func AtomicAnd(mask: UInt32, inout _ theVal: UInt32) -> UInt32 {
    return UInt32(bitPattern: OSAtomicAnd32OrigBarrier(mask, &theVal))
}
/// Atomic bitwise XOR of two 32-bit values returning original with barrier.
@_transparent
public func AtomicXor(mask: UInt32, inout _ theVal: UInt32) -> UInt32 {
    return UInt32(bitPattern: OSAtomicXor32OrigBarrier(mask, &theVal))
}
