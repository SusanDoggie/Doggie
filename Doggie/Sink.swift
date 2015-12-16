//
//  Sink.swift
//
//  The MIT License
//  Copyright (c) 2015 Susan Cheng. All rights reserved.
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

public class Sink<Element> {
    
    private var sinks: [(Element) -> ()]
    
    public init() {
        self.sinks = []
    }
}

extension Sink {
    
    public final func put(value: Element) {
        for sink in sinks {
            sink(value)
        }
    }
    
    public final func apply(body: (Element) -> ()) {
        sinks.append(body)
    }
}

extension Sink {
    
    /// Mapping the elements by `transform`.
    public func map<T>(transform: (Element) -> T) -> Sink<T> {
        let _sink = Sink<T>()
        self.apply {
            _sink.put(transform($0))
        }
        return _sink
    }
    
    /// Filter the elements that satisfy `predicate`.
    public func filter(includeElement: (Element) -> Bool) -> Sink<Element> {
        let _sink = Sink<Element>()
        self.apply {
            if includeElement($0) {
                _sink.put($0)
            }
        }
        return _sink
    }
    
    /// Mapping the elements by `transform` and fill the elements of `Sequence` to resulted sink.
    public func flatMap<S : SequenceType>(transform: (Element) -> S) -> Sink<S.Generator.Element> {
        let _sink = Sink<S.Generator.Element>()
        self.apply {
            for item in transform($0) {
                _sink.put(item)
            }
        }
        return _sink
    }
    
    /// Mapping the elements by `transform` and fill the non-nil elements to resulted sink.
    public func flatMap<T>(transform: (Element) -> T?) -> Sink<T> {
        let _sink = Sink<T>()
        self.apply {
            if let val = transform($0) {
                _sink.put(val)
            }
        }
        return _sink
    }
    
    public func scan<T>(var initial: T, combine: (T, Element)-> T) -> Sink<T> {
        let _sink = Sink<T>()
        _sink.put(initial)
        self.apply {
            initial = combine(initial, $0)
            _sink.put(initial)
        }
        return _sink
    }
}

/// Zip two sink
public func zip<Element1, Element2>(Sink1: Sink<Element1>, _ Sink2: Sink<Element2>) -> Sink<(Element1, Element2)> {
    let _zip = Sink<(Element1, Element2)>()
    var e1: [Element1] = []
    var e2: [Element2] = []
    Sink1.apply {
        if let first = e2.first {
            _zip.put($0, first)
            e2.removeFirst()
        } else {
            e1.append($0)
        }
    }
    Sink2.apply {
        if let first = e1.first {
            _zip.put(first, $0)
            e1.removeFirst()
        } else {
            e2.append($0)
        }
    }
    return _zip
}
