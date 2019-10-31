//
//  SVGConvolveMatrixEffect.swift
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

public struct SVGConvolveMatrixEffect : SVGEffectElement {
    
    public var region: Rect?
    
    public var source: SVGEffect.Source
    
    public var matrix: [Double]
    public var bias: Double
    public var orderX: Int
    public var orderY: Int
    public var edgeMode: EdgeMode
    public var preserveAlpha: Bool
    
    public var sources: [SVGEffect.Source] {
        return [source]
    }
    
    public init(source: SVGEffect.Source = .source, matrix: [Double], bias: Double, orderX: Int, orderY: Int, edgeMode: EdgeMode, preserveAlpha: Bool) {
        precondition(orderX > 0, "nonpositive width is not allowed.")
        precondition(orderY > 0, "nonpositive height is not allowed.")
        precondition(orderX * orderY == matrix.count, "mismatch matrix count.")
        self.source = source
        self.matrix = matrix
        self.bias = bias
        self.orderX = orderX
        self.orderY = orderY
        self.edgeMode = edgeMode
        self.preserveAlpha = preserveAlpha
    }
    
    public enum EdgeMode {
        case duplicate
        case wrap
        case none
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        return sources[source]?.inset(dx: -0.5 * Double(orderX + 1), dy: -0.5 * Double(orderY + 1))
    }
}