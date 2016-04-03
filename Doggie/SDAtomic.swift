//
//  SDAtomicNode.swift
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

public class SDAtomic {
    
    private static let dispatchQueue = dispatch_queue_create("com.SusanDoggie.Atomic", DISPATCH_QUEUE_CONCURRENT)
    
    private var _callback: ((SDAtomic) -> Void)
    private var flag: Int32
    
    public init(callback: ((SDAtomic) -> Void)) {
        self._callback = callback
        self.flag = 0
    }
}

extension SDAtomic {
    
    public final func signal() {
        if flag.fetchStore(2) == 0 {
            dispatch_async(SDAtomic.dispatchQueue, dispatchRunloop)
        }
    }
    
    private func dispatchRunloop() {
        while true {
            flag = 1
            self._callback(self)
            if flag.compareSet(1, 0) {
                return
            }
        }
    }
}

public class SDAtomicGraph<Value> : CollectionType {
    
    public typealias Index = SDAtomicGraphIndex<Value>
    public typealias Generator = SDAtomicGraphGenerator<Value>
    public typealias NodeID = SDAtomicNode.Identifier
    
    private var graph: Graph<NodeID, Value>
    private var lck: SDSpinLock
    
    private var identifier: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
    
    public init() {
        graph = Graph()
        lck = SDSpinLock()
    }
    
    public var startIndex : Index {
        return Index(base: graph.startIndex)
    }
    
    public var endIndex : Index {
        return Index(base: graph.endIndex)
    }
    
    public var count: Int {
        return graph.count
    }
    
    public subscript(idx: Index) -> Generator.Element {
        return graph[idx.base]
    }
    
    public subscript(from fromNode: NodeID, to toNode: NodeID) -> Value? {
        get {
            return lck.synchronized { graph[from: fromNode, to: toNode] }
        }
        set {
            if fromNode.graphID == identifier && toNode.graphID == identifier {
                lck.synchronized { graph[from: fromNode, to: toNode] = newValue }
            }
        }
    }
    
    public func contains(node: NodeID) -> Bool {
        return lck.synchronized { graph.contains(node) }
    }
    
    public var isEmpty: Bool {
        return lck.synchronized { graph.isEmpty }
    }
    
    public func removeNode(node: NodeID) {
        lck.synchronized { graph.removeNode(node) }
    }
    
    public func removeAll(keepCapacity keepCapacity: Bool = false) {
        lck.synchronized { graph.removeAll(keepCapacity: keepCapacity) }
    }
    
    public var nodes: Set<NodeID> {
        return lck.synchronized { graph.nodes }
    }
    public func nodes(near nearNode: NodeID) -> Set<NodeID> {
        return lck.synchronized { graph.nodes(near: nearNode) }
    }
    public func nodes(from fromNode: NodeID) -> AnyForwardCollection<(NodeID, Value)> {
        return lck.synchronized { graph.nodes(from: fromNode) }
    }
    public func nodes(to toNode: NodeID) -> AnyForwardCollection<(NodeID, Value)> {
        return lck.synchronized { graph.nodes(to: toNode) }
    }
    
    public func generate() -> Generator {
        return Generator(base: graph.generate())
    }
}

public struct SDAtomicGraphIndex<Value> : ForwardIndexType {
    
    public typealias NodeID = SDAtomicNode.Identifier
    
    private let base: Graph<NodeID, Value>.Index
    
    public func successor() -> SDAtomicGraphIndex<Value> {
        return SDAtomicGraphIndex(base: base.successor())
    }
}

public func == <Value>(lhs: SDAtomicGraphIndex<Value>, rhs: SDAtomicGraphIndex<Value>) -> Bool {
    return lhs.base == rhs.base
}

public struct SDAtomicGraphGenerator<Value> : GeneratorType, SequenceType {
    
    public typealias NodeID = SDAtomicNode.Identifier
    
    private var base: Graph<NodeID, Value>.Generator
    
    public mutating func next() -> Graph<NodeID, Value>.Generator.Element? {
        return base.next()
    }
}

public class SDAtomicNode : SDAtomic {
    
    private let graphID: ObjectIdentifier
    
    public var activate: Bool = false {
        didSet {
            if activate {
                self.signal()
            }
        }
    }
    
    public var callback: ((SDAtomicNode) -> Void)?
    
    public init<Value>(graph: SDAtomicGraph<Value>) {
        self.graphID = graph.identifier
        super.init {
            if let _self = $0 as? SDAtomicNode where _self.activate {
                _self.callback?(_self)
            }
        }
    }
    public init<Value>(graph: SDAtomicGraph<Value>, callback: ((SDAtomicNode) -> Void)) {
        self.graphID = graph.identifier
        self.callback = callback
        super.init {
            if let _self = $0 as? SDAtomicNode where _self.activate {
                _self.callback?(_self)
            }
        }
    }
}

// MARK: SDAtomicNode Identifier

extension SDAtomicNode : Hashable {
    
    public struct Identifier : Hashable {
        
        private let graphID: ObjectIdentifier
        private let nodeID: ObjectIdentifier
        private weak var _node: SDAtomicNode?
        
        public init(node: SDAtomicNode) {
            graphID = node.graphID
            nodeID = ObjectIdentifier(node)
            _node = node
        }
        
        public var hashValue: Int {
            return nodeID.hashValue
        }
    }
    
    public var identifier: Identifier {
        return Identifier(node: self)
    }
    
    public var hashValue: Int {
        return identifier.hashValue
    }
}

extension SDAtomicNode.Identifier {
    
    public func signal() {
        _node?.signal()
    }
}

// MARK: -

public func == (lhs: SDAtomicNode.Identifier, rhs: SDAtomicNode.Identifier) -> Bool {
    return lhs.nodeID == rhs.nodeID
}

public func == (lhs: SDAtomicNode, rhs: SDAtomicNode) -> Bool {
    return lhs.identifier == rhs.identifier
}
