//
//  RectCollection.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public struct RectCollection {
    
    private let bounds: [Rect]
    private let minX: [(Int, Double)]
    private let maxX: [(Int, Double)]
    private let minY: [(Int, Double)]
    private let maxY: [(Int, Double)]
    
    public init() {
        self.bounds = []
        self.minX = []
        self.maxX = []
        self.minY = []
        self.maxY = []
    }
    
    public init<S : Sequence>(_ bounds: S) where S.Element == Rect {
        let bounds = Array(bounds)
        self.bounds = bounds
        self.minX = bounds.enumerated().map { ($0.offset, $0.element.minX) }.sorted { $0.1 < $1.1 }
        self.maxX = bounds.enumerated().map { ($0.offset, $0.element.maxX) }.sorted { $0.1 < $1.1 }
        self.minY = bounds.enumerated().map { ($0.offset, $0.element.minY) }.sorted { $0.1 < $1.1 }
        self.maxY = bounds.enumerated().map { ($0.offset, $0.element.maxY) }.sorted { $0.1 < $1.1 }
    }
}

extension RectCollection : RandomAccessCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return bounds.startIndex
    }
    
    public var endIndex: Int {
        return bounds.endIndex
    }
    
    public subscript(position : Int) -> Rect {
        return bounds[position]
    }
}

extension RectCollection {
    
    private func search(_ target: Double, _ elements: UnsafePointer<(Int, Double)>, _ indices: CountableRange<Int>) -> Int {
        switch indices.count {
        case 0: return indices.lowerBound
        default:
            let mid = (indices.lowerBound + indices.upperBound) >> 1
            if target < elements[mid].1 {
                if indices.lowerBound == mid || target >= elements[mid - 1].1 {
                    return mid
                } else {
                    return search(target, elements, indices.lowerBound..<mid)
                }
            } else {
                if indices.upperBound == mid + 1 || target < elements[mid + 1].1 {
                    return mid + 1
                } else {
                    return search(target, elements, mid..<indices.upperBound)
                }
            }
        }
    }
    
    public func search(x: Double) -> Set<Int> {
        let a = minX.indices.prefix(upTo: search(x, minX, minX.indices)).map { minX[$0].0 }
        let b = maxX.indices.suffix(from: search(x, maxX, maxX.indices)).map { maxX[$0].0 }
        return Set(a).intersection(b)
    }
    
    public func search(y: Double) -> Set<Int> {
        let a = minY.indices.prefix(upTo: search(y, minY, minY.indices)).map { minY[$0].0 }
        let b = maxY.indices.suffix(from: search(y, maxY, maxY.indices)).map { maxY[$0].0 }
        return Set(a).intersection(b)
    }
    
    public func search(x: ClosedRange<Double>) -> Set<Int> {
        let a = minX.indices.prefix(upTo: search(x.upperBound, minX, minX.indices)).map { minX[$0].0 }
        let b = maxX.indices.suffix(from: search(x.lowerBound, maxX, maxX.indices)).map { maxX[$0].0 }
        return Set(a).intersection(b)
    }
    
    public func search(y: ClosedRange<Double>) -> Set<Int> {
        let a = minY.indices.prefix(upTo: search(y.upperBound, minY, minY.indices)).map { minY[$0].0 }
        let b = maxY.indices.suffix(from: search(y.lowerBound, maxY, maxY.indices)).map { maxY[$0].0 }
        return Set(a).intersection(b)
    }
    
    public func search(_ point: Point) -> Set<Int> {
        return Set(search(x: point.x)).intersection(search(y: point.y))
    }
    
    public func search(contains rect: Rect) -> Set<Int> {
        return Set(search(Point(x: rect.minX, y: rect.minY))).intersection(search(Point(x: rect.maxX, y: rect.maxY)))
    }
    
    public func search(overlap rect: Rect) -> Set<Int> {
        return search(x: rect.minX...rect.maxX).intersection(search(y: rect.minY...rect.maxY))
    }
}
