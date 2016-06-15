//
//  OrderedSet.swift
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

private class OrderedSetNodeBase<Element : Comparable> {
    
    var left: OrderedSetNode<Element>?
    var right: OrderedSetNode<Element>?
    
    init(left: OrderedSetNode<Element>? = nil, right: OrderedSetNode<Element>? = nil) {
        self.left = left
        self.right = right
    }
}

private struct OrderedSetNode<Element : Comparable> {
    
    var value: Element
    var weight: Int
    var base: OrderedSetNodeBase<Element>
    
    init(_ value: Element) {
        self.value = value
        self.weight = 1
        self.base = OrderedSetNodeBase()
    }
}

extension OrderedSetNode {
    
    mutating func leftRotate() {
        var leftRoot = OrderedSetNode(value)
        leftRoot.base.left = base.left
        leftRoot.base.right = base.right!.left
        leftRoot.rotateIfNeed()
        self.value = base.right!.value
        self.base = OrderedSetNodeBase(left: leftRoot, right: base.right!.right)
        updateSelf()
    }
    mutating func rightRotate() {
        var rightRoot = OrderedSetNode(value)
        rightRoot.base.right = base.right
        rightRoot.base.left = base.left!.right
        rightRoot.rotateIfNeed()
        self.value = base.left!.value
        self.base = OrderedSetNodeBase(left: base.left!.left, right: rightRoot)
        updateSelf()
    }
    
    mutating func rotateIfNeed() {
        let left_weight = base.left?.weight ?? 0
        let right_weight = base.right?.weight ?? 0
        if left_weight > right_weight + 1 {
            rightRotate()
        } else if right_weight > left_weight + 1 {
            leftRotate()
        }
    }
    
    mutating func updateSelf() {
        let left_weight = base.left?.weight ?? 0
        let right_weight = base.right?.weight ?? 0
        self.weight = max(left_weight, right_weight) + 1
    }
}

extension OrderedSetNode {
    
    var left : OrderedSetNode? {
        get {
            return base.left
        }
        set {
            if isUniquelyReferencedNonObjC(&base) {
                base.left = newValue
            } else {
                base = OrderedSetNodeBase(left: newValue, right: base.right)
            }
            updateSelf()
            rotateIfNeed()
        }
    }
    
    var right : OrderedSetNode? {
        get {
            return base.right
        }
        set {
            if isUniquelyReferencedNonObjC(&base) {
                base.right = newValue
            } else {
                base = OrderedSetNodeBase(left: base.left, right: newValue)
            }
            updateSelf()
            rotateIfNeed()
        }
    }
    
    var array: [Element] {
        let _left = OptionOneCollection(left?.array).flatten()
        let _right = OptionOneCollection(right?.array).flatten()
        return Array(_left.concat(with: CollectionOfOne(value)).concat(_right))
    }
}

extension OrderedSetNode {
    
    mutating func insertOrUpdate(_ newElement: Element) {
        if value == newElement {
            value = newElement
        } else if value > newElement {
            if left == nil {
                self.left = OrderedSetNode(newElement)
            } else {
                self.left!.insertOrUpdate(newElement)
            }
        } else {
            if right == nil {
                self.right = OrderedSetNode(newElement)
            } else {
                self.right!.insertOrUpdate(newElement)
            }
        }
    }
}

public struct OrderedSet<Element : Comparable> {
    
    private var root : OrderedSetNode<Element>?
    
    public init() {
        self.root = nil
    }
}

extension OrderedSet {
    
    public var array: [Element] {
        return root?.array ?? []
    }
    
    public mutating func insert(_ member: Element) {
        
        if root == nil {
            root = OrderedSetNode(member)
        } else {
            root!.insertOrUpdate(member)
        }
    }
}
