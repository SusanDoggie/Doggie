//
//  MeshGradient.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

public enum MeshGradientPatchType: CaseIterable {
    
    case coonsPatch
    
    case tensorProduct
}

@frozen
public struct MeshGradient<Color: ColorProtocol> {
    
    public let type: MeshGradientPatchType
    
    public let column: Int
    public let row: Int
    
    public let points: [Point]
    public let colors: [Color]
    
    public var transform: SDTransform = .identity
    public var opacity: Double = 1
    
    @inlinable
    @inline(__always)
    public init?(type: MeshGradientPatchType, column: Int, row: Int, points: [Point], colors: [Color]) {
        self.type = type
        self.row = row
        self.column = column
        self.points = points
        self.colors = colors
        guard self.colors.count == (row + 1) * (column + 1) else { return nil }
        guard self.patches.count == row * column else { return nil }
    }
}

extension Gradient where Color == AnyColor {
    
    @inlinable
    @inline(__always)
    public init<M>(_ gradient: Gradient<DoggieGraphics.Color<M>>) {
        self.init(type: gradient.type, column: gradient.column, row: gradient.row, points: gradient.points, colors: gradient.colors.map(GradientStop<AnyColor>.init))
        self.transform = gradient.transform
        self.opacity = gradient.opacity
    }
}

extension MeshGradient: Equatable where Color: Equatable {
    
}

extension MeshGradient: Hashable where Color: Hashable {
    
}

extension MeshGradient {
    
    @inlinable
    @inline(__always)
    public func convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) -> MeshGradient<DoggieGraphics.Color<Model>> {
        var gradient = MeshGradient<DoggieGraphics.Color<Model>>(type: self.type, column: self.column, row: self.row, points: self.points, colors: self.colors.map { $0.convert(to: colorSpace, intent: intent) })
        gradient.transform = self.transform
        gradient.opacity = self.opacity
        return gradient
    }
    
    @inlinable
    @inline(__always)
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> MeshGradient<AnyColor> {
        var gradient = MeshGradient<AnyColor>(type: self.type, column: self.column, row: self.row, points: self.points, colors: self.colors.map { $0.convert(to: colorSpace, intent: intent) })
        gradient.transform = self.transform
        gradient.opacity = self.opacity
        return gradient
    }
}

extension MeshGradient {
    
    @inlinable
    @inline(__always)
    public var patches: [CubicBezierPatch<Point>] {
        
        var result: [CubicBezierPatch<Point>] = []
        var points = self.points[...]
        
        while !points.isEmpty {
            
            let top = result.count < column ? nil : result[result.count - column]
            let left = result.count % column == 0 ? nil : result[result.count - 1]
            
            guard let m00 = top?.m30 ?? points.popFirst() else { return result }
            guard let m01 = top?.m31 ?? points.popFirst() else { return result }
            guard let m02 = top?.m32 ?? points.popFirst() else { return result }
            guard let m03 = top?.m33 ?? points.popFirst() else { return result }
            guard let m13 = points.popFirst() else { return result }
            guard let m23 = points.popFirst() else { return result }
            guard let m33 = points.popFirst() else { return result }
            guard let m32 = points.popFirst() else { return result }
            guard let m31 = points.popFirst() else { return result }
            guard let m30 = left?.m33 ?? points.popFirst() else { return result }
            guard let m20 = left?.m23 ?? points.popFirst() else { return result }
            guard let m10 = left?.m13 ?? points.popFirst() else { return result }
            
            switch type {
                
            case .coonsPatch:
                
                result.append(CubicBezierPatch(coonsPatch: m00, m01, m02, m03, m10, m13, m20, m23, m30, m31, m32, m33))
                
            case .tensorProduct:
                
                guard let m11 = points.popFirst() else { return result }
                guard let m12 = points.popFirst() else { return result }
                guard let m21 = points.popFirst() else { return result }
                guard let m22 = points.popFirst() else { return result }
                
                result.append(CubicBezierPatch(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33))
            }
        }
        
        return result
    }
    
}
