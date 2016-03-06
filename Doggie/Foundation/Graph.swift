//
//  Graph.swift
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

public struct Graph<Node : Hashable, Link> : CollectionType {
    
    public typealias Generator = GraphGenerator<Node, Link>
    
    private var table: [Node:[Node:Link]]
    
    /// Create an empty graph.
    public init() {
        table = Dictionary()
    }
    
    /// The number of links in the graph.
    ///
    /// - Complexity: O(`count of from nodes`).
    public var count: Int {
        return table.reduce(0) { $0 + $1.1.count }
    }
    
    /// - Complexity: O(1).
    @warn_unused_result
    public func generate() -> Generator {
        return Generator(_base: table.lazy.flatMap { from, to in to.lazy.map { (from, $0, $1) } }.generate())
    }
    
    /// The position of the first element in a non-empty dictionary.
    ///
    /// Identical to `endIndex` in an empty dictionary.
    ///
    /// - Complexity: Amortized O(1).
    public var startIndex: GraphIndex<Node, Link> {
        let _base = table.indices.lazy.flatMap { from in self.table[from].1.indices.lazy.map { (from, $0) } }
        return GraphIndex(base: _base, current: _base.startIndex)
    }
    
    /// The collection's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always
    /// reachable from `startIndex` by zero or more applications of
    /// `successor()`.
    ///
    /// - Complexity: Amortized O(1).
    public var endIndex: GraphIndex<Node, Link> {
        let _base = table.indices.lazy.flatMap { from in self.table[from].1.indices.lazy.map { (from, $0) } }
        return GraphIndex(base: _base, current: _base.endIndex)
    }
    
    /// - Complexity: Amortized O(1).
    public subscript(idx: GraphIndex<Node, Link>) -> Generator.Element {
        let _idx = idx.index
        let (from, to_val) = table[_idx.0]
        let (to, val) = to_val[_idx.1]
        return (from, to, val)
    }
    
    /// - Complexity: Amortized O(1).
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
    /// - Complexity: Amortized O(1).
    @warn_unused_result
    public func isLinked(from fromNode: Node, to toNode: Node) -> Bool {
        return linkValue(from: fromNode, to: toNode) != nil
    }
    
    /// - Complexity: Amortized O(1).
    @warn_unused_result
    public func linkValue(from fromNode: Node, to toNode: Node) -> Link? {
        return table[fromNode]?[toNode]
    }
    
    /// - Complexity: Amortized O(1).
    public mutating func updateLink(from fromNode: Node, to toNode: Node, with link: Link) -> Link? {
        if table[fromNode] == nil {
            table[fromNode] = [toNode: link]
            return nil
        }
        return table[fromNode]!.updateValue(link, forKey: toNode)
    }
    
    /// - Complexity: Amortized O(1).
    public mutating func removeLink(from fromNode: Node, to toNode: Node) -> Link? {
        if var list = table[fromNode], let result = list[toNode] {
            list.removeValueForKey(toNode)
            if list.count != 0 {
                table.updateValue(list, forKey: fromNode)
            } else {
                table.removeValueForKey(fromNode)
            }
            return result
        }
        return nil
    }
    
    /// `true` iff `self` contains `node`.
    ///
    /// - Complexity: O(`count of nodes`).
    @warn_unused_result
    public func contains(node: Node) -> Bool {
        if table[node] != nil {
            return true
        }
        for list in table.values where list[node] != nil {
            return true
        }
        return false
    }
    
    /// `true` iff `count == 0`.
    public var isEmpty: Bool {
        return table.isEmpty
    }
    
    /// Remove a node with all connections with it.
    ///
    /// - Complexity: O(`count of nodes`).
    public mutating func removeNode(node: Node) {
        table[node] = nil
        for (fromNode, var list) in table {
            list.removeValueForKey(node)
            if list.count != 0 {
                table.updateValue(list, forKey: fromNode)
            } else {
                table.removeValueForKey(fromNode)
            }
        }
    }
    
    /// Remove all elements.
    ///
    /// - parameter keepCapacity: If `true`, the operation preserves the
    ///   storage capacity that the collection has, otherwise the underlying
    ///   storage is released.  The default is `false`.
    ///
    /// - Complexity: O(`count of nodes`).
    public mutating func removeAll(keepCapacity keepCapacity: Bool = false) {
        table.removeAll(keepCapacity: keepCapacity)
    }
    
    /// A collection containing just the links of `self`.
    public var links: LazyMapCollection<Graph<Node, Link>, Link> {
        return self.lazy.map { $0.2 }
    }
    
    /// A set containing just the nodes of `self`.
    ///
    /// - Complexity: O(`count of nodes`).
    public var nodes: Set<Node> {
        var _nodes = Set<Node>()
        for (_node, list) in table {
            _nodes.insert(_node)
            _nodes.unionInPlace(list.keys)
        }
        return _nodes
    }
    
    /// A set of nodes which has connection with `nearNode`.
    @warn_unused_result
    public func nodes(near nearNode: Node) -> Set<Node> {
        return Set(self.nodes(from: nearNode).concat(self.nodes(to: nearNode)).lazy.map { $0.0 })
    }
    
    /// A collection of nodes which connected from `fromNode`.
    @warn_unused_result
    public func nodes(from fromNode: Node) -> AnyForwardCollection<(Node, Link)> {
        return table[fromNode]?.any ?? EmptyCollection().any
    }
    
    /// A collection of nodes which connected to `toNode`.
    @warn_unused_result
    public func nodes(to toNode: Node) -> AnyForwardCollection<(Node, Link)> {
        return table.lazy.flatMap { from, to in to[toNode].map { (from, $0) } }.any
    }
}

extension Graph: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        
        return "[\(self.map { "(from: \($0.from), to: \($0.to)): \($0.2)" }.joinWithSeparator(", "))]"
    }
    public var debugDescription: String {
        
        return "[\(self.map { "(from: \($0.from), to: \($0.to)): \($0.2)" }.joinWithSeparator(", "))]"
    }
}

public struct GraphIndex<Node : Hashable, Link> : ForwardIndexType {
    
    private typealias Base = LazyCollection<FlattenCollection<LazyMapCollection<Range<DictionaryIndex<Node, [Node : Link]>>, LazyMapCollection<Range<DictionaryIndex<Node, Link>>, (DictionaryIndex<Node, [Node : Link]>, DictionaryIndex<Node, Link>)>>>>
    
    private let base: Base
    private let current: Base.Index
    
    private var index: Base.Generator.Element {
        return base[current]
    }
    
    @warn_unused_result
    public func successor() -> GraphIndex<Node, Link> {
        return GraphIndex(base: base, current: current.successor())
    }
}

public func == <Node, Link>(lhs: GraphIndex<Node, Link>, rhs: GraphIndex<Node, Link>) -> Bool {
    return lhs.current == rhs.current
}

public struct GraphGenerator<Node : Hashable, Link> : GeneratorType, SequenceType {
    
    public typealias Element = (from: Node, to: Node, Link)
    
    private var _base: FlattenGenerator<LazyMapGenerator<DictionaryGenerator<Node, [Node : Link]>, LazyMapCollection<[Node : Link], (Node, Node, Link)>>>
    
    public mutating func next() -> Element? {
        return _base.next()
    }
}

extension GraphGenerator: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "GraphGenerator"
    }
    public var debugDescription: String {
        return "GraphGenerator"
    }
}

public struct UndirectedGraph<Node : Hashable, Link> : CollectionType {
    
    public typealias Generator = UndirectedGraphGenerator<Node, Link>
    
    private var graph: Graph<Node, Link>
    
    /// Create an empty graph.
    public init() {
        graph = Graph()
    }
    
    /// The number of links in the graph.
    ///
    /// - Complexity: O(`count of from nodes`).
    public var count: Int {
        return graph.count
    }
    
    /// - Complexity: O(1).
    @warn_unused_result
    public func generate() -> Generator {
        return Generator(base: graph.generate())
    }
    
    /// The position of the first element in a non-empty dictionary.
    ///
    /// Identical to `endIndex` in an empty dictionary.
    ///
    /// - Complexity: Amortized O(1).
    public var startIndex: UndirectedGraphIndex<Node, Link> {
        return UndirectedGraphIndex(base: graph.startIndex)
    }
    
    /// The collection's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always
    /// reachable from `startIndex` by zero or more applications of
    /// `successor()`.
    ///
    /// - Complexity: Amortized O(1).
    public var endIndex: UndirectedGraphIndex<Node, Link> {
        return UndirectedGraphIndex(base: graph.endIndex)
    }
    
    /// - Complexity: Amortized O(1).
    public subscript(idx: UndirectedGraphIndex<Node, Link>) -> Generator.Element {
        return graph[idx.base]
    }
    
    /// - Complexity: Amortized O(1).
    public subscript(fromNode: Node, toNode: Node) -> Link? {
        get {
            return linkValue(fromNode, toNode)
        }
        set {
            if newValue != nil {
                updateLink(fromNode, toNode, with: newValue!)
            } else {
                removeLink(fromNode, toNode)
            }
        }
    }
    
    /// Return `true` iff it has link with `fromNode` and `toNode`.
    ///
    /// - Complexity: Amortized O(1).
    @warn_unused_result
    public func isLinked(fromNode: Node, _ toNode: Node) -> Bool {
        return linkValue(fromNode, toNode) != nil
    }
    
    /// - Complexity: Amortized O(1).
    @warn_unused_result
    public func linkValue(fromNode: Node, _ toNode: Node) -> Link? {
        return graph.linkValue(from: fromNode, to: toNode) ?? graph.linkValue(from: toNode, to: fromNode)
    }
    
    /// - Complexity: Amortized O(1).
    public mutating func updateLink(fromNode: Node, _ toNode: Node, with link: Link) -> Link? {
        return graph.updateLink(from: fromNode, to: toNode, with: link) ?? (fromNode != toNode ? graph.removeLink(from: toNode, to: fromNode) : nil)
    }
    
    /// - Complexity: Amortized O(1).
    public mutating func removeLink(fromNode: Node, _ toNode: Node) -> Link? {
        return graph.removeLink(from: fromNode, to: toNode) ?? graph.removeLink(from: toNode, to: fromNode)
    }
    
    /// `true` iff `self` contains `node`.
    ///
    /// - Complexity: O(`count of nodes`).
    @warn_unused_result
    public func contains(node: Node) -> Bool {
        return graph.contains(node)
    }
    
    /// `true` iff `count == 0`.
    public var isEmpty: Bool {
        return graph.isEmpty
    }
    
    /// Remove a node with all connections with it.
    ///
    /// - Complexity: O(`count of nodes`).
    public mutating func removeNode(node: Node) {
        graph.removeNode(node)
    }
    
    /// Remove all elements.
    ///
    /// - parameter keepCapacity: If `true`, the operation preserves the
    ///   storage capacity that the collection has, otherwise the underlying
    ///   storage is released.  The default is `false`.
    ///
    /// - Complexity: O(`count of nodes`).
    public mutating func removeAll(keepCapacity keepCapacity: Bool = false) {
        graph.removeAll(keepCapacity: keepCapacity)
    }
    
    /// A collection containing just the links of `self`.
    public var links: LazyMapCollection<UndirectedGraph<Node, Link>, Link> {
        return self.lazy.map { $0.2 }
    }
    
    /// A set containing just the nodes of `self`.
    ///
    /// - Complexity: O(`count of nodes`).
    public var nodes: Set<Node> {
        return graph.nodes
    }
    
    /// A collection of nodes which has connection with `nearNode`.
    @warn_unused_result
    public func nodes(near nearNode: Node) -> AnyForwardCollection<(Node, Link)> {
        return graph.nodes(from: nearNode).concat(graph.table.lazy.flatMap { from, to in from != nearNode ? to[nearNode].map { (from, $0) } : nil }).any
    }
}

extension UndirectedGraph: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        
        return "[\(self.map { "(\($0.0), \($0.1)): \($0.2)" }.joinWithSeparator(", "))]"
    }
    public var debugDescription: String {
        
        return "[\(self.map { "(\($0.0), \($0.1)): \($0.2)" }.joinWithSeparator(", "))]"
    }
}

public struct UndirectedGraphIndex<Node : Hashable, Link> : ForwardIndexType {
    
    private let base: Graph<Node, Link>.Index
    
    @warn_unused_result
    public func successor() -> UndirectedGraphIndex<Node, Link> {
        return UndirectedGraphIndex(base: base.successor())
    }
}

public func == <Node, Link>(lhs: UndirectedGraphIndex<Node, Link>, rhs: UndirectedGraphIndex<Node, Link>) -> Bool {
    return lhs.base == rhs.base
}

public struct UndirectedGraphGenerator<Node : Hashable, Link> : GeneratorType, SequenceType {
    
    public typealias Element = (Node, Node, Link)
    
    private var base: Graph<Node, Link>.Generator
    
    public mutating func next() -> Element? {
        return base.next()
    }
}

extension UndirectedGraphGenerator: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "UndirectedGraphGenerator"
    }
    public var debugDescription: String {
        return "UndirectedGraphGenerator"
    }
}
