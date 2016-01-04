//
//  SecureBuffer.swift
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

private final class SecureBufferBase {
    
    let size: Int
    let ptr: UnsafeMutablePointer<UInt8>
    
    init(size: Int) {
        self.size = size
        self.ptr = UnsafeMutablePointer<UInt8>.alloc(size)
        mlock(self.ptr, size)
        memset(self.ptr, 0, size)
    }
    
    deinit {
        memset(self.ptr, 0, self.size)
        munlock(self.ptr, size)
        self.ptr.destroy(self.size)
        self.ptr.dealloc(self.size)
    }
}

extension SecureBufferBase {
    
    var clone: SecureBufferBase {
        let _clone = SecureBufferBase(size: self.size)
        memcpy(_clone.ptr, self.ptr, self.size)
        return _clone
    }
}

public struct SecureBuffer {
    
    private var base: SecureBufferBase
    
    public init(size: Int) {
        self.base = SecureBufferBase(size: size)
    }
}

public extension SecureBuffer {
    
    public var size: Int {
        return self.base.size
    }
    
    public func count<T : IntegerType>(_: T.Type) -> Int {
        return self.base.size / sizeof(T)
    }
    
    public subscript(idx: Int) -> UInt8 {
        get {
            return self.getValue(idx)
        }
        set {
            self.setValue(idx, value: newValue)
        }
    }
    public subscript(idx: Int) -> UInt16 {
        get {
            return self.getValue(idx)
        }
        set {
            self.setValue(idx, value: newValue)
        }
    }
    public subscript(idx: Int) -> UInt32 {
        get {
            return self.getValue(idx)
        }
        set {
            self.setValue(idx, value: newValue)
        }
    }
    public subscript(idx: Int) -> UInt64 {
        get {
            return self.getValue(idx)
        }
        set {
            self.setValue(idx, value: newValue)
        }
    }
}

public extension SecureBuffer {
    
    public mutating func copyFrom(bytes: UnsafePointer<UInt8>, count: Int) {
        if !isUniquelyReferencedNonObjC(&self.base) {
            self.base = self.base.clone
        }
        memcpy(self.base.ptr, bytes, min(self.base.size, count))
    }
}

private extension SecureBuffer {
    
    func getValue<T : IntegerType>(idx: Int) -> T {
        assert(idx * sizeof(T) < self.base.size, "index out of range.")
        return UnsafePointer(self.base.ptr)[idx]
    }
    
    mutating func setValue<T : IntegerType>(idx: Int, value: T) {
        assert(idx * sizeof(T) < self.base.size, "index out of range.")
        if !isUniquelyReferencedNonObjC(&self.base) {
            self.base = self.base.clone
        }
        UnsafeMutablePointer(self.base.ptr)[idx] = value
    }
}