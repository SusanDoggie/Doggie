//
//  WeakSet.swift
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
public struct WeakSet<Element: AnyObject>: Collection, SetAlgebra {
    
    @usableFromInline
    var base: [ObjectIdentifier: ElementContainer] {
        didSet {
            base = base.filter { $0.value.element !== nil }
        }
    }
    
    @inlinable
    public init() {
        self.base = [:]
    }
}

extension WeakSet {
    
    @frozen
    @usableFromInline
    struct ElementContainer {
        
        @usableFromInline
        weak var element: Element?
        
        @inlinable
        init(element: Element) {
            self.element = element
        }
    }
    
    @frozen
    public struct Index: Comparable {
        
        @usableFromInline
        let base: Dictionary<ObjectIdentifier, ElementContainer>.Index
        
        @usableFromInline
        let element: Element?
        
        @inlinable
        init(base: Dictionary<ObjectIdentifier, ElementContainer>.Index, element: Element?) {
            self.base = base
            self.element = element
        }
        
        @inlinable
        public static func < (lhs: WeakSet<Element>.Index, rhs: WeakSet<Element>.Index) -> Bool {
            return lhs.base < rhs.base
        }
        
        @inlinable
        public static func == (lhs: WeakSet<Element>.Index, rhs: WeakSet<Element>.Index) -> Bool {
            return lhs.base == rhs.base
        }
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension WeakSet: Sendable where Element: Sendable { }

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension WeakSet.ElementContainer: Sendable where Element: Sendable { }

extension WeakSet {
    
    @inlinable
    public var count: Int {
        return base.values.count { $0.element !== nil }
    }
    
    @inlinable
    public var isEmpty: Bool {
        return !base.values.contains { $0.element !== nil }
    }
    
    @inlinable
    public var startIndex: Index {
        for (index, (key: _, value: container)) in base.indexed() {
            if let element = container.element {
                return Index(base: index, element: element)
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
            if let element = container.element {
                return Index(base: index, element: element)
            }
        }
        return self.endIndex
    }
}

extension WeakSet {
    
    @inlinable
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        base.removeAll(keepingCapacity: keepCapacity)
    }
}

extension WeakSet {
    
    @inlinable
    public func contains(_ member: Element) -> Bool {
        return base[ObjectIdentifier(member)]?.element === member
    }
    
    @inlinable
    public func union(_ other: WeakSet<Element>) -> WeakSet<Element> {
        var copy = self
        copy.formUnion(other)
        return copy
    }
    
    @inlinable
    public func intersection(_ other: WeakSet<Element>) -> WeakSet<Element> {
        var copy = self
        copy.formIntersection(other)
        return copy
    }
    
    @inlinable
    public func subtracting(_ other: WeakSet<Element>) -> WeakSet<Element> {
        var copy = self
        copy.subtract(other)
        return copy
    }
    
    @inlinable
    public func symmetricDifference(_ other: WeakSet<Element>) -> WeakSet<Element> {
        var copy = self
        copy.formSymmetricDifference(other)
        return copy
    }
    
    @inlinable
    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if let oldMember = base[ObjectIdentifier(newMember)]?.element, oldMember === newMember {
            return (false, oldMember)
        }
        base[ObjectIdentifier(newMember)] = ElementContainer(element: newMember)
        return (true, newMember)
    }
    
    @inlinable
    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        let removed = base[ObjectIdentifier(member)]?.element
        base[ObjectIdentifier(member)] = nil
        return removed
    }
    
    @inlinable
    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        let old = base[ObjectIdentifier(newMember)]?.element
        base[ObjectIdentifier(newMember)] = ElementContainer(element: newMember)
        return old
    }
    
    @inlinable
    public mutating func formUnion(_ other: WeakSet<Element>) {
        for item in other where base[ObjectIdentifier(item)]?.element == nil {
            base[ObjectIdentifier(item)] = ElementContainer(element: item)
        }
    }
    
    @inlinable
    public mutating func formIntersection(_ other: WeakSet<Element>) {
        for key in base.keys {
            if let element = base[key]?.element, !other.contains(element) {
                base[key] = nil
            }
        }
    }
    
    @inlinable
    public mutating func subtract(_ other: WeakSet<Element>) {
        for key in base.keys {
            if let element = base[key]?.element, other.contains(element) {
                base[key] = nil
            }
        }
    }
    
    @inlinable
    public mutating func formSymmetricDifference(_ other: WeakSet<Element>) {
        let temp = other.subtracting(self)
        self.subtract(other)
        self.formUnion(temp)
    }
}

extension WeakSet {
    
    @inlinable
    public static func == (lhs: WeakSet<Element>, rhs: WeakSet<Element>) -> Bool {
        for container in lhs.base.values {
            if let element = container.element, !rhs.contains(element) {
                return false
            }
        }
        return true
    }
}
