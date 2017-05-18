//
//  Memory.swift
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

import Foundation

extension UnsafeRawBufferPointer {
    
    @_inlineable
    public func _memmap<T, R>(to: UnsafeMutableRawBufferPointer, body: (T) throws -> R) rethrows -> Int {
        
        let s_count = self.count / MemoryLayout<T>.stride
        let r_count = to.count / MemoryLayout<R>.stride
        
        let write = Swift.min(s_count, r_count)
        
        if var source = self.baseAddress?.assumingMemoryBound(to: T.self), var destination = to.baseAddress?.assumingMemoryBound(to: R.self) {
            
            for _ in 0..<write {
                
                destination.pointee = try body(source.pointee)
                
                source += 1
                destination += 1
            }
        }
        
        return write
    }
}

@_inlineable
public func _memset<T>(_ __b: UnsafeMutableRawPointer, _ __c: T, _ __len: Int) -> Int {
    
    var __c = __c
    let __s = __b
    var __b = __b
    var __len = __len
    var copied = 0
    
    if __len > 0 {
        let copy = min(MemoryLayout<T>.stride, __len)
        withUnsafeBytes(of: &__c) { _ = memcpy(__b, $0.baseAddress!, copy) }
        __len -= copy
        __b += copy
        copied += copy
    }
    
    while __len > 0 {
        let copy = min(copied, __len)
        memcpy(__b, __s, copy)
        __len -= copy
        __b += copy
        copied += copy
    }
    
    return copied
}
