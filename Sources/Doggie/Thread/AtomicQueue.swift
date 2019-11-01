//
//  AtomicQueue.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

private class AtomicQueueContainer<Instance> {
    
    var next: Atomic<AtomicQueueContainer<Instance>?>
    var value: Instance?
    
    init(next: AtomicQueueContainer<Instance>? = nil, value: Instance? = nil) {
        self.next = Atomic(value: next)
        self.value = value
    }
}

open class AtomicQueue<Instance> {
    
    private var head: Atomic<AtomicQueueContainer<Instance>>
    private var tail: AtomicQueueContainer<Instance>
    
    public init() {
        let telomere = AtomicQueueContainer<Instance>()
        self.head = Atomic(value: telomere)
        self.tail = telomere
    }
    
    public func push(_ newElement: Instance) {
        let new = AtomicQueueContainer(next: nil, value: newElement)
        var tail = self.tail
        while true {
            let _tail = tail.next.fetchSelf()
            if let next = _tail.value {
                tail = next
            } else if tail.next.compareSet(old: _tail.current, new: new) {
                self.tail = new
                return
            }
        }
    }
    
    public func next() -> Instance? {
        while true {
            let _head = head.fetchSelf()
            guard let _next = _head.value.next.fetch() else { return nil }
            if head.compareSet(old: _head.current, new: _next) {
                let value = _next.value
                _next.value = nil
                return value
            }
        }
    }
}
