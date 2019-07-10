//
//  Graph.swift
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

@usableFromInline
enum GraphError : Error, CaseIterable {
    case keyCollision
}

@_fixed_layout
public struct Graph<Node : Hashable, Link> : Collection {
    
    public typealias Iterator = GraphIterator<Node, Link>
    
    @usableFromInline
    var table: [Node:[Node:Link]]
    
    @inlinable
    init(table: [Node:[Node:Link]]) {
        self.table = table
    }
    
    /// Create an empty graph.
    @inlinable
    public init() {
        table = Dictionary()
    }
    
    @inlinable
    public init<S: Sequence>(uniqueKeysWithValues keysAndValues: S) where S.Element == Iterator.Element {
        do {
            try self.init(keysAndValues, uniquingKeysWith: { _, _ in throw GraphError.keyCollision })
        } catch {
            fatalError("Key collision.")
        }
    }
    
    @inlinable
    public init<S: Sequence>(_ keysAndValues: S, uniquingKeysWith combine: (Link, Link) throws -> Link) rethrows where S.Element == Iterator.Element {
        if let graph = keysAndValues as? Graph {
            self = graph
        } else {
            self.table = try Dictionary(grouping: keysAndValues) { $0.0 }.mapValues { try Dictionary($0.lazy.map { ($0.1, $0.2) }, uniquingKeysWith: combine) }
        }
    }
    
    @inlinable
    public var count: Int {
        return table.reduce(0) { $0 + $1.1.count }
    }
    
    @inlinable
    public func makeIterator() -> Iterator {
        return Iterator(base: table.lazy.flatMap { from, to in to.lazy.map { (from, $0, $1) } }.makeIterator())
    }
    
    @inlinable
    public var startIndex: GraphIndex<Node, Link> {
        return GraphIndex(index1: table.startIndex, index2: table.first?.value.startIndex)
    }
    
    @inlinable
    public var endIndex: GraphIndex<Node, Link> {
        return GraphIndex(index1: table.endIndex, index2: nil)
    }
    
    @inlinable
    public func index(after i: GraphIndex<Node, Link>) -> GraphIndex<Node, Link> {
        if i.index2 != nil {
            let _to = table[i.index1].value
            let next = _to.index(after: i.index2!)
            if next != _to.endIndex {
                return GraphIndex(index1: i.index1, index2: next)
            } else {
                let _next = table.index(after: i.index1)
                return GraphIndex(index1: _next, index2: _next == table.endIndex ? nil : table[_next].value.startIndex)
            }
        } else {
            return GraphIndex(index1: table.endIndex, index2: nil)
        }
    }
    
    @inlinable
    public subscript(position: GraphIndex<Node, Link>) -> Iterator.Element {
        let (from, to_val) = table[position.index1]
        let (to, val) = to_val[position.index2!]
        return (from, to, val)
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    public subscript(from fromNode: Node, to toNode: Node) -> Link? {
        get {
            return linkValue(from: fromNode, to: toNode)
        }
        set {
            if newValue != nil {
                updateLink(from: fromNode, to: toNode, with: newValue!)
            } else {
                removeLink(from: fromNode, to: toNode)
            }
        }
    }
    
    @inlinable
    public subscript(from fromNode: Node, to toNode: Node, default defaultValue: @autoclosure () -> Link) -> Link {
        get {
            return self[from: fromNode, to: toNode] ?? defaultValue()
        }
        set {
            self[from: fromNode, to: toNode] = newValue
        }
    }
    
    /// Return `true` iff it has link from `fromNode` to `toNode`.
    ///
    /// - complexity: Amortized O(1)
    @inlinable
    public func isLinked(from fromNode: Node, to toNode: Node) -> Bool {
        return linkValue(from: fromNode, to: toNode) != nil
    }
    
    /// Return `true` iff it has link between two nodes.
    ///
    /// - complexity: Amortized O(1)
    @inlinable
    public func isLinked(between lhs: Node, _ rhs: Node) -> Bool {
        if lhs == rhs {
            return isLinked(from: lhs, to: rhs)
        }
        return isLinked(from: lhs, to: rhs) || isLinked(from: rhs, to: lhs)
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    public func linkValue(from fromNode: Node, to toNode: Node) -> Link? {
        return table[fromNode]?[toNode]
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    public func linkValues(between lhs: Node, _ rhs: Node) -> (Link?, Link?) {
        if lhs == rhs {
            let value = linkValue(from: lhs, to: rhs)
            return (value, value)
        }
        return (linkValue(from: lhs, to: rhs), linkValue(from: rhs, to: lhs))
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    @discardableResult
    public mutating func updateLink(from fromNode: Node, to toNode: Node, with link: Link) -> Link? {
        return table[fromNode, default: [:]].updateValue(link, forKey: toNode)
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    @discardableResult
    public mutating func removeLink(from fromNode: Node, to toNode: Node) -> Link? {
        if var list = table[fromNode], let result = list[toNode] {
            list.removeValue(forKey: toNode)
            if list.count != 0 {
                table.updateValue(list, forKey: fromNode)
            } else {
                table.removeValue(forKey: fromNode)
            }
            return result
        }
        return nil
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    @discardableResult
    public mutating func removeLinks(between lhs: Node, _ rhs: Node) -> (Link?, Link?) {
        if lhs == rhs {
            let value = removeLink(from: lhs, to: rhs)
            return (value, value)
        }
        return (removeLink(from: lhs, to: rhs), removeLink(from: rhs, to: lhs))
    }
    
    /// `true` iff `self` contains `node`.
    ///
    /// - complexity: O(`count of nodes`).
    @inlinable
    public func contains(_ node: Node) -> Bool {
        if table[node] != nil {
            return true
        }
        for list in table.values where list[node] != nil {
            return true
        }
        return false
    }
    
    @inlinable
    public var isEmpty: Bool {
        return table.isEmpty
    }
    
    /// Remove a node with all connections with it.
    ///
    /// - complexity: O(`count of nodes`).
    @inlinable
    public mutating func removeNode(_ node: Node) {
        table[node] = nil
        for (fromNode, var list) in table where list.removeValue(forKey: node) != nil {
            if list.count != 0 {
                table.updateValue(list, forKey: fromNode)
            } else {
                table.removeValue(forKey: fromNode)
            }
        }
    }
    
    /// Remove all elements.
    ///
    /// - parameter keepingCapacity: If `true`, the operation preserves the
    ///   storage capacity that the collection has, otherwise the underlying
    ///   storage is released.  The default is `false`.
    ///
    /// - complexity: O(`count of nodes`).
    @inlinable
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        table.removeAll(keepingCapacity: keepCapacity)
    }
    
    /// A collection containing just the links of `self`.
    @inlinable
    public var links: LazyMapCollection<Graph<Node, Link>, Link> {
        return self.lazy.map { $0.2 }
    }
    
    /// A set containing just the nodes of `self`.
    ///
    /// - complexity: O(`count of nodes`).
    @inlinable
    public var nodes: Set<Node> {
        var _nodes = Set<Node>()
        for (_node, list) in table {
            _nodes.insert(_node)
            _nodes.formUnion(list.keys)
        }
        return _nodes
    }
    
    /// A set of nodes which has connection with `nearNode`.
    @inlinable
    public func nodes(near nearNode: Node) -> Set<Node> {
        return Set(self.nodes(from: nearNode).concat(self.nodes(to: nearNode)).lazy.map { $0.0 })
    }
    
    /// A collection of nodes which connected from `fromNode`.
    @inlinable
    public func nodes(from fromNode: Node) -> AnyCollection<(Node, Link)> {
        return (table[fromNode]?.lazy.map { ($0.key, $0.value) }).map(AnyCollection.init) ?? AnyCollection(EmptyCollection())
    }
    
    /// A collection of nodes which connected to `toNode`.
    @inlinable
    public func nodes(to toNode: Node) -> AnyCollection<(Node, Link)> {
        return AnyCollection(table.lazy.compactMap { from, list in list[toNode].map { (from, $0) } })
    }
    
    @inlinable
    public func filter(_ isIncluded: (Iterator.Element) throws -> Bool) rethrows -> Graph {
        return try Graph(table: Dictionary(uniqueKeysWithValues: table.compactMap { from, list in
            let list = try list.filter { try isIncluded((from, $0, $1)) }
            return list.count == 0 ? nil : (from, list)
        }))
    }
    
    @inlinable
    public func mapValues<T>(_ transform: (Link) throws -> T) rethrows -> Graph<Node, T> {
        return try Graph<Node, T>(table: table.mapValues { try $0.mapValues(transform) })
    }
    
    @inlinable
    public func compactMapValues<T>(_ transform: (Link) throws -> T?) rethrows -> Graph<Node, T> {
        return try Graph<Node, T>(table: table.mapValues { try $0.compactMapValues(transform) })
    }
    
    @inlinable
    public mutating func merge<S: Sequence>(_ keysAndValues: S, uniquingKeysWith combine: (Link, Link) throws -> Link) rethrows where S.Element == (Node, Node, Link) {
        for (key, list) in Dictionary(grouping: keysAndValues, by: { $0.0 }) {
            try table[key, default: [:]].merge(list.lazy.map { ($0.1, $0.2) }, uniquingKeysWith: combine)
        }
    }
    
    @inlinable
    public func merging<S: Sequence>(_ keysAndValues: S, uniquingKeysWith combine: (Link, Link) throws -> Link) rethrows -> Graph where S.Element == (Node, Node, Link) {
        var result = self
        try result.merge(keysAndValues, uniquingKeysWith: combine)
        return result
    }
}

extension Graph: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "[\(self.map { "(from: \($0.from), to: \($0.to)): \($0.2)" }.joined(separator: ", "))]"
    }
}

extension Graph where Node == AnyHashable {
    
    /// Return `true` iff it has link from `fromNode` to `toNode`.
    ///
    /// - complexity: Amortized O(1)
    @inlinable
    public func isLinked<ConcreteElement : Hashable>(from fromNode: ConcreteElement, to toNode: ConcreteElement) -> Bool {
        return self.isLinked(from: AnyHashable(fromNode), to: AnyHashable(toNode))
    }
    
    /// Return `true` iff it has link between two nodes.
    ///
    /// - complexity: Amortized O(1)
    @inlinable
    public func isLinked<ConcreteElement : Hashable>(between node1: ConcreteElement, _ node2: ConcreteElement) -> Bool {
        return self.isLinked(between: AnyHashable(node1), AnyHashable(node2))
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    public func linkValue<ConcreteElement : Hashable>(from fromNode: ConcreteElement, to toNode: ConcreteElement) -> Link? {
        return self.linkValue(from: AnyHashable(fromNode), to: AnyHashable(toNode))
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    public func linkValues<ConcreteElement : Hashable>(between node1: ConcreteElement, _ node2: ConcreteElement) -> (Link?, Link?) {
        return self.linkValues(between: AnyHashable(node1), AnyHashable(node2))
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    @discardableResult
    public mutating func updateLink<ConcreteElement : Hashable>(from fromNode: ConcreteElement, to toNode: ConcreteElement, with link: Link) -> Link? {
        return self.updateLink(from: AnyHashable(fromNode), to: AnyHashable(toNode), with: link)
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    @discardableResult
    public mutating func removeLink<ConcreteElement : Hashable>(from fromNode: ConcreteElement, to toNode: ConcreteElement) -> Link? {
        return self.removeLink(from: AnyHashable(fromNode), to: AnyHashable(toNode))
    }
    
    /// - complexity: Amortized O(1)
    @inlinable
    @discardableResult
    public mutating func removeLinks<ConcreteElement : Hashable>(between node1: ConcreteElement, _ node2: ConcreteElement) -> (Link?, Link?) {
        return self.removeLinks(between: AnyHashable(node1), AnyHashable(node2))
    }
    
    /// `true` iff `self` contains `node`.
    ///
    /// - complexity: O(`count of nodes`).
    @inlinable
    public func contains<ConcreteElement : Hashable>(_ node: ConcreteElement) -> Bool {
        return self.contains(AnyHashable(node))
    }
    
    /// Remove a node with all connections with it.
    ///
    /// - complexity: O(`count of nodes`).
    @inlinable
    public mutating func removeNode<ConcreteElement : Hashable>(_ node: ConcreteElement) {
        self.removeNode(AnyHashable(node))
    }
    /// A set of nodes which has connection with `nearNode`.

    @inlinable
    public func nodes<ConcreteElement : Hashable>(near nearNode: ConcreteElement) -> Set<Node> {
        return self.nodes(near: AnyHashable(nearNode))
    }
    
    /// A collection of nodes which connected from `fromNode`.
    @inlinable
    public func nodes<ConcreteElement : Hashable>(from fromNode: ConcreteElement) -> AnyCollection<(Node, Link)> {
        return self.nodes(from: AnyHashable(fromNode))
    }
    
    /// A collection of nodes which connected to `toNode`.
    @inlinable
    public func nodes<ConcreteElement : Hashable>(to toNode: ConcreteElement) -> AnyCollection<(Node, Link)> {
        return self.nodes(to: AnyHashable(toNode))
    }
}

@_fixed_layout
public struct GraphIndex<Node : Hashable, Link> : Hashable, Comparable {
    
    @usableFromInline
    let index1: DictionaryIndex<Node, [Node:Link]>
    
    @usableFromInline
    let index2: DictionaryIndex<Node, Link>?
    
    @inlinable
    init(index1: DictionaryIndex<Node, [Node:Link]>, index2: DictionaryIndex<Node, Link>?) {
        self.index1 = index1
        self.index2 = index2
    }
    
}

extension GraphIndex {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(index1)
        hasher.combine(index2)
    }
}

@inlinable
public func < <Node, Link>(lhs: GraphIndex<Node, Link>, rhs: GraphIndex<Node, Link>) -> Bool {
    if lhs.index1 < rhs.index1 {
        return true
    } else if lhs.index1 == rhs.index1 && lhs.index2 != nil && rhs.index2 != nil && lhs.index2! < rhs.index2! {
        return true
    }
    return false
}

@_fixed_layout
public struct GraphIterator<Node : Hashable, Link> : IteratorProtocol, Sequence {
    
    public typealias Element = (from: Node, to: Node, value: Link)
    
    @usableFromInline
    var base: FlattenSequence<LazyMapCollection<[Node : [Node : Link]], LazyMapCollection<[Node : Link], (Node, Node, Link)>>>.Iterator
    
    @inlinable
    init(base: FlattenSequence<LazyMapCollection<[Node : [Node : Link]], LazyMapCollection<[Node : Link], (Node, Node, Link)>>>.Iterator) {
        self.base = base
    }
    
    @inlinable
    public mutating func next() -> Element? {
        return base.next()
    }
}

extension GraphIterator: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "GraphIterator"
    }
}
