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
let PCSXYZ = CIEXYZColorSpace(white: Point(x: 0.34567, y: 0.35850))

@_versioned
protocol PCSColorModel : ColorModelProtocol {
    
    var luminance: Double { get set }
    
    static func * (lhs: Self, rhs: Matrix) -> Self
    
    static func *= (lhs: inout Self, rhs: Matrix)
}

extension XYZColorModel : PCSColorModel {
    
}

extension LabColorModel : PCSColorModel {
    
    @_versioned
    @_inlineable
    var luminance: Double {
        get {
            return lightness
        }
        set {
            lightness = newValue
        }
    }
    
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
protocol NonnormalizedColorModel {
    
    static func rangeOfComponent(_ i: Int) -> ClosedRange<Double>
}

extension LuvColorModel : NonnormalizedColorModel {
    
    @_versioned
    @_inlineable
    static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        switch i {
        case 0: return 0...100
        default: return -128...128
        }
    }
}

extension LabColorModel : NonnormalizedColorModel {
    
    @_versioned
    @_inlineable
    static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        switch i {
        case 0: return 0...100
        default: return -128...128
        }
    }
}

@_versioned
@_inlineable
func _interpolate_index(_ x: Double, _ count: Int) -> (Int, Double) {
    var _i = 0.0
    let _count = count - 1
    let m = modf(x * Double(_count), &_i)
    let i = Int(_i)
    switch i {
    case ..<0: return (0, 0)
    case _count...: return (_count, 0)
    default: return (i, m)
    }
}

@_versioned
@_inlineable
func interpolate<C : RandomAccessCollection>(_ x: Double, table: C) -> Double where C.Index == Int, C.IndexDistance == Int, C.Element == Double {
    
    let (i, m) = _interpolate_index(x, table.count)
    
    let offset = table.startIndex
    
    if i == table.count - 1 {
        return table[offset + i]
    } else {
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
    init(channels: Int, grid: Int, table: [Double]) {
        self.channels = channels
        self.grid = grid
        self.table = table
    }
    
    @_versioned
    @_inlineable
    func eval<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        precondition(Model.numberOfComponents == channels)
        
        var result = Model()
        
        for i in 0..<Model.numberOfComponents {
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
    init(_ tag: iccProfile.TagData.CLUTTableView) {
        self.inputChannels = tag.inputChannels
        self.outputChannels = tag.outputChannels
        self.grids = tag.grids
        self.table = tag.table
    }
    
    @_versioned
    @_inlineable
    init(inputChannels: Int, outputChannels: Int, grids: [Int], table: [Double]) {
        self.inputChannels = inputChannels
        self.outputChannels = outputChannels
        self.grids = grids
        self.table = table
    }
    
    @_versioned
    @_inlineable
    func eval<Source: ColorModelProtocol, Destination: ColorModelProtocol>(_ source: Source) -> Destination {
        
        let position = source.components.enumerated().map { _interpolate_index($0.1, grids[$0.0]) }
        
        func _interpolate(level: Int, offset: Int) -> Destination {
            
            let _p = position[Source.numberOfComponents - level - 1]
            let _s = level == 0 ? Destination.numberOfComponents : grids[level - 1]
            
            if _p.0 == grids[level] - 1 {
                
                var r = Destination()
                
                let offset = (offset + _p.0) * _s
                
                if level == 0 {
                    for i in 0..<Destination.numberOfComponents {
                        r.setComponent(i, table[offset + i])
                    }
                } else {
                    let _level = level - 1
                    r = _interpolate(level: _level, offset: offset)
                }
                
                return r
                
            } else {
                
                var a = Destination()
                var b = Destination()
                
                let offset1 = (offset + _p.0) * _s
                let offset2 = offset1 + _s
                
                if level == 0 {
                    for i in 0..<Destination.numberOfComponents {
                        a.setComponent(i, table[offset1 + i])
                        b.setComponent(i, table[offset2 + i])
                    }
                } else {
                    let _level = level - 1
                    a = _interpolate(level: _level, offset: offset1)
                    b = _interpolate(level: _level, offset: offset2)
                }
                
                return (1 - _p.1) * a + _p.1 * b
            }
        }
        
        return _interpolate(level: Source.numberOfComponents - 1, offset: 0)
    }
}

@_versioned
@_fixed_layout
enum ICCCurve {
    
    case identity
    case gamma(Double)
    case parametric1(Double, Double, Double)
    case parametric2(Double, Double, Double, Double)
    case parametric3(Double, Double, Double, Double, Double)
    case parametric4(Double, Double, Double, Double, Double, Double, Double)
    case table([Double])
}

extension ICCCurve {
    
    @_versioned
    @_inlineable
    init?(_ tag: iccProfile.TagData) {
        
        if let curve = tag.curve {
            
            if curve.count == 0 {
                self = .identity
            } else if let gamma = curve.gamma {
                self = .gamma(gamma.value)
            } else {
                self = .table(Array(curve))
            }
        } else if let curve = tag.parametricCurve {
            
            switch curve.funcType {
            case 0: self = .gamma(curve.gamma.value)
            case 1: self = .parametric1(curve.gamma.value, curve.a.value, curve.b.value)
            case 2: self = .parametric2(curve.gamma.value, curve.a.value, curve.b.value, curve.c.value)
            case 3: self = .parametric3(curve.gamma.value, curve.a.value, curve.b.value, curve.c.value, curve.d.value)
            case 4: self = .parametric4(curve.gamma.value, curve.a.value, curve.b.value, curve.c.value, curve.d.value, curve.e.value, curve.f.value)
            default: return nil
            }
        } else {
            return nil
        }
    }
}

extension ICCCurve {
    
    @_versioned
    @_inlineable
    var inverse: ICCCurve {
        switch self {
        case .identity: return .identity
        case let .gamma(gamma): return .gamma(1 / gamma)
        case let .parametric1(gamma, a, b): return ICCCurve.parametric4(gamma, a, b, 0, -b / a, 0, 0).inverse
        case let .parametric2(gamma, a, b, c): return ICCCurve.parametric4(gamma, a, b, 0, -b / a, c, c).inverse
        case let .parametric3(gamma, a, b, c, d): return ICCCurve.parametric4(gamma, a, b, c, d, 0, 0).inverse
        case let .parametric4(gamma, a, b, c, d, e, f):
            
            let _a = pow(a, -gamma)
            let _b = -e * _a
            let _c = c == 0 ? 0 : 1 / c
            let _d = c * d + f
            let _e = a == 0 ? 0 : -b / a
            let _f = c == 0 ? 0 : -f / c
            return .parametric4(1 / gamma, _a, _b, _c, _d, _e, _f)
            
        case let .table(points):
            
            var inversed: [Double] = []
            inversed.reserveCapacity(points.count << 1)
            
            let N = Double(points.count - 1)
            
            var hint = 0
            
            func __interpolate<C : RandomAccessCollection>(_ y: Double, _ points: C) -> Double? where C.Element == Double, C.Index == Int {
                
                for (lhs, rhs) in zip(points.indexed(), points.dropFirst().indexed()) {
                    let _min: Double
                    let _max: Double
                    let _min_idx: Int
                    let _max_idx: Int
                    if lhs.element <= rhs.element {
                        _min = lhs.element
                        _max = rhs.element
                        _min_idx = lhs.index
                        _max_idx = rhs.index
                    } else {
                        _min = rhs.element
                        _max = lhs.element
                        _min_idx = rhs.index
                        _max_idx = lhs.index
                    }
                    if _min..._max ~= y {
                        hint = lhs.index
                        let m = (y - _min) / (_max - _min)
                        let a = (1 - m) * Double(_min_idx) / N
                        let b = m * Double(_max_idx) / N
                        return a + b
                    }
                }
                
                return nil
            }
            
            func _interpolate(_ y: Double) -> Double {
                
                if y == 0 && points.first?.almostZero() == true {
                    return 0
                } else if y == 1 && points.last?.almostEqual(1) == true {
                    return 1
                }
                
                if hint != points.count - 1 {
                    if let value = __interpolate(y, points.suffix(from: hint)) {
                        return value
                    }
                }
                if let value = __interpolate(y, points) {
                    return value
                }
                if let idx = points.suffix(from: hint).indexed().min(by: { abs($0.1 - y) })?.0 ?? points.indexed().min(by: { abs($0.1 - y) })?.0 {
                    return Double(idx) / N
                }
                return 0
            }
            
            let N2 = Double((points.count << 1) - 1)
            
            for i in 0..<points.count << 1 {
                inversed.append(_interpolate(Double(i) / N2))
            }
            
            return .table(inversed)
        }
    }
}

extension ICCCurve {
    
    @_versioned
    @_inlineable
    func eval(_ x: Double) -> Double {
        
        @inline(__always)
        func exteneded(_ x: Double, _ gamma: (Double) -> Double) -> Double {
            return x.sign == .plus ? gamma(x) : -gamma(-x)
        }
        
        switch self {
        case .identity: return x
        case let .gamma(gamma): return exteneded(x) { pow($0, gamma) }
        case let .parametric1(gamma, a, b):
            return exteneded(x) {
                if $0 < -b / a {
                    return 0
                } else {
                    return pow(a * $0 + b, gamma)
                }
            }
        case let .parametric2(gamma, a, b, c):
            return exteneded(x) {
                if $0 < -b / a {
                    return c
                } else {
                    return pow(a * $0 + b, gamma) + c
                }
            }
        case let .parametric3(gamma, a, b, c, d):
            return exteneded(x) {
                if $0 < d {
                    return c * $0
                } else {
                    return pow(a * $0 + b, gamma)
                }
            }
        case let .parametric4(gamma, a, b, c, d, e, f):
            return exteneded(x) {
                if $0 < d {
                    return c * $0 + f
                } else {
                    return pow(a * $0 + b, gamma) + e
                }
            }
        case let .table(points): return interpolate(x, table: points)
        }
    }
}

@_versioned
@_fixed_layout
enum iccTransform {
    
    typealias Curves = (ICCCurve, ICCCurve, ICCCurve)
    
    case monochrome(ICCCurve)
    case matrix(Matrix, Curves)
    case LUT0(Matrix, OneDimensionalLUT, MultiDimensionalLUT, OneDimensionalLUT)
    case LUT1(Curves)
    case LUT2(Curves, Matrix, Curves)
    case LUT3(Curves, MultiDimensionalLUT, [ICCCurve])
    case LUT4(Curves, Matrix, Curves, MultiDimensionalLUT, [ICCCurve])
}

extension iccTransform {
    
    @_versioned
    @_inlineable
    init?(_ tag: iccProfile.TagData) {
        
        if let curve = tag.lut8 {
            
            let input = OneDimensionalLUT(channels: curve.inputChannels, grid: 256, table: curve.inputTable)
            
            let output = OneDimensionalLUT(channels: curve.outputChannels, grid: 256, table: curve.outputTable)
            
            let m = MultiDimensionalLUT(inputChannels: curve.inputChannels, outputChannels: curve.outputChannels, grids: Array(repeating: curve.grids, count: curve.inputChannels), table: curve.clutTable)
            
            self = .LUT0(curve.header.matrix.matrix, input, m, output)
            
        } else if let curve = tag.lut16 {
            
            let input = OneDimensionalLUT(channels: curve.inputChannels, grid: curve.inputEntries, table: curve.inputTable)
            
            let output = OneDimensionalLUT(channels: curve.outputChannels, grid: curve.outputEntries, table: curve.outputTable)
            
            let m = MultiDimensionalLUT(inputChannels: curve.inputChannels, outputChannels: curve.outputChannels, grids: Array(repeating: curve.grids, count: curve.inputChannels), table: curve.clutTable)
            
            self = .LUT0(curve.header.matrix.matrix, input, m, output)
            
        } else if let curve = tag.lutAtoB {
            
            if let B = curve.B, B.count == 3, let B0 = ICCCurve(B[0]), let B1 = ICCCurve(B[1]), let B2 = ICCCurve(B[2]) {
                if let A = curve.A, let LUT = curve.clutTable {
                    let _A = A.map(ICCCurve.init)
                    if _A.contains(where: { $0 == nil }) || LUT.inputChannels != _A.count || LUT.outputChannels != 3 {
                        return nil
                    }
                    if let M = curve.M, let matrix = curve.matrix {
                        if M.count == 3, let M0 = ICCCurve(M[0]), let M1 = ICCCurve(M[1]), let M2 = ICCCurve(M[2]) {
                            self = .LUT4((B0, B1, B2), matrix.matrix, (M0, M1, M2), MultiDimensionalLUT(LUT), _A.map { $0! })
                        } else {
                            return nil
                        }
                    } else {
                        self = .LUT3((B0, B1, B2), MultiDimensionalLUT(LUT), _A.map { $0! })
                    }
                } else if let M = curve.M, let matrix = curve.matrix {
                    if M.count == 3, let M0 = ICCCurve(M[0]), let M1 = ICCCurve(M[1]), let M2 = ICCCurve(M[2]) {
                        self = .LUT2((B0, B1, B2), matrix.matrix, (M0, M1, M2))
                    } else {
                        return nil
                    }
                } else {
                    self = .LUT1((B0, B1, B2))
                }
            } else {
                return nil
            }
        } else if let curve = tag.lutBtoA {
            
            if let B = curve.B, B.count == 3, let B0 = ICCCurve(B[0]), let B1 = ICCCurve(B[1]), let B2 = ICCCurve(B[2]) {
                if let A = curve.A, let LUT = curve.clutTable {
                    let _A = A.map(ICCCurve.init)
                    if _A.contains(where: { $0 == nil }) || LUT.outputChannels != _A.count || LUT.inputChannels != 3 {
                        return nil
                    }
                    if let M = curve.M, let matrix = curve.matrix {
                        if M.count == 3, let M0 = ICCCurve(M[0]), let M1 = ICCCurve(M[1]), let M2 = ICCCurve(M[2]) {
                            self = .LUT4((B0, B1, B2), matrix.matrix, (M0, M1, M2), MultiDimensionalLUT(LUT), _A.map { $0! })
                        } else {
                            return nil
                        }
                    } else {
                        self = .LUT3((B0, B1, B2), MultiDimensionalLUT(LUT), _A.map { $0! })
                    }
                } else if let M = curve.M, let matrix = curve.matrix {
                    if M.count == 3, let M0 = ICCCurve(M[0]), let M1 = ICCCurve(M[1]), let M2 = ICCCurve(M[2]) {
                        self = .LUT2((B0, B1, B2), matrix.matrix, (M0, M1, M2))
                    } else {
                        return nil
                    }
                } else {
                    self = .LUT1((B0, B1, B2))
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

@_versioned
@_fixed_layout
struct ICCColorSpace<Model : ColorModelProtocol, Connection : ColorSpaceBaseProtocol> : ColorSpaceBaseProtocol where Connection.Model : PCSColorModel {
    
    @_versioned
    let _iccData: Data
    
    @_versioned
    let profile: iccProfile
    
    @_versioned
    let connection : Connection
    
    @_versioned
    let cieXYZ : CIEXYZColorSpace
    
    @_versioned
    let a2b: iccTransform
    
    @_versioned
    let b2a: iccTransform
    
    @_versioned
    let chromaticAdaptationMatrix: Matrix
    
    @_versioned
    @_inlineable
    init(iccData: Data, profile: iccProfile, connection : Connection, cieXYZ : CIEXYZColorSpace, a2b: iccTransform, b2a: iccTransform, chromaticAdaptationMatrix: Matrix) {
        self._iccData = iccData
        self.profile = profile
        self.connection = connection
        self.cieXYZ = cieXYZ
        self.a2b = a2b
        self.b2a = b2a
        self.chromaticAdaptationMatrix = chromaticAdaptationMatrix
    }
}

extension ICCColorSpace {
    
    @_versioned
    @_inlineable
    var iccData: Data? {
        return _iccData
    }
}

extension ICCColorSpace {
    
    @_versioned
    @_inlineable
    var localizedName: String? {
        
        if let description = profile[.ProfileDescription] {
            
            if let desc = description.text {
                return desc
            }
            
            let language = Locale.current.languageCode ?? "en"
            let country = Locale.current.regionCode ?? "US"
            
            if let desc = description.multiLocalizedUnicode {
                return desc.first(where: { $0.language.description == language && $0.country.description == country })?.2 ?? desc.first(where: { $0.language.description == language })?.2 ?? desc.first?.2
            }
        }
        
        return nil
    }
}

extension AnyColorSpace {
    
    public enum ICCError : Error {
        
        case invalidFormat(message: String)
        case unsupported(message: String)
    }
    
    @_inlineable
    public init(iccData: Data) throws {
        
        let profile = try iccProfile(iccData)
        
        switch profile.header.colorSpace {
            
        case .XYZ: self.base = try ColorSpace<XYZColorModel>(iccData: iccData, profile: profile)
        case .Lab: self.base = try ColorSpace<LabColorModel>(iccData: iccData, profile: profile)
        case .Luv: self.base = try ColorSpace<LuvColorModel>(iccData: iccData, profile: profile)
        case .YCbCr: self.base = try ColorSpace<Device3ColorModel>(iccData: iccData, profile: profile)
        case .Yxy: self.base = try ColorSpace<Device3ColorModel>(iccData: iccData, profile: profile)
        case .Rgb: self.base = try ColorSpace<RGBColorModel>(iccData: iccData, profile: profile)
        case .Gray: self.base = try ColorSpace<GrayColorModel>(iccData: iccData, profile: profile)
        case .Hsv: self.base = try ColorSpace<Device3ColorModel>(iccData: iccData, profile: profile)
        case .Hls: self.base = try ColorSpace<Device3ColorModel>(iccData: iccData, profile: profile)
        case .Cmyk: self.base = try ColorSpace<CMYKColorModel>(iccData: iccData, profile: profile)
        case .Cmy: self.base = try ColorSpace<CMYColorModel>(iccData: iccData, profile: profile)
            
        case .Named: throw AnyColorSpace.ICCError.unsupported(message: "ColorSpace: \(profile.header.colorSpace)")
            
        case .color2: self.base = try ColorSpace<Device2ColorModel>(iccData: iccData, profile: profile)
        case .color3: self.base = try ColorSpace<Device3ColorModel>(iccData: iccData, profile: profile)
        case .color4: self.base = try ColorSpace<Device4ColorModel>(iccData: iccData, profile: profile)
        case .color5: self.base = try ColorSpace<Device5ColorModel>(iccData: iccData, profile: profile)
        case .color6: self.base = try ColorSpace<Device6ColorModel>(iccData: iccData, profile: profile)
        case .color7: self.base = try ColorSpace<Device7ColorModel>(iccData: iccData, profile: profile)
        case .color8: self.base = try ColorSpace<Device8ColorModel>(iccData: iccData, profile: profile)
        case .color9: self.base = try ColorSpace<Device9ColorModel>(iccData: iccData, profile: profile)
        case .color10: self.base = try ColorSpace<Device10ColorModel>(iccData: iccData, profile: profile)
        case .color11: self.base = try ColorSpace<Device11ColorModel>(iccData: iccData, profile: profile)
        case .color12: self.base = try ColorSpace<Device12ColorModel>(iccData: iccData, profile: profile)
        case .color13: self.base = try ColorSpace<Device13ColorModel>(iccData: iccData, profile: profile)
        case .color14: self.base = try ColorSpace<Device14ColorModel>(iccData: iccData, profile: profile)
        case .color15: self.base = try ColorSpace<Device15ColorModel>(iccData: iccData, profile: profile)
        default: throw AnyColorSpace.ICCError.unsupported(message: "ColorSpace: \(profile.header.colorSpace)")
        }
    }
}

extension ColorSpace {
    
    @_versioned
    @_inlineable
    init(iccData: Data, profile: iccProfile) throws {
        
        func check(_ a2bCurve: iccTransform, _ b2aCurve: iccTransform) throws {
            
            switch a2bCurve {
            case let .LUT0(_, i, lut, o):
                if lut.inputChannels != Model.numberOfComponents || lut.outputChannels != 3 {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
                if i.channels != Model.numberOfComponents {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
                if o.channels != 3 {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
            case .LUT1, .LUT2:
                if Model.numberOfComponents != 3 {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
            case let .LUT3(_, lut, A):
                if lut.inputChannels != Model.numberOfComponents || lut.outputChannels != 3 {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
                if A.count != Model.numberOfComponents {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
            case let .LUT4(_, _, _, lut, A):
                if lut.inputChannels != Model.numberOfComponents || lut.outputChannels != 3 {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
                if A.count != Model.numberOfComponents {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
            default: break
            }
            
            switch b2aCurve {
            case let .LUT0(_, i, lut, o):
                if lut.inputChannels != 3 || lut.outputChannels != Model.numberOfComponents {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
                if i.channels != 3 {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
                if o.channels != Model.numberOfComponents {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
            case .LUT1, .LUT2:
                if Model.numberOfComponents != 3 {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
            case let .LUT3(_, lut, A):
                if lut.inputChannels != 3 || lut.outputChannels != Model.numberOfComponents {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
                if A.count != Model.numberOfComponents {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
            case let .LUT4(_, _, _, lut, A):
                if lut.inputChannels != 3 || lut.outputChannels != Model.numberOfComponents {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
                if A.count != Model.numberOfComponents {
                    throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
                }
            default: break
            }
            
        }
        
        func ABCurve() throws -> (iccTransform, iccTransform)? {
            
            if let a2bCurve = profile[.AToB1].flatMap(iccTransform.init), let b2aCurve = profile[.BToA1].flatMap(iccTransform.init) {
                try check(a2bCurve, b2aCurve)
                return (a2bCurve, b2aCurve)
            }
            if let a2bCurve = profile[.AToB0].flatMap(iccTransform.init), let b2aCurve = profile[.BToA0].flatMap(iccTransform.init) {
                try check(a2bCurve, b2aCurve)
                return (a2bCurve, b2aCurve)
            }
            if let a2bCurve = profile[.AToB2].flatMap(iccTransform.init), let b2aCurve = profile[.BToA2].flatMap(iccTransform.init) {
                try check(a2bCurve, b2aCurve)
                return (a2bCurve, b2aCurve)
            }
            
            return nil
        }
        
        let a2b: iccTransform
        let b2a: iccTransform
        
        switch Model.numberOfComponents {
        case 1:
            
            if let curve = profile[.GrayTRC] {
                
                let kTRC = ICCCurve(curve) ?? .identity
                
                a2b = .monochrome(kTRC)
                b2a = .monochrome(kTRC.inverse)
                
            } else if let (a2bCurve, b2aCurve) = try ABCurve() {
                
                a2b = a2bCurve
                b2a = b2aCurve
                
            } else {
                throw AnyColorSpace.ICCError.invalidFormat(message: "LUT not found.")
            }
            
        case 3 where profile.header.pcs == .XYZ:
            
            if let red = profile[.RedColorant]?.XYZArray?.first, let green = profile[.GreenColorant]?.XYZArray?.first, let blue = profile[.BlueColorant]?.XYZArray?.first {
                
                let rTRC = profile[.RedTRC].flatMap(ICCCurve.init) ?? .identity
                let gTRC = profile[.GreenTRC].flatMap(ICCCurve.init) ?? .identity
                let bTRC = profile[.BlueTRC].flatMap(ICCCurve.init) ?? .identity
                
                let matrix = Matrix(a: red.x.value, b: green.x.value, c: blue.x.value, d: 0,
                                    e: red.y.value, f: green.y.value, g: blue.y.value, h: 0,
                                    i: red.z.value, j: green.z.value, k: blue.z.value, l: 0)
                
                a2b = .matrix(matrix, (rTRC, gTRC, bTRC))
                b2a = .matrix(matrix.inverse, (rTRC.inverse, gTRC.inverse, bTRC.inverse))
                
            } else if let (a2bCurve, b2aCurve) = try ABCurve() {
                
                a2b = a2bCurve
                b2a = b2aCurve
                
            } else {
                throw AnyColorSpace.ICCError.invalidFormat(message: "LUT not found.")
            }
            
        default:
            
            if let (a2bCurve, b2aCurve) = try ABCurve() {
                
                a2b = a2bCurve
                b2a = b2aCurve
                
            } else {
                throw AnyColorSpace.ICCError.invalidFormat(message: "LUT not found.")
            }
        }
        
        let cieXYZ: CIEXYZColorSpace
        
        if let white = profile[.MediaWhitePoint]?.XYZArray?.first {
            if let black = profile[.MediaBlackPoint]?.XYZArray?.first {
                if let luminance = profile[.Luminance]?.XYZArray?.first?.y {
                    cieXYZ = CIEXYZColorSpace(white: XYZColorModel(x: white.x.value, y: white.y.value, z: white.z.value), black: XYZColorModel(x: black.x.value, y: black.y.value, z: black.z.value), luminance: luminance.value)
                } else {
                    cieXYZ = CIEXYZColorSpace(white: XYZColorModel(x: white.x.value, y: white.y.value, z: white.z.value), black: XYZColorModel(x: black.x.value, y: black.y.value, z: black.z.value))
                }
            } else {
                if let luminance = profile[.Luminance]?.XYZArray?.first?.y {
                    cieXYZ = CIEXYZColorSpace(white: XYZColorModel(x: white.x.value, y: white.y.value, z: white.z.value), luminance: luminance.value)
                } else {
                    cieXYZ = CIEXYZColorSpace(white: XYZColorModel(x: white.x.value, y: white.y.value, z: white.z.value))
                }
            }
        } else {
            throw AnyColorSpace.ICCError.invalidFormat(message: "MediaWhitePoint not found.")
        }
        
        let chromaticAdaptationMatrix = cieXYZ.chromaticAdaptationMatrix(to: PCSXYZ, .default)
        
        switch profile.header.pcs {
        case .XYZ: self.base = ICCColorSpace<Model, CIEXYZColorSpace>(iccData: iccData, profile: profile, connection: PCSXYZ, cieXYZ: cieXYZ, a2b: a2b, b2a: b2a, chromaticAdaptationMatrix: chromaticAdaptationMatrix)
        case .Lab: self.base = ICCColorSpace<Model, CIELabColorSpace>(iccData: iccData, profile: profile, connection: CIELabColorSpace(PCSXYZ), cieXYZ: cieXYZ, a2b: a2b, b2a: b2a, chromaticAdaptationMatrix: chromaticAdaptationMatrix)
        default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid PCS.")
        }
    }
}

extension ICCColorSpace {
    
    @_versioned
    @_inlineable
    func convertToLinear(_ color: Model) -> Model {
        
        var result = Model()
        
        var color = color
        
        if let _Model = Model.self as? NonnormalizedColorModel.Type {
            for i in 0..<Model.numberOfComponents {
                let upperBound = _Model.rangeOfComponent(i).upperBound
                let lowerBound = _Model.rangeOfComponent(i).lowerBound
                color.setComponent(i, (color.component(i) - lowerBound) / (upperBound - lowerBound))
            }
        }
        
        switch a2b {
        case .monochrome: return color
        case let .matrix(_, curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case let .LUT0(_, curve, _, _):
            
            result = curve.eval(color)
            
        case let .LUT1(curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
            if result is XYZColorModel {
                result *= 65535.0 / 32768.0
            }
            
        case let .LUT2(_, _, curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case let .LUT3(_, _, curve):
            
            for i in 0..<Model.numberOfComponents {
                result.setComponent(i, curve[i].eval(color.component(i)))
            }
            
        case let .LUT4(_, _, _, _, curve):
            
            for i in 0..<Model.numberOfComponents {
                result.setComponent(i, curve[i].eval(color.component(i)))
            }
        default: fatalError()
        }
        
        if let _Model = Model.self as? NonnormalizedColorModel.Type {
            for i in 0..<Model.numberOfComponents {
                let upperBound = _Model.rangeOfComponent(i).upperBound
                let lowerBound = _Model.rangeOfComponent(i).lowerBound
                result.setComponent(i, result.component(i) * (upperBound - lowerBound) + lowerBound)
            }
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    func convertFromLinear(_ color: Model) -> Model {
        
        var result = Model()
        
        var color = color
        
        if let _Model = Model.self as? NonnormalizedColorModel.Type {
            for i in 0..<Model.numberOfComponents {
                let upperBound = _Model.rangeOfComponent(i).upperBound
                let lowerBound = _Model.rangeOfComponent(i).lowerBound
                color.setComponent(i, (color.component(i) - lowerBound) / (upperBound - lowerBound))
            }
        }
        
        switch b2a {
        case .monochrome: return color
        case let .matrix(_, curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case let .LUT0(_, _, _, curve):
            
            result = curve.eval(color)
            
        case let .LUT1(curve):
            
            if color is XYZColorModel {
                color *= 32768.0 / 65535.0
            }
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case let .LUT2(_, _, curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case let .LUT3(_, _, curve):
            
            for i in 0..<Model.numberOfComponents {
                result.setComponent(i, curve[i].eval(color.component(i)))
            }
            
        case let .LUT4(_, _, _, _, curve):
            
            for i in 0..<Model.numberOfComponents {
                result.setComponent(i, curve[i].eval(color.component(i)))
            }
        default: fatalError()
        }
        
        if let _Model = Model.self as? NonnormalizedColorModel.Type {
            for i in 0..<Model.numberOfComponents {
                let upperBound = _Model.rangeOfComponent(i).upperBound
                let lowerBound = _Model.rangeOfComponent(i).lowerBound
                result.setComponent(i, result.component(i) * (upperBound - lowerBound) + lowerBound)
            }
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    func convertLinearToConnection(_ color: Model) -> Connection.Model {
        
        var result = Connection.Model()
        
        var color = color
        
        if let _Model = Model.self as? NonnormalizedColorModel.Type {
            for i in 0..<Model.numberOfComponents {
                let upperBound = _Model.rangeOfComponent(i).upperBound
                let lowerBound = _Model.rangeOfComponent(i).lowerBound
                color.setComponent(i, (color.component(i) - lowerBound) / (upperBound - lowerBound))
            }
        }
        
        switch a2b {
        case let .monochrome(ICCCurve):
            
            result.setComponent(0, ICCCurve.eval(color.component(0)))
            
        case let .matrix(matrix, _):
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
            result *= matrix
            
        case let .LUT0(matrix, _, lut, o):
            
            result = lut.eval(color)
            
            result = o.eval(result)
            
            if result is XYZColorModel {
                result *= matrix
            }
            
        case .LUT1:
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
        case let .LUT2(B, matrix, _):
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
            result *= matrix
            
            result.setComponent(0, B.0.eval(result.component(0)))
            result.setComponent(1, B.1.eval(result.component(1)))
            result.setComponent(2, B.2.eval(result.component(2)))
            
            if result is XYZColorModel {
                result *= 65535.0 / 32768.0
            }
            
        case let .LUT3(B, lut, _):
            
            result = lut.eval(color)
            
            result.setComponent(0, B.0.eval(result.component(0)))
            result.setComponent(1, B.1.eval(result.component(1)))
            result.setComponent(2, B.2.eval(result.component(2)))
            
            if result is XYZColorModel {
                result *= 65535.0 / 32768.0
            }
            
        case let .LUT4(B, matrix, M, lut, _):
            
            result = lut.eval(color)
            
            result.setComponent(0, M.0.eval(result.component(0)))
            result.setComponent(1, M.1.eval(result.component(1)))
            result.setComponent(2, M.2.eval(result.component(2)))
            
            result *= matrix
            
            result.setComponent(0, B.0.eval(result.component(0)))
            result.setComponent(1, B.1.eval(result.component(1)))
            result.setComponent(2, B.2.eval(result.component(2)))
            
            if result is XYZColorModel {
                result *= 65535.0 / 32768.0
            }
            
        default: fatalError()
        }
        
        if let _Model = Connection.Model.self as? NonnormalizedColorModel.Type {
            for i in 0..<Connection.Model.numberOfComponents {
                let upperBound = _Model.rangeOfComponent(i).upperBound
                let lowerBound = _Model.rangeOfComponent(i).lowerBound
                result.setComponent(i, result.component(i) * (upperBound - lowerBound) + lowerBound)
            }
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromConnection(_ color: Connection.Model) -> Model {
        
        var result = Model()
        
        var color = color
        
        if let _Model = Connection.Model.self as? NonnormalizedColorModel.Type {
            for i in 0..<Connection.Model.numberOfComponents {
                let upperBound = _Model.rangeOfComponent(i).upperBound
                let lowerBound = _Model.rangeOfComponent(i).lowerBound
                color.setComponent(i, (color.component(i) - lowerBound) / (upperBound - lowerBound))
            }
        }
        
        switch b2a {
        case let .monochrome(ICCCurve):
            
            result.setComponent(0, ICCCurve.eval(color.component(0)))
            
        case let .matrix(matrix, _):
            
            color *= matrix
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
        case let .LUT0(matrix, i, lut, _):
            
            if color is XYZColorModel {
                color *= matrix
            }
            
            color = i.eval(color)
            
            result = lut.eval(color)
            
        case .LUT1:
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
        case let .LUT2(B, matrix, _):
            
            if color is XYZColorModel {
                color *= 32768.0 / 65535.0
            }
            
            color.setComponent(0, B.0.eval(color.component(0)))
            color.setComponent(1, B.1.eval(color.component(1)))
            color.setComponent(2, B.2.eval(color.component(2)))
            
            color *= matrix
            
            result.setComponent(0, color.component(0))
            result.setComponent(1, color.component(1))
            result.setComponent(2, color.component(2))
            
        case let .LUT3(B, lut, _):
            
            if color is XYZColorModel {
                color *= 32768.0 / 65535.0
            }
            
            color.setComponent(0, B.0.eval(color.component(0)))
            color.setComponent(1, B.1.eval(color.component(1)))
            color.setComponent(2, B.2.eval(color.component(2)))
            
            result = lut.eval(color)
            
        case let .LUT4(B, matrix, M, lut, _):
            
            if color is XYZColorModel {
                color *= 32768.0 / 65535.0
            }
            
            color.setComponent(0, B.0.eval(color.component(0)))
            color.setComponent(1, B.1.eval(color.component(1)))
            color.setComponent(2, B.2.eval(color.component(2)))
            
            color *= matrix
            
            color.setComponent(0, M.0.eval(color.component(0)))
            color.setComponent(1, M.1.eval(color.component(1)))
            color.setComponent(2, M.2.eval(color.component(2)))
            
            result = lut.eval(color)
            
        default: fatalError()
        }
        
        if let _Model = Model.self as? NonnormalizedColorModel.Type {
            for i in 0..<Model.numberOfComponents {
                let upperBound = _Model.rangeOfComponent(i).upperBound
                let lowerBound = _Model.rangeOfComponent(i).lowerBound
                result.setComponent(i, result.component(i) * (upperBound - lowerBound) + lowerBound)
            }
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        return self.connection._convertToXYZ(self.convertLinearToConnection(color)) * chromaticAdaptationMatrix.inverse
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return self.convertLinearFromConnection(self.connection._convertFromXYZ(color * chromaticAdaptationMatrix))
    }
}

