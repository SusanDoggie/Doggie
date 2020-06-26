//
//  WeakDictionary.swift
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

@frozen
public struct WeakDictionary<Key: AnyObject, Value>: Collection {
    
    public typealias Element = (key: Key, value: Value)
    
    @usableFromInline
    var base: [ObjectIdentifier: ValueContainer] {
        didSet {
            base = base.filter { $0.value.key !== nil }
        }
    }
    
    @inlinable
    public init() {
        self.base = [:]
    }
}

extension WeakDictionary {
    
    @frozen
    @usableFromInline
    struct ValueContainer {
        
        @usableFromInline
        weak var key: Key?
        
        @usableFromInline
        let value: Value
        
        @inlinable
        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }
    
    @frozen
    public struct Index: Comparable {
        
        @usableFromInline
        let base: Dictionary<ObjectIdentifier, ValueContainer>.Index
        
        @usableFromInline
        let element: Element?
        
        @inlinable
        init(base: Dictionary<ObjectIdentifier, ValueContainer>.Index, element: Element?) {
            self.base = base
            self.element = element
        }
        
        @inlinable
        public static func < (lhs: WeakDictionary<Key, Value>.Index, rhs: WeakDictionary<Key, Value>.Index) -> Bool {
            return lhs.base < rhs.base
        }
        
        @inlinable
        public static func == (lhs: WeakDictionary<Key, Value>.Index, rhs: WeakDictionary<Key, Value>.Index) -> Bool {
            return lhs.base == rhs.base
        }
    }
}

extension WeakDictionary {
    
    @inlinable
    public var count: Int {
        return base.values.count { $0.key !== nil }
    }
    
    @inlinable
    public var isEmpty: Bool {
        return !base.values.contains { $0.key !== nil }
    }
    
    @inlinable
    public var startIndex: Index {
        for (index, (key: _, value: container)) in base.indexed() {
            if let key = container.key {
                return Index(base: index, element: (key, container.value))
            }
        }
        return self.endIndex
    }
    
    @inlinable
    public var endIndex: Index {
        return Index(base: base.endIndex, element: nil)
    }
    
    @inlinable
    public subscript(position: Index) -> Element {
        return position.element!
    }
    
    @inlinable
    public func index(after i: Index) -> Index {
        for (index, (key: _, value: container)) in base.suffix(from: i.base).indexed() {
            if let key = container.key {
                return Index(base: index, element: (key, container.value))
            }
        }
        return self.endIndex
    }
    
    @inlinable
    public func index(forKey key: Key) -> Index? {
        
        guard let index = base.index(forKey: ObjectIdentifier(key)) else { return nil }
        
        let container = base[index].value
        guard let _key = container.key, _key === key else { return nil }
        
        return Index(base: index, element: (_key, container.value))
    }
}

extension WeakDictionary {
    
    @inlinable
    public subscript(key: Key) -> Value? {
        get {
            guard let element = base[ObjectIdentifier(key)], element.key === key else { return nil }
            return element.value
        }
        set {
            base[ObjectIdentifier(key)] = newValue.map { ValueContainer(key: key, value: $0) }
        }
    }
    
    @inlinable
    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            return self[key] ?? defaultValue()
        }
        set {
            self[key] = newValue
        }
    }
}

extension WeakDictionary {
    
    @inlinable
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        base.removeAll(keepingCapacity: keepCapacity)
    }
}
