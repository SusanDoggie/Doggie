//
//  SDTask.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

public let SDDefaultDispatchQueue: DispatchQueue = {
    if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
        return DispatchQueue(label: "com.SusanDoggie.Thread", attributes: .concurrent, autoreleaseFrequency: .workItem)
    } else {
        return DispatchQueue(label: "com.SusanDoggie.Thread", attributes: .concurrent)
    }
}()

public class SDTask<Result> {
    
    private let queue: DispatchQueue
    private var worker: DispatchWorkItem!
    
    private let lck = SDConditionLock()
    
    private var storage: Result?
    
    private init(queue: DispatchQueue) {
        self.queue = queue
    }
}

extension SDTask {
    
    private func createWorker(qos: DispatchQoS, flags: DispatchWorkItemFlags, block: @escaping () -> Result?) -> DispatchWorkItem {
        return DispatchWorkItem(qos: qos, flags: flags) { [weak self] in
            let value = block()
            guard let _self = self else { return }
            _self.lck.synchronized {
                _self.storage = value
                _self.lck.broadcast()
            }
        }
    }
    
    /// Create a SDTask and compute block.
    @discardableResult
    public static func async(queue: DispatchQueue = SDDefaultDispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], block: @escaping () -> Result) -> SDTask {
        let task = SDTask(queue: queue)
        task.worker = task.createWorker(qos: qos, flags: flags, block: block)
        task.queue.async(execute: task.worker)
        return task
    }
    
    @discardableResult
    public static func capture(queue: DispatchQueue = SDDefaultDispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], completeHandler: (@escaping (Result) -> Void) -> Void) -> SDTask {
        var storage: Result?
        let task = SDTask(queue: queue)
        task.worker = task.createWorker(qos: qos, flags: flags) { storage! }
        completeHandler { result in
            storage = result
            task.queue.async(execute: task.worker)
        }
        return task
    }
}

extension SDTask where Result == Void {
    
    @discardableResult
    public static func capture(queue: DispatchQueue = SDDefaultDispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], completeHandler: (@escaping () -> Void) -> Void) -> SDTask {
        let task = SDTask(queue: queue)
        task.worker = task.createWorker(qos: qos, flags: flags) { return }
        completeHandler { task.queue.async(execute: task.worker) }
        return task
    }
}

extension SDTask {
    
    /// Return `true` iff task is completed.
    public var completed: Bool {
        return lck.synchronized { storage != nil }
    }
    
    @discardableResult
    public func wait(until time: DispatchWallTime) -> Bool {
        return lck.wait(for: storage != nil, until: time)
    }
    
    /// Result of task.
    public var result: Result {
        lck.wait(for: storage != nil)
        return storage!
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
        var storage: Result?
        let result = SDTask<R>(queue: queue)
        let worker = result.createWorker(qos: qos, flags: flags) { storage.map(block) }
        result.worker = worker
        self.worker.notify(qos: qos, flags: flags, queue: queue) {
            storage = self.storage
            worker.perform()
        }
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
        var storage: Result?
        let result = SDTask<Result>(queue: queue)
        let worker = result.createWorker(qos: qos, flags: flags) { storage }
        result.worker = worker
        self.worker.notify(qos: qos, flags: flags, queue: queue) {
            if let value = self.storage, !predicate(value) {
                storage = value
            }
            worker.perform()
        }
        return result
    }
}
