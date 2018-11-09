//
//  AtomicTest.swift
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

import Doggie
import XCTest

class AtomicTest: XCTestCase {
    
    func testAtomicA() {
        
        let queue = DispatchQueue(label: "com.SusanDoggie.Thread", attributes: .concurrent)
        let group = DispatchGroup()
        
        var atom = Atomic(value: 0)
        
        for _ in 0..<10 {
            queue.async(group: group) {
                sleep(1)
                atom.fetchStore { $0 + 1 }
            }
        }
        
        group.wait()
        
        XCTAssertEqual(atom.value, 10)
    }
    
    func testAtomicQueueA() {
        
        let queue = AtomicQueue<Int>()
        
        for i in 1...10 {
            queue.push(i)
        }
        
        XCTAssertEqual(queue.next(), 1)
        XCTAssertEqual(queue.next(), 2)
        XCTAssertEqual(queue.next(), 3)
        XCTAssertEqual(queue.next(), 4)
        XCTAssertEqual(queue.next(), 5)
        XCTAssertEqual(queue.next(), 6)
        XCTAssertEqual(queue.next(), 7)
        XCTAssertEqual(queue.next(), 8)
        XCTAssertEqual(queue.next(), 9)
        XCTAssertEqual(queue.next(), 10)
        XCTAssertEqual(queue.next(), nil)
    }
    func testAtomicStackA() {
        
        let stack = AtomicStack<Int>()
        
        for i in 1...10 {
            stack.push(i)
        }
        
        XCTAssertEqual(stack.next(), 10)
        XCTAssertEqual(stack.next(), 9)
        XCTAssertEqual(stack.next(), 8)
        XCTAssertEqual(stack.next(), 7)
        XCTAssertEqual(stack.next(), 6)
        XCTAssertEqual(stack.next(), 5)
        XCTAssertEqual(stack.next(), 4)
        XCTAssertEqual(stack.next(), 3)
        XCTAssertEqual(stack.next(), 2)
        XCTAssertEqual(stack.next(), 1)
        XCTAssertEqual(stack.next(), nil)
    }
    func testAtomicQueueB() {
        
        let queue = AtomicQueue<Int>()
        
        DispatchQueue.concurrentPerform(iterations: 10) {
            queue.push($0)
        }
        
        let result = Set(AnyIterator(queue.next))
        
        XCTAssertEqual(result, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    func testAtomicStackB() {
        
        let stack = AtomicStack<Int>()
        
        DispatchQueue.concurrentPerform(iterations: 10) {
            stack.push($0)
        }
        
        let result = Set(AnyIterator(stack.next))
        
        XCTAssertEqual(result, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
}
