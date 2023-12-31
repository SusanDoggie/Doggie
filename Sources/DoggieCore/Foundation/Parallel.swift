//
//  Parallel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension DispatchQueue {
    
    @inlinable
    @inline(__always)
    public class func concurrentPerform(iterations: Int, threads: Int, execute work: (Int) -> Void) {
        concurrentPerform(iterations: threads) { stride(from: $0, to: iterations, by: threads).forEach(work) }
    }
}

extension RandomAccessCollection {
    
    /// Call `body` on each element in `self` in parallel
    ///
    /// - Note: You cannot use the `break` or `continue` statement to exit the
    ///   current call of the `body` closure or skip subsequent calls.
    /// - Note: Using the `return` statement in the `body` closure will only
    ///   exit from the current call to `body`, not any outer scope, and won't
    ///   skip subsequent calls.
    @inlinable
    @inline(__always)
    public func parallelEach(body: (Element) -> Void) {
        DispatchQueue.concurrentPerform(iterations: self.count) { body(self[self.index(startIndex, offsetBy: $0)]) }
    }
    
    /// Call `body` on each element in `self` in parallel
    ///
    /// - Note: You cannot use the `break` or `continue` statement to exit the
    ///   current call of the `body` closure or skip subsequent calls.
    /// - Note: Using the `return` statement in the `body` closure will only
    ///   exit from the current call to `body`, not any outer scope, and won't
    ///   skip subsequent calls.
    ///
    /// - Parameter threads: Number of threads at the same time.
    @inlinable
    @inline(__always)
    public func parallelEach(threads: Int, body: (Element) -> Void) {
        DispatchQueue.concurrentPerform(iterations: self.count, threads: threads) { body(self[self.index(startIndex, offsetBy: $0)]) }
    }
    
    /// Returns an array containing the results of mapping the given closure
    /// over the sequence's elements. The elements of the result are computed
    /// in parallel.
    ///
    /// In this example, `map` is used first to convert the names in the array
    /// to lowercase strings and then to count their characters.
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    ///     let lowercaseNames = cast.parallelMap { $0.lowercaseString }
    ///     // 'lowercaseNames' == ["vivien", "marlon", "kim", "karl"]
    ///     let letterCounts = cast.parallelMap { $0.count }
    ///     // 'letterCounts' == [6, 6, 3, 4]
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts an
    ///   element of this sequence as its parameter and returns a transformed
    ///   value of the same or of a different type.
    /// - Returns: An array containing the transformed elements of this
    ///   sequence.
    @inlinable
    public func parallelMap<T>(_ transform: (Element) -> T) -> [T] {
        
        let count = self.count
        
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            guard let buffer = buffer.baseAddress else { return }
            DispatchQueue.concurrentPerform(iterations: count) {
                (buffer + $0).initialize(to: transform(self[self.index(startIndex, offsetBy: $0)]))
            }
            initializedCount = count
        }
    }
    
    /// Returns an array containing the results of mapping the given closure
    /// over the sequence's elements. The elements of the result are computed
    /// in parallel.
    ///
    /// In this example, `map` is used first to convert the names in the array
    /// to lowercase strings and then to count their characters.
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    ///     let lowercaseNames = cast.parallelMap { $0.lowercaseString }
    ///     // 'lowercaseNames' == ["vivien", "marlon", "kim", "karl"]
    ///     let letterCounts = cast.parallelMap { $0.count }
    ///     // 'letterCounts' == [6, 6, 3, 4]
    ///
    /// - Parameter threads: Number of threads at the same time.
    /// - Parameter transform: A mapping closure. `transform` accepts an
    ///   element of this sequence as its parameter and returns a transformed
    ///   value of the same or of a different type.
    /// - Returns: An array containing the transformed elements of this
    ///   sequence.
    @inlinable
    public func parallelMap<T>(threads: Int, _ transform: (Element) -> T) -> [T] {
        
        let count = self.count
        
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            guard let buffer = buffer.baseAddress else { return }
            DispatchQueue.concurrentPerform(iterations: count, threads: threads) {
                (buffer + $0).initialize(to: transform(self[self.index(startIndex, offsetBy: $0)]))
            }
            initializedCount = count
        }
    }
}
