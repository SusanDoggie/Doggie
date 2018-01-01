//
//  AtomicStack.swift
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

private class AtomicStackContainerBox<Instance> {
    
    var base: AtomicStackContainer<Instance>!
    
    init(base: AtomicStackContainer<Instance>! = nil) {
        self.base = base
    }
}
private struct AtomicStackContainer<Instance> {
    
    let next: AtomicStackContainerBox<Instance>?
    let value: Instance
}

open class AtomicStack<Instance> {
    
    private var head: Atomic<AtomicStackContainer<Instance>?>
    
    public init() {
        self.head = Atomic(value: nil)
    }
    
    public func push(_ newElement: Instance) {
        let box = AtomicStackContainerBox<Instance>()
        head.fetchStore {
            if $0 == nil {
                return AtomicStackContainer(next: nil, value: newElement)
            } else {
                box.base = $0
                return AtomicStackContainer(next: box, value: newElement)
            }
        }
    }
    
    public func next() -> Instance? {
        return head.fetchStore { $0?.next?.base }?.value
    }
}
