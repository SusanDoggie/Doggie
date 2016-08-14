//
//  Parallel.swift
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

extension LazyRandomAccessCollection {
    
    /// Call `body` on each element in `self` in parallel
    ///
    /// - Note: You cannot use the `break` or `continue` statement to exit the
    ///   current call of the `body` closure or skip subsequent calls.
    /// - Note: Using the `return` statement in the `body` closure will only
    ///   exit from the current call to `body`, not any outer scope, and won't
    ///   skip subsequent calls.
    public func parallelEach(body: (Iterator.Element) -> ()) {
        DispatchQueue.concurrentPerform(iterations: numericCast(self.count)) {
            body(self[self.index(startIndex, offsetBy: numericCast($0))])
        }
    }
    
    public var parallel : [Iterator.Element] {
        let count: Int = numericCast(self.count)
        let buffer = UnsafeMutablePointer<Iterator.Element>.allocate(capacity: count)
        DispatchQueue.concurrentPerform(iterations: numericCast(self.count)) {
            (buffer + $0).initialize(to: self[self.index(startIndex, offsetBy: numericCast($0))])
        }
        let result = ContiguousArray(UnsafeMutableBufferPointer(start: buffer, count: count))
        buffer.deinitialize(count: count)
        buffer.deallocate(capacity: count)
        return Array(result)
    }
}
