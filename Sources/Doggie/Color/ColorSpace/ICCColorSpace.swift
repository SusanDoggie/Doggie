//
//  ICCColorSpace.swift
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

import Foundation

@_versioned
protocol PCSColorModel : ColorModelProtocol {
    
    static func * (lhs: Self, rhs: Matrix) -> Self
    
    static func *= (lhs: inout Self, rhs: Matrix)
}

extension XYZColorModel : PCSColorModel {
    
}

extension LabColorModel : PCSColorModel {
    
    @_versioned
    @_inlineable
    static func * (lhs: LabColorModel, rhs: Matrix) -> LabColorModel {
        return LabColorModel(lightness: lhs.lightness * rhs.a + lhs.a * rhs.b + lhs.b * rhs.c + rhs.d, a: lhs.lightness * rhs.e + lhs.a * rhs.f + lhs.b * rhs.g + rhs.h, b: lhs.lightness * rhs.i + lhs.a * rhs.j + lhs.b * rhs.k + rhs.l)
    }
    
    @_versioned
    @_inlineable
    static func *= (lhs: inout LabColorModel, rhs: Matrix) {
        lhs = lhs * rhs
    }
}

@_versioned
@_inlineable
func _modf(_ x: Double) -> (Int, Double) {
    var _i = 0.0
    let m = modf(x, &_i)
    return (Int(_i), m)
}

@_versioned
@_inlineable
func interpolate<C : RandomAccessCollection>(_ x: Double, table: C) -> Double where C.Index == Int, C.IndexDistance == Int, C.Element == Double {
    
    let (i, m) = _modf(x / Double(table.count - 1))
    
    if i < 0 {
        return table.first!
    } else if i >= table.count - 1 {
        return table.last!
    } else {
        let offset = table.startIndex
        let a = (1 - m) * table[offset + i]
        let b = m * table[offset + i + 1]
        return a + b
    }
}

@_versioned
@_fixed_layout
struct OneDimensionalLUT {
    
    @_versioned
    let channels: Int
    
    @_versioned
    let grid: Int
    
    @_versioned
    let table: [Double]
    
    @_versioned
    @_inlineable
    func eval<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        precondition(Model.count == channels)
        
        var result = Model()
        
        for i in 0..<Model.count {
            let offset = grid * i
            result.setComponent(i, interpolate(color.component(i), table: table[offset..<offset + grid]))
        }
        
        return result
    }
}

@_versioned
@_fixed_layout
struct MultiDimensionalLUT {
    
    @_versioned
    let inputChannels: Int
    
    @_versioned
    let outputChannels: Int
    
    @_versioned
    let grids: [Int]
    
    @_versioned
    let table: [Double]
    
    @_versioned
    @_inlineable
    func eval<Source: ColorModelProtocol, Destination: ColorModelProtocol>(_ source: Source) -> Destination {
        
        precondition(Source.count == inputChannels)
        precondition(Destination.count == outputChannels)
        
        let s = grids.scan(Destination.count, *)
        
        let p0 = source.components.enumerated().map { _modf($0.1 / Double(grids[$0.0] - 1)) }
        
        func offset(_ k: Int) -> Int {
            return zip(p0.enumerated(), s).reduce(0) { $0 + (k & (1 << $1.0.0) == 0 ? $1.0.1.0 : $1.0.1.0 + 1) * $1.1 }
        }
        
        func _interpolate(level: Int, pattern: Int) -> Destination {
            
            var a = Destination()
            var b = Destination()
            
            if level == 0 {
                for i in 0..<Destination.count {
                    a.setComponent(i, table[table.startIndex + offset(pattern) + i])
                    b.setComponent(i, table[table.startIndex + offset(pattern | 1) + i])
                }
            } else {
                let _level = level - 1
                a = _interpolate(level: _level, pattern: pattern)
                b = _interpolate(level: _level, pattern: pattern | (1 << level))
            }
            
            let m = p0[level].1
            return (1 - m) * a + m * b
        }
        
        return _interpolate(level: Source.count - 1, pattern: 0)
    }
}

@_versioned
@_fixed_layout
enum ICCCurve {
    
    case identity
    case gamma(Double)
    case parametric(Double, Double, Double, Double, Double, Double, Double)
    case table([Double])
}

extension ICCCurve {
    
    @_versioned
    @_inlineable
    init() {
        self = .identity
    }
    
    @_versioned
    @_inlineable
    init(gamma: Double) {
        self = .gamma(gamma)
    }
    
    @_versioned
    @_inlineable
    init(gamma: Double, a: Double, b: Double, c: Double = 0) {
        self = .parametric(gamma, a, b, c, -b / a, c, c)
    }
    
    @_versioned
    @_inlineable
    init(gamma: Double, a: Double, b: Double, c: Double, d: Double, e: Double = 0, f: Double = 0) {
        self = .parametric(gamma, a, b, c, d, e, f)
    }
    
    @_versioned
    @_inlineable
    init(points: [Double]) {
        self = .table(points)
    }
    
    @_versioned
    @_inlineable
    func eval(_ x: Double) -> Double {
        
        switch self {
        case .identity: return x
        case let .gamma(gamma): return pow(x, gamma)
        case let .parametric(gamma, a, b, c, d, e, f):
            if x < d {
                return c * x + f
            } else {
                return pow(a * x + b, gamma) + e
            }
        case let .table(points): return interpolate(x, table: points)
        }
    }
}

@_versioned
@_fixed_layout
enum iccTransform {
    
    typealias Curves = (ICCCurve, ICCCurve, ICCCurve)
    
    case matrix(Matrix, Curves)
    case LUT0(Matrix, OneDimensionalLUT, MultiDimensionalLUT, OneDimensionalLUT)
    case LUT1(Curves)
    case LUT2(Curves, Matrix, Curves)
    case LUT3(Curves, Matrix, Curves, MultiDimensionalLUT, [ICCCurve])
}

@_versioned
@_fixed_layout
struct ICCColorSpace<Model : ColorModelProtocol, Connection : ColorSpaceBaseProtocol> : ColorSpaceBaseProtocol where Connection.Model : PCSColorModel {
    
    @_versioned
    let iccData: Data
    
    @_versioned
    let connection : Connection
    
    @_versioned
    let a2b: iccTransform
    
    @_versioned
    let b2a: iccTransform
    
    @_versioned
    let chromaticAdaptationMatrix: Matrix
}

extension ICCColorSpace {
    
    @_versioned
    @_inlineable
    var cieXYZ: CIEXYZColorSpace {
        return connection.cieXYZ
    }
    
    @_versioned
    @_inlineable
    func convertToLinear(_ color: Model) -> Model {
        
        var result = Model()
        
        switch a2b {
        case let .matrix(_, curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case .LUT0: return color
            
        case let .LUT1(curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case let .LUT2(_, _, curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case let .LUT3(_, _, _, _, curve):
            
            for i in 0..<Model.count {
                result.setComponent(i, curve[i].eval(color.component(i)))
            }
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    func convertFromLinear(_ color: Model) -> Model {
        
        var result = Model()
        
        switch b2a {
        case let .matrix(_, curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case .LUT0: return color
            
        case let .LUT1(curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case let .LUT2(_, _, curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case let .LUT3(_, _, _, _, curve):
            
            for i in 0..<Model.count {
                result.setComponent(i, curve[i].eval(color.component(i)))
            }
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    func convertLinearToConnection(_ color: Model) -> Connection.Model {
        
        var result = Connection.Model()
        
        switch a2b {
        case let .matrix(matrix, _):
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
            result *= matrix
            
        case let .LUT0(matrix, i, lut, o):
            
            var color = color
            
            if var xyz = color as? XYZColorModel {
                xyz *= matrix
                color = xyz as! Model
            }
            
            color = i.eval(color)
            
            result = lut.eval(color)
            
            result = o.eval(result)
            
        case .LUT1:
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
        case let .LUT2(B, matrix, _):
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
            result *= matrix
            
            result.setComponent(0, B.0.eval(color.component(0)))
            result.setComponent(1, B.1.eval(color.component(1)))
            result.setComponent(2, B.2.eval(color.component(2)))
            
        case let .LUT3(B, matrix, M, lut, _):
            
            result = lut.eval(color)
            
            result.setComponent(0, M.0.eval(result.component(0)))
            result.setComponent(1, M.1.eval(result.component(1)))
            result.setComponent(2, M.2.eval(result.component(2)))
            
            result *= matrix
            
            result.setComponent(0, B.0.eval(result.component(0)))
            result.setComponent(1, B.1.eval(result.component(1)))
            result.setComponent(2, B.2.eval(result.component(2)))
            
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromConnection(_ color: Connection.Model) -> Model {
        
        var result = Model()
        
        switch b2a {
        case let .matrix(matrix, _):
            
            var color = color
            
            color *= matrix
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
        case let .LUT0(matrix, i, lut, o):
            
            var color = color
            
            if color is XYZColorModel {
                color *= matrix
            }
            
            color = i.eval(color)
            
            result = lut.eval(color)
            
            result = o.eval(result)
            
        case .LUT1:
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
        case let .LUT2(B, matrix, _):
            
            var color = color
            
            color.setComponent(0, B.0.eval(color.component(0)))
            color.setComponent(1, B.1.eval(color.component(1)))
            color.setComponent(2, B.2.eval(color.component(2)))
            
            color *= matrix
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
        case let .LUT3(B, matrix, M, lut, _):
            
            var color = color
            
            color.setComponent(0, B.0.eval(color.component(0)))
            color.setComponent(1, B.1.eval(color.component(1)))
            color.setComponent(2, B.2.eval(color.component(2)))
            
            color *= matrix
            
            color.setComponent(0, M.0.eval(color.component(0)))
            color.setComponent(1, M.1.eval(color.component(1)))
            color.setComponent(2, M.2.eval(color.component(2)))
            
            result = lut.eval(color)
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        return self.connection._convertToXYZ(self.convertLinearToConnection(color))
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return self.convertLinearFromConnection(self.connection._convertFromXYZ(color))
    }
}

