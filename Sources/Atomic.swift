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
    
    /// Compare and set the value.
    mutating func compareSet(old: Self, new: Self) -> Bool
    
    /// Sets the value, and returns the previous value.
    mutating func fetchStore(new: Self) -> Self
    
    /// Sets the value, and returns the previous value. `block` is called repeatedly until result accepted.
    mutating func fetchStore(block: @noescape (Self) throws -> Self) rethrows -> Self
}

public extension SDAtomicType {
    
    public mutating func fetchStore(new: Self) -> Self {
        return self.fetchStore { _ in new }
    }
    
    public mutating func fetchStore(block: @noescape (Self) throws -> Self) rethrows -> Self {
        while true {
            let old = self
            if self.compareSet(old: old, new: try block(old)) {
                return old
            }
        }
    }
}

extension Int32 : SDAtomicType {
    
    /// Compare and set Int32 with barrier.
    public mutating func compareSet(old: Int32, new: Int32) -> Bool {
        return OSAtomicCompareAndSwap32Barrier(old, new, &self)
    }
}

extension Int64 : SDAtomicType {
    
    /// Compare and set Int64 with barrier.
    public mutating func compareSet(old: Int64, new: Int64) -> Bool {
        return OSAtomicCompareAndSwap64Barrier(old, new, &self)
    }
}

extension Int : SDAtomicType {
    
    /// Compare and set Int with barrier.
    public mutating func compareSet(old: Int, new: Int) -> Bool {
        return OSAtomicCompareAndSwapLongBarrier(old, new, &self)
    }
}

extension UInt32 : SDAtomicType {
    
    /// Compare and set UInt32 with barrier.
    public mutating func compareSet(old: UInt32, new: UInt32) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UInt32>) -> Bool {
            return OSAtomicCompareAndSwap32Barrier(Int32(bitPattern: old), Int32(bitPattern: new), UnsafeMutablePointer(theVal))
        }
        return cas(&self)
    }
}

extension UInt64 : SDAtomicType {
    
    /// Compare and set UInt64 with barrier.
    public mutating func compareSet(old: UInt64, new: UInt64) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UInt64>) -> Bool {
            return OSAtomicCompareAndSwap64Barrier(Int64(bitPattern: old), Int64(bitPattern: new), UnsafeMutablePointer(theVal))
        }
        return cas(&self)
    }
}

extension UInt : SDAtomicType {
    
    /// Compare and set UInt with barrier.
    public mutating func compareSet(old: UInt, new: UInt) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UInt>) -> Bool {
            return OSAtomicCompareAndSwapLongBarrier(Int(bitPattern: old), Int(bitPattern: new), UnsafeMutablePointer(theVal))
        }
        return cas(&self)
    }
}

extension UnsafePointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafePointer, new: UnsafePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) -> Bool {
            return OSAtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(mutating: old), UnsafeMutableRawPointer(mutating: new), UnsafeMutablePointer<UnsafeMutableRawPointer?>(theVal))
        }
        return cas(&self)
    }
}

extension UnsafeMutablePointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeMutablePointer, new: UnsafeMutablePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) -> Bool {
            return OSAtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(old), UnsafeMutableRawPointer(new), UnsafeMutablePointer<UnsafeMutableRawPointer?>(theVal))
        }
        return cas(&self)
    }
}
extension UnsafeRawPointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeRawPointer, new: UnsafeRawPointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) -> Bool {
            return OSAtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(mutating: old), UnsafeMutableRawPointer(mutating: new), UnsafeMutablePointer<UnsafeMutableRawPointer?>(theVal))
        }
        return cas(&self)
    }
}

extension UnsafeMutableRawPointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeMutableRawPointer, new: UnsafeMutableRawPointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) -> Bool {
            return OSAtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(old), UnsafeMutableRawPointer(new), UnsafeMutablePointer<UnsafeMutableRawPointer?>(theVal))
        }
        return cas(&self)
    }
}

extension OpaquePointer : SDAtomicType {
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: OpaquePointer, new: OpaquePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<OpaquePointer>) -> Bool {
            return OSAtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(old), UnsafeMutableRawPointer(new), UnsafeMutablePointer<UnsafeMutableRawPointer?>(theVal))
        }
        return cas(&self)
    }
}

public struct AtomicBoolean {
    
    fileprivate var val: Int32
    
    public init() {
        self.val = 0
    }
}

extension AtomicBoolean : ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: Bool) {
        self.val = value ? 0x80 : 0
    }
}

extension AtomicBoolean {
    
    /// Returns the current value of the boolean.
    public var boolValue: Bool {
        return val == 0x80
    }
    /// Construct an instance representing the same logical value as
    /// `value`.
    public init(_ value: Bool) {
        self.val = value ? 0x80 : 0
    }
}

extension AtomicBoolean : SDAtomicType {
    
    public mutating func compareSet(old: AtomicBoolean, new: AtomicBoolean) -> Bool {
        return self.compareSet(old: old.boolValue, new: new.boolValue)
    }
    public mutating func fetchStore(value: AtomicBoolean) -> Bool {
        return self.fetchStore(value: value.boolValue)
    }
    
    /// Compare and set Bool with barrier.
    public mutating func compareSet(old: Bool, new: Bool) -> Bool {
        return OSAtomicCompareAndSwap32Barrier(old ? 0x80 : 0, new ? 0x80 : 0, &val)
    }
    
    /// Sets the value, and returns the previous value.
    public mutating func fetchStore(value: Bool) -> Bool {
        return value ? OSAtomicTestAndSet(0, &val) : OSAtomicTestAndClear(0, &val)
    }
}

extension AtomicBoolean: CustomStringConvertible {
    
    public var description: String {
        return self.boolValue ? "true" : "false"
    }
}

extension AtomicBoolean : Equatable, Hashable {
    
    public var hashValue: Int {
        return boolValue.hashValue
    }
}

public func == (lhs: AtomicBoolean, rhs: AtomicBoolean) -> Bool {
    return lhs.boolValue == rhs.boolValue
}

private final class AtomicBase<Instance> {
    
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
            return OSAtomicCompareAndSwapPtrBarrier(_old.toOpaque(), _new.toOpaque(), UnsafeMutablePointer<UnsafeMutableRawPointer?>(theVal))
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
    public mutating func fetchStore(block: @noescape (Instance) throws -> Instance) rethrows -> Instance {
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
