//
//  SDThread.swift
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
import Dispatch

// MARK: SDAtomic

private let SDDefaultDispatchQueue: DispatchQueue = {
    if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
        return DispatchQueue(label: "com.SusanDoggie.Thread", attributes: .concurrent, autoreleaseFrequency: .workItem)
    } else {
        return DispatchQueue(label: "com.SusanDoggie.Thread", attributes: .concurrent)
    }
}()

open class SDAtomic {
    
    fileprivate let queue: DispatchQueue
    fileprivate let block: (SDAtomic) -> Void
    fileprivate var flag: Int8
    
    public var qos: DispatchQoS
    public var flags: DispatchWorkItemFlags
    
    public init(queue: DispatchQueue = SDDefaultDispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], block: @escaping (SDAtomic) -> Void) {
        self.queue = queue
        self.block = block
        self.flag = 0
        self.qos = qos
        self.flags = flags
    }
}

extension SDAtomic {
    
    public func signal() {
        if flag.fetchStore(2) == 0 {
            queue.async(qos: qos, flags: flags, execute: dispatchRunloop)
        }
    }
    
    fileprivate func dispatchRunloop() {
        while true {
            flag = 1
            
            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
                autoreleasepool { self.block(self) }
            #else
                self.block(self)
            #endif

            if flag.compareSet(old: 1, new: 0) {
                return
            }
        }
    }
}

// MARK: SDTask

public class SDTask<Result> {
    
    fileprivate let queue: DispatchQueue
    fileprivate var worker: DispatchWorkItem!
    
    fileprivate let lck = SDConditionLock()
    
    fileprivate var storage = Atomic<Result?>(value: nil)
    
    fileprivate init(queue: DispatchQueue) {
        self.queue = queue
    }
    /// Create a SDTask and compute block.
    public init(queue: DispatchQueue = SDDefaultDispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], block: @escaping () -> Result) {
        self.queue = queue
        let worker = createWorker(qos: qos, flags: flags, block: block)
        self.worker = worker
        self.queue.async(execute: worker)
    }
}

extension SDTask {
    
    /// Create a SDTask and compute block.
    @discardableResult
    public static func async(queue: DispatchQueue = SDDefaultDispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], block: @escaping () -> Result) -> SDTask {
        return SDTask(queue: queue, qos: qos, flags: flags, block: block)
    }
}

extension SDTask {
    
    fileprivate func createWorker(qos: DispatchQoS, flags: DispatchWorkItemFlags, block: @escaping () -> Result) -> DispatchWorkItem {
        return DispatchWorkItem(qos: qos, flags: flags) { [weak self] in
            let value = block()
            if let _self = self {
                _self.storage.value = value
                _self.lck.broadcast()
            }
        }
    }
}

extension SDTask {
    
    /// Return `true` iff task is completed.
    public var completed: Bool {
        return storage.value != nil
    }
    
    @discardableResult
    public func wait(until time: DispatchWallTime) -> Bool {
        return lck.wait(for: completed, until: time)
    }
    
    /// Result of task.
    public var result: Result {
        if let value = storage.value {
            return value
        }
        lck.wait(for: completed)
        return storage.value!
    }
}

extension SDTask {
    
    /// Run `block` after `self` is completed.
    @discardableResult
    public func then<R>(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], block: @escaping (Result) -> R) -> SDTask<R> {
        return self.then(queue: queue, qos: qos, flags: flags, block: block)
    }
    
    /// Run `block` after `self` is completed with specific queue.
    @discardableResult
    public func then<R>(queue: DispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], block: @escaping (Result) -> R) -> SDTask<R> {
        var storage: Result!
        let result = SDTask<R>(queue: queue)
        let worker = result.createWorker(qos: qos, flags: flags) { block(storage) }
        result.worker = worker
        self.worker.notify(qos: qos, flags: flags, queue: queue) {
            storage = self.result
            worker.perform()
        }
        return result
    }
}

extension SDTask {
    
    public func wait(deadline: DispatchTime, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = []) -> SDTask<Result?> {
        return self.wait(queue: queue, deadline: deadline, qos: qos, flags: flags)
    }
    
    public func wait(queue: DispatchQueue, deadline: DispatchTime, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = []) -> SDTask<Result?> {
        let result = SDTask<Result?>(queue: queue)
        let worker = result.createWorker(qos: qos, flags: flags) { self.storage.value }
        result.worker = worker
        queue.asyncAfter(deadline: deadline, execute: worker)
        return result
    }
    
    public func wait(wallDeadline: DispatchWallTime, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = []) -> SDTask<Result?> {
        return self.wait(queue: queue, wallDeadline: wallDeadline, qos: qos, flags: flags)
    }
    
    public func wait(queue: DispatchQueue, wallDeadline: DispatchWallTime, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = []) -> SDTask<Result?> {
        let result = SDTask<Result?>(queue: queue)
        let worker = result.createWorker(qos: qos, flags: flags) { self.storage.value }
        result.worker = worker
        queue.asyncAfter(wallDeadline: wallDeadline, execute: worker)
        return result
    }
}

extension SDTask {
    
    /// Suspend if `result` satisfies `predicate`.
    @discardableResult
    public func suspend(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], where predicate: @escaping (Result) -> Bool) -> SDTask<Result> {
        return self.suspend(queue: queue, qos: qos, flags: flags, where: predicate)
    }
    
    /// Suspend if `result` satisfies `predicate` with specific queue.
    @discardableResult
    public func suspend(queue: DispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], where predicate: @escaping (Result) -> Bool) -> SDTask<Result> {
        var storage: Result!
        let result = SDTask<Result>(queue: queue)
        let worker = result.createWorker(qos: qos, flags: flags) { storage }
        result.worker = worker
        self.worker.notify(qos: qos, flags: flags, queue: queue) {
            storage = self.result
            if !predicate(storage) {
                worker.perform()
            }
        }
        return result
    }
}
