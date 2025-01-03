//
//  Cache.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
public struct Cache<Key: Hashable>: Collection, ExpressibleByDictionaryLiteral {
    
    public typealias Index = Dictionary<Key, Any>.Index
    public typealias Element = (Key, Any)
    
    @usableFromInline
    var base: Base
    
    @inlinable
    public init() {
        self.base = Base(table: Dictionary())
    }
    
    @inlinable
    public init(minimumCapacity: Int) {
        self.base = Base(table: Dictionary(minimumCapacity: minimumCapacity))
    }
    
    @inlinable
    public init<S: Sequence>(uniqueKeysWithValues keysAndValues: S) where S.Element == Element {
        self.base = Base(table: Dictionary(uniqueKeysWithValues: keysAndValues))
    }
    
    @inlinable
    public init<S: Sequence>(_ keysAndValues: S, uniquingKeysWith combine: (Any, Any) throws -> Any) rethrows where S.Element == Element {
        self.base = Base(table: try Dictionary(keysAndValues, uniquingKeysWith: combine))
    }
    
    @inlinable
    public init(dictionaryLiteral elements: (Key, Any)...) {
        self.base = Base(table: Dictionary(uniqueKeysWithValues: elements))
    }
}

extension Cache {
    
    @usableFromInline
    final class Base {
        
        @usableFromInline
        let lck = NSLock()
        
        @usableFromInline
        var table: [Key: Any]
        
        @inlinable
        init(table: [Key: Any]) {
            self.table = table
        }
    }
    
    @inlinable
    public var identifier: ObjectIdentifier {
        return ObjectIdentifier(base)
    }
}

extension Cache {
    
    @inlinable
    public var startIndex: Index {
        return base.lck.synchronized { base.table.startIndex }
    }
    
    @inlinable
    public var endIndex: Index {
        return base.lck.synchronized { base.table.endIndex }
    }
    
    @inlinable
    public var count: Int {
        return base.lck.synchronized { base.table.count }
    }
    
    @inlinable
    public var isEmpty: Bool {
        return base.lck.synchronized { base.table.isEmpty }
    }
    
    @inlinable
    public func index(after i: Index) -> Index {
        return base.lck.synchronized { base.table.index(after: i) }
    }
    
    @inlinable
    public subscript(position: Index) -> Element {
        return base.lck.synchronized { base.table[position] }
    }
}

extension Cache {
    
    @inlinable
    public var keys: Dictionary<Key, Any>.Keys {
        return base.lck.synchronized { base.table.keys }
    }
    
    @inlinable
    public var values: Dictionary<Key, Any>.Values {
        get {
            return base.lck.synchronized { base.table.values }
        }
        set {
            if isKnownUniquelyReferenced(&base) {
                base.lck.synchronized { base.table.values = newValue }
            } else {
                var table = base.lck.synchronized { base.table }
                table.values = newValue
                base = Base(table: table)
            }
        }
    }
}

extension Cache {
    
    @inlinable
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        if isKnownUniquelyReferenced(&base) {
            base.lck.synchronized { base.table.removeAll(keepingCapacity: keepCapacity) }
        } else {
            if keepCapacity {
                var table = base.lck.synchronized { base.table }
                table.removeAll(keepingCapacity: true)
                base = Base(table: table)
            } else {
                base = Base(table: [:])
            }
        }
    }
}

extension Cache {
    
    @inlinable
    public func load<Value>(for key: Key) -> Value? {
        return base.lck.synchronized { base.table[key] as? Value }
    }
    
    @inlinable
    public func load<Value>(for key: Key, body: () -> Value) -> Value {
        
        return base.lck.synchronized {
            
            if let object = base.table[key], let value = object as? Value {
                return value
            }
            let value = body()
            base.table[key] = value
            return value
        }
    }
    
    @inlinable
    public mutating func store<Value>(value: Value, for key: Key) {
        
        if isKnownUniquelyReferenced(&base) {
            base.lck.synchronized { base.table[key] = value }
        } else {
            var table = base.lck.synchronized { base.table }
            table[key] = value
            base = Base(table: table)
        }
    }
}
