//
//  Graph.swift
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

@_fixed_layout
public struct Graph<Node : Hashable, Link> : Collection {
    
    public typealias Iterator = GraphIterator<Node, Link>
    
    @_versioned
    var table: [Node:[Node:Link]]
    
    /// Create an empty graph.
    @_inlineable
    public init() {
        table = Dictionary()
    }
    
    @_inlineable
    public var count: Int {
        return table.reduce(0) { $0 + $1.1.count }
    }
    
    @_inlineable
    public func makeIterator() -> Iterator {
        return Iterator(base: table.lazy.flatMap { from, to in to.lazy.map { (from, $0, $1) } }.makeIterator())
    }
    
    @_inlineable
    public var startIndex: GraphIndex<Node, Link> {
        return GraphIndex(index1: table.startIndex, index2: table.first?.value.startIndex)
    }
    
    @_inlineable
    public var endIndex: GraphIndex<Node, Link> {
        return GraphIndex(index1: table.endIndex, index2: nil)
    }
    
    @_inlineable
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
    
    public subscript(position: GraphIndex<Node, Link>) -> Iterator.Element {
        let (from, to_val) = table[position.index1]
        let (to, val) = to_val[position.index2!]
        return (from, to, val)
    }
    
    /// - complexity: Amortized O(1)
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
    
    /// Return `true` iff it has link from `fromNode` to `toNode`.
    ///
    /// - complexity: Amortized O(1)
    @_inlineable
    public func isLinked(from fromNode: Node, to toNode: Node) -> Bool {
        return linkValue(from: fromNode, to: toNode) != nil
    }
    
    /// Return `true` iff it has link between two nodes.
    ///
    /// - complexity: Amortized O(1)
    @_inlineable
    public func isLinked(between lhs: Node, _ rhs: Node) -> Bool {
        if lhs == rhs {
            return isLinked(from: lhs, to: rhs)
        }
        return isLinked(from: lhs, to: rhs) || isLinked(from: rhs, to: lhs)
    }
    
    /// - complexity: Amortized O(1)
    @_inlineable
    public func linkValue(from fromNode: Node, to toNode: Node) -> Link? {
        return table[fromNode]?[toNode]
    }
    
    /// - complexity: Amortized O(1)
    @_inlineable
    public func linkValues(between lhs: Node, _ rhs: Node) -> (Link?, Link?) {
        if lhs == rhs {
            let value = linkValue(from: lhs, to: rhs)
            return (value, value)
        }
        return (linkValue(from: lhs, to: rhs), linkValue(from: rhs, to: lhs))
    }
    
    /// - complexity: Amortized O(1)
    @discardableResult
    @_inlineable
    public mutating func updateLink(from fromNode: Node, to toNode: Node, with link: Link) -> Link? {
        if table[fromNode] == nil {
            table[fromNode] = [toNode: link]
            return nil
        }
        return table[fromNode]!.updateValue(link, forKey: toNode)
    }
    
    /// - complexity: Amortized O(1)
    @discardableResult
    @_inlineable
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
    @discardableResult
    @_inlineable
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
    @_inlineable
    public func contains(_ node: Node) -> Bool {
        if table[node] != nil {
            return true
        }
        for list in table.values where list[node] != nil {
            return true
        }
        return false
    }
    
    @_inlineable
    public var isEmpty: Bool {
        return table.isEmpty
    }
    
    /// Remove a node with all connections with it.
    ///
    /// - complexity: O(`count of nodes`).
    @_inlineable
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
    @_inlineable
    public mutating func removeAll(keepingCapacity: Bool = false) {
        table.removeAll(keepingCapacity: keepingCapacity)
    }
    
    /// A collection containing just the links of `self`.
    @_inlineable
    public var links: LazyMapCollection<Graph<Node, Link>, Link> {
        return self.lazy.map { $0.2 }
    }
    
    /// A set containing just the nodes of `self`.
    ///
    /// - complexity: O(`count of nodes`).
    @_inlineable
    public var nodes: Set<Node> {
        var _nodes = Set<Node>()
        for (_node, list) in table {
            _nodes.insert(_node)
            _nodes.formUnion(list.keys)
        }
        return _nodes
    }
    
    /// A set of nodes which has connection with `nearNode`.
    @_inlineable
    public func nodes(near nearNode: Node) -> Set<Node> {
        return Set(self.nodes(from: nearNode).concat(self.nodes(to: nearNode)).lazy.map { $0.0 })
    }
    
    /// A collection of nodes which connected from `fromNode`.
    @_inlineable
    public func nodes(from fromNode: Node) -> AnyCollection<(Node, Link)> {
        return (table[fromNode]?.lazy.map { ($0.key, $0.value) }).map(AnyCollection.init) ?? AnyCollection(EmptyCollection())
    }
    
    /// A collection of nodes which connected to `toNode`.
    @_inlineable
    public func nodes(to toNode: Node) -> AnyCollection<(Node, Link)> {
        return AnyCollection(table.lazy.flatMap { arg in arg.1[toNode].map { (arg.0, $0) } })
    }
}

extension Graph: CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "[\(self.map { "(from: \($0.from), to: \($0.to)): \($0.2)" }.joined(separator: ", "))]"
    }
}

extension Graph where Node == AnyHashable {
    
    /// Return `true` iff it has link from `fromNode` to `toNode`.
    ///
    /// - complexity: Amortized O(1)
    @_inlineable
    public func isLinked<ConcreteElement : Hashable>(from fromNode: ConcreteElement, to toNode: ConcreteElement) -> Bool {
        return self.isLinked(from: AnyHashable(fromNode), to: AnyHashable(toNode))
    }
    
    /// Return `true` iff it has link between two nodes.
    ///
    /// - complexity: Amortized O(1)
    @_inlineable
    public func isLinked<ConcreteElement : Hashable>(between node1: ConcreteElement, _ node2: ConcreteElement) -> Bool {
        return self.isLinked(between: AnyHashable(node1), AnyHashable(node2))
    }
    
    /// - complexity: Amortized O(1)
    @_inlineable
    public func linkValue<ConcreteElement : Hashable>(from fromNode: ConcreteElement, to toNode: ConcreteElement) -> Link? {
        return self.linkValue(from: AnyHashable(fromNode), to: AnyHashable(toNode))
    }
    
    /// - complexity: Amortized O(1)
    @_inlineable
    public func linkValues<ConcreteElement : Hashable>(between node1: ConcreteElement, _ node2: ConcreteElement) -> (Link?, Link?) {
        return self.linkValues(between: AnyHashable(node1), AnyHashable(node2))
    }
    
    /// - complexity: Amortized O(1)
    @discardableResult
    @_inlineable
    public mutating func updateLink<ConcreteElement : Hashable>(from fromNode: ConcreteElement, to toNode: ConcreteElement, with link: Link) -> Link? {
        return self.updateLink(from: AnyHashable(fromNode), to: AnyHashable(toNode), with: link)
    }
    
    /// - complexity: Amortized O(1)
    @discardableResult
    @_inlineable
    public mutating func removeLink<ConcreteElement : Hashable>(from fromNode: ConcreteElement, to toNode: ConcreteElement) -> Link? {
        return self.removeLink(from: AnyHashable(fromNode), to: AnyHashable(toNode))
    }
    
    /// - complexity: Amortized O(1)
    @discardableResult
    @_inlineable
    public mutating func removeLinks<ConcreteElement : Hashable>(between node1: ConcreteElement, _ node2: ConcreteElement) -> (Link?, Link?) {
        return self.removeLinks(between: AnyHashable(node1), AnyHashable(node2))
    }
    
    /// `true` iff `self` contains `node`.
    ///
    /// - complexity: O(`count of nodes`).
    @_inlineable
    public func contains<ConcreteElement : Hashable>(_ node: ConcreteElement) -> Bool {
        return self.contains(AnyHashable(node))
    }
    
    /// Remove a node with all connections with it.
    ///
    /// - complexity: O(`count of nodes`).
    @_inlineable
    public mutating func removeNode<ConcreteElement : Hashable>(_ node: ConcreteElement) {
        self.removeNode(AnyHashable(node))
    }
    /// A set of nodes which has connection with `nearNode`.

    @_inlineable
    public func nodes<ConcreteElement : Hashable>(near nearNode: ConcreteElement) -> Set<Node> {
        return self.nodes(near: AnyHashable(nearNode))
    }
    
    /// A collection of nodes which connected from `fromNode`.
    @_inlineable
    public func nodes<ConcreteElement : Hashable>(from fromNode: ConcreteElement) -> AnyCollection<(Node, Link)> {
        return self.nodes(from: AnyHashable(fromNode))
    }
    
    /// A collection of nodes which connected to `toNode`.
    @_inlineable
    public func nodes<ConcreteElement : Hashable>(to toNode: ConcreteElement) -> AnyCollection<(Node, Link)> {
        return self.nodes(to: AnyHashable(toNode))
    }
}

@_fixed_layout
public struct GraphIndex<Node : Hashable, Link> : Comparable {
    
    @_versioned
    let index1: DictionaryIndex<Node, [Node:Link]>
    
    @_versioned
    let index2: DictionaryIndex<Node, Link>?
    
    @_versioned
    @_inlineable
    init(index1: DictionaryIndex<Node, [Node:Link]>, index2: DictionaryIndex<Node, Link>?) {
        self.index1 = index1
        self.index2 = index2
    }
    
}

@_inlineable
public func == <Node, Link>(lhs: GraphIndex<Node, Link>, rhs: GraphIndex<Node, Link>) -> Bool {
    return lhs.index1 == rhs.index1 && lhs.index2 == rhs.index2
}
@_inlineable
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
    
    public typealias Element = (from: Node, to: Node, Link)
    
    @_versioned
    var base: FlattenIterator<LazyMapIterator<DictionaryIterator<Node, [Node : Link]>, LazyMapCollection<[Node : Link], (Node, Node, Link)>>>
    
    @_versioned
    @_inlineable
    init(base: FlattenIterator<LazyMapIterator<DictionaryIterator<Node, [Node : Link]>, LazyMapCollection<[Node : Link], (Node, Node, Link)>>>) {
        self.base = base
    }
    
    @_inlineable
    public mutating func next() -> Element? {
        return base.next()
    }
}

extension GraphIterator: CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "GraphIterator"
    }
}
