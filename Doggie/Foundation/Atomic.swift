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
/// Compare and swap pointers with Int32.
@_transparent
public func AtomicCompareAndSwap(oldVal: Int32, _ newVal: Int32, inout _ theVal: Int32) -> Bool {
    return OSAtomicCompareAndSwap32Barrier(oldVal, newVal, &theVal)
}
/// Compare and swap pointers with Int64.
@_transparent
public func AtomicCompareAndSwap(oldVal: Int64, _ newVal: Int64, inout _ theVal: Int64) -> Bool {
    return OSAtomicCompareAndSwap64Barrier(oldVal, newVal, &theVal)
}
/// Compare and swap pointers with Int.
@_transparent
public func AtomicCompareAndSwap(oldVal: Int, _ newVal: Int, inout _ theVal: Int) -> Bool {
    return OSAtomicCompareAndSwapLongBarrier(oldVal, newVal, &theVal)
}
/// Compare and swap pointers with barrier.
@_transparent
public func AtomicCompareAndSwap<T>(oldVal: UnsafeMutablePointer<T>, _ newVal: UnsafeMutablePointer<T>, inout _ theVal: UnsafeMutablePointer<T>) -> Bool {
    @inline(__always)
    func cas(oldVal: UnsafeMutablePointer<Void>, _ newVal: UnsafeMutablePointer<Void>, _ theVal: UnsafeMutablePointer<UnsafeMutablePointer<T>>) -> Bool {
        return OSAtomicCompareAndSwapPtrBarrier(oldVal, newVal, UnsafeMutablePointer(theVal))
    }
    return cas(oldVal, newVal, &theVal)
}

/// Atomic test and set with barrier
@_transparent
public func AtomicTestAndSet(val: Int32, inout _ theVal: Int32) -> Bool {
    @inline(__always)
    func tas(val: Int32, _ theVal: UnsafeMutablePointer<Int32>) -> Bool {
        return OSAtomicTestAndSetBarrier(UInt32(bitPattern: val), UnsafeMutablePointer(theVal))
    }
    return tas(val, &theVal)
}
/// Atomic test and clear
@_transparent
public func AtomicTestAndClear(val: Int32, inout _ theVal: Int32) -> Bool {
    @inline(__always)
    func tac(val: Int32, _ theVal: UnsafeMutablePointer<Int32>) -> Bool {
        return OSAtomicTestAndClearBarrier(UInt32(bitPattern: val), UnsafeMutablePointer(theVal))
    }
    return tac(val, &theVal)
}
/// Atomic test and set with barrier
@_transparent
public func AtomicTestAndSet(val: UInt32, inout _ theVal: UInt32) -> Bool {
    return OSAtomicTestAndSetBarrier(val, &theVal)
}
/// Atomic test and clear
@_transparent
public func AtomicTestAndClear(val: UInt32, inout _ theVal: UInt32) -> Bool {
    return OSAtomicTestAndClearBarrier(val, &theVal)
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
