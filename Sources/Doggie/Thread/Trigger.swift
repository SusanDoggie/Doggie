//
//  Trigger.swift
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

open class Trigger {
    
    private let queue: DispatchQueue
    private let callback: (Trigger) -> Void
    private var flag: Int8
    
    public var qos: DispatchQoS
    public var flags: DispatchWorkItemFlags
    
    public init(queue: DispatchQueue = SDDefaultDispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], callback: @escaping (Trigger) -> Void) {
        self.queue = queue
        self.callback = callback
        self.flag = 0
        self.qos = qos
        self.flags = flags
    }
}

extension Trigger {
    
    public func signal() {
        if flag.fetchStore(2) == 0 {
            queue.async(qos: qos, flags: flags, execute: dispatchRunloop)
        }
    }
    
    private func dispatchRunloop() {
        while true {
            flag = 1
            self.callback(self)
            if flag.compareSet(old: 1, new: 0) {
                return
            }
        }
    }
}
