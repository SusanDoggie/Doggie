//
//  SDTriggerNode.swift
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

open class SDTriggerGraph<Value> : Collection {
    
    public typealias Index = SDTriggerGraphIndex<Value>
    public typealias Iterator = SDTriggerGraphIterator<Value>
    public typealias NodeID = SDTriggerNode.Identifier
    
    fileprivate var graph: Graph<NodeID, Value>
    fileprivate let lck: SDLock
    
    fileprivate var identifier: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
    
    public init() {
        graph = Graph()
        lck = SDLock()
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
    
    public func index(after i: Index) -> Index {
        return Index(base: graph.index(after: i.base))
    }
    
    public subscript(position: Index) -> Iterator.Element {
        return graph[position.base]
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
    
    public func contains(_ node: NodeID) -> Bool {
        return lck.synchronized { graph.contains(node) }
    }
    
    public var isEmpty: Bool {
        return lck.synchronized { graph.isEmpty }
    }
    
    public func removeNode(_ node: NodeID) {
        lck.synchronized { graph.removeNode(node) }
    }
    
    public func removeAll(keepingCapacity: Bool = false) {
        lck.synchronized { graph.removeAll(keepingCapacity: keepingCapacity) }
    }
    
    public var nodes: Set<NodeID> {
        return lck.synchronized { graph.nodes }
    }
    public func nodes(near nearNode: NodeID) -> Set<NodeID> {
        return lck.synchronized { graph.nodes(near: nearNode) }
    }
    public func nodes(from fromNode: NodeID) -> AnyCollection<(NodeID, Value)> {
        return lck.synchronized { graph.nodes(from: fromNode) }
    }
    public func nodes(to toNode: NodeID) -> AnyCollection<(NodeID, Value)> {
        return lck.synchronized { graph.nodes(to: toNode) }
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(base: graph.makeIterator())
    }
}

public struct SDTriggerGraphIndex<Value> : Comparable {
    
    public typealias NodeID = SDTriggerNode.Identifier
    
    fileprivate let base: Graph<NodeID, Value>.Index
}

public func == <Value>(lhs: SDTriggerGraphIndex<Value>, rhs: SDTriggerGraphIndex<Value>) -> Bool {
    return lhs.base == rhs.base
}
public func < <Value>(lhs: SDTriggerGraphIndex<Value>, rhs: SDTriggerGraphIndex<Value>) -> Bool {
    return lhs.base < rhs.base
}

public struct SDTriggerGraphIterator<Value> : IteratorProtocol, Sequence {
    
    public typealias NodeID = SDTriggerNode.Identifier
    
    fileprivate var base: Graph<NodeID, Value>.Iterator
    
    public mutating func next() -> Graph<NodeID, Value>.Element? {
        return base.next()
    }
}

open class SDTriggerNode : Trigger {
    
    fileprivate let graphID: ObjectIdentifier
    
    public var activate: Bool = false {
        didSet {
            if activate {
                self.signal()
            }
        }
    }
    
    public var callback: ((SDTriggerNode) -> Void)?
    
    public init<Value>(graph: SDTriggerGraph<Value>) {
        self.graphID = graph.identifier
        super.init {
            if let _self = $0 as? SDTriggerNode, _self.activate {
                _self.callback?(_self)
            }
        }
    }
    public init<Value>(graph: SDTriggerGraph<Value>, callback: @escaping (SDTriggerNode) -> Void) {
        self.graphID = graph.identifier
        self.callback = callback
        super.init {
            if let _self = $0 as? SDTriggerNode, _self.activate {
                _self.callback?(_self)
            }
        }
    }
}

// MARK: SDTriggerNode Identifier

extension SDTriggerNode : Hashable {
    
    public struct Identifier : Hashable {
        
        fileprivate let graphID: ObjectIdentifier
        fileprivate let nodeID: ObjectIdentifier
        fileprivate weak var _node: SDTriggerNode?
        
        public init(node: SDTriggerNode) {
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

extension SDTriggerNode.Identifier {
    
    public func signal() {
        _node?.signal()
    }
}

// MARK: -

public func == (lhs: SDTriggerNode.Identifier, rhs: SDTriggerNode.Identifier) -> Bool {
    return lhs.nodeID == rhs.nodeID
}

public func == (lhs: SDTriggerNode, rhs: SDTriggerNode) -> Bool {
    return lhs.identifier == rhs.identifier
}
