//
//  SDSink.swift
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

public class SDSink<Element> {
    
    private var sinks: [(Element) -> ()]
    
    public init() {
        self.sinks = []
    }
}

extension SDSink {
    
    public final func put(value: Element) {
        for sink in sinks {
            sink(value)
        }
    }
    
    public final func apply(body: (Element) -> ()) {
        sinks.append(body)
    }
}

extension SDSink {
    
    /// Mapping the elements by `transform`.
    @warn_unused_result
    public func map<T>(transform: (Element) -> T) -> SDSink<T> {
        let _sink = SDSink<T>()
        self.apply {
            _sink.put(transform($0))
        }
        return _sink
    }
    
    /// Filter the elements that satisfy `predicate`.
    @warn_unused_result
    public func filter(includeElement: (Element) -> Bool) -> SDSink<Element> {
        let _sink = SDSink<Element>()
        self.apply {
            if includeElement($0) {
                _sink.put($0)
            }
        }
        return _sink
    }
    
    /// Mapping the elements by `transform` and fill the elements of `Sequence` to resulted sink.
    @warn_unused_result
    public func flatMap<S : SequenceType>(transform: (Element) -> S) -> SDSink<S.Generator.Element> {
        let _sink = SDSink<S.Generator.Element>()
        self.apply {
            for item in transform($0) {
                _sink.put(item)
            }
        }
        return _sink
    }
    
    /// Mapping the elements by `transform` and fill the non-nil elements to resulted sink.
    @warn_unused_result
    public func flatMap<T>(transform: (Element) -> T?) -> SDSink<T> {
        let _sink = SDSink<T>()
        self.apply {
            if let val = transform($0) {
                _sink.put(val)
            }
        }
        return _sink
    }
    
    @warn_unused_result
    public func scan<T>(var initial: T, combine: (T, Element)-> T) -> SDSink<T> {
        let _sink = SDSink<T>()
        _sink.put(initial)
        self.apply {
            initial = combine(initial, $0)
            _sink.put(initial)
        }
        return _sink
    }
    
    @warn_unused_result
    public func throttle<T>(sink: SDSink<T>) -> SDSink<(Element, [T])> {
        let _throttle = SDSink<(Element, [T])>()
        var e: [T] = []
        var lck = SDSpinLock()
        self.apply { val in
            lck.synchronized {
                _throttle.put((val, e))
                e.removeAll(keepCapacity: true)
            }
        }
        sink.apply { val in
            lck.synchronized { e.append(val) }
        }
        return _throttle
    }
}

/// Zip two sink
@warn_unused_result
public func zip<Element1, Element2>(sink1: SDSink<Element1>, _ sink2: SDSink<Element2>) -> SDSink<(Element1, Element2)> {
    let _zip = SDSink<(Element1, Element2)>()
    var e1: [Element1] = []
    var e2: [Element2] = []
    var lck = SDSpinLock()
    sink1.apply { val in
        lck.synchronized {
            if let first = e2.first {
                _zip.put(val, first)
                e2.removeFirst()
            } else {
                e1.append(val)
            }
        }
    }
    sink2.apply { val in
        lck.synchronized {
            if let first = e1.first {
                _zip.put(first, val)
                e1.removeFirst()
            } else {
                e2.append(val)
            }
        }
    }
    return _zip
}
