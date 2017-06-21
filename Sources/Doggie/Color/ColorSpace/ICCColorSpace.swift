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
func _modf(_ x: Double) -> (Int, Double) {
    var _i = 0.0
    let m = modf(x, &_i)
    return (Int(_i), m)
}

@_versioned
@_inlineable
func interpolate<C : RandomAccessCollection>(_ x: Double, table: C) -> Double where C.Index == Int, C.IndexDistance == Int, C.Element == Double {
    
    let (i, m) = _modf(x.clamped(to: 0...1) * Double(table.count - 1))
    
    let offset = table.startIndex
    let a = (1 - m) * table[offset + i]
    let b = m * table[offset + i + 1]
    return a + b
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
        
        let position = source.components.enumerated().map { _modf($0.1.clamped(to: 0...1) * Double(grids[$0.0] - 1)) }
        
        func _interpolate(level: Int, offset: Int) -> Destination {
            
            var a = Destination()
            var b = Destination()
            
            let _p = position[Source.numberOfComponents - level - 1]
            let _s = level == 0 ? Destination.numberOfComponents : grids[level - 1]
            
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
        
        return _interpolate(level: Source.numberOfComponents - 1, offset: 0)
    }
}

@_versioned
@_fixed_layout
enum ICCCurve {
    
    case identity
    case gamma(Double)
    case parametric(Double, Double, Double, Double, Double, Double, Double)
    case table([Double])
    case inverse_table([Double])
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
            case 1: self = .parametric(curve.gamma.value, curve.a.value, curve.b.value, 0, -curve.b.value / curve.a.value, 0, 0)
            case 2: self = .parametric(curve.gamma.value, curve.a.value, curve.b.value, curve.c.value, -curve.b.value / curve.a.value, curve.c.value, curve.c.value)
            case 3: self = .parametric(curve.gamma.value, curve.a.value, curve.b.value, curve.c.value, curve.d.value, 0, 0)
            case 4: self = .parametric(curve.gamma.value, curve.a.value, curve.b.value, curve.c.value, curve.d.value, curve.e.value, curve.f.value)
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
        case let .parametric(gamma, a, b, c, d, e, f):
            let _a = 1 / pow(a, gamma)
            let _b = -e * _a
            let _c = c == 0 ? 0 : 1 / c
            let _d = c * d + f
            let _e = -b / a
            let _f = c == 0 ? 0 : -f / c
            return .parametric(gamma, _a, _b, _c, _d, _e, _f)
        case let .table(points): return .inverse_table(points)
        case let .inverse_table(points): return .table(points)
        }
    }
}

extension ICCCurve {
    
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
        case let .inverse_table(points):
            print(points)
            return 0
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
    let iccData: Data
    
    @_versioned
    let profile: iccProfile
    
    @_versioned
    let connection : Connection
    
    @_versioned
    let a2b: iccTransform
    
    @_versioned
    let b2a: iccTransform
    
    @_versioned
    @_inlineable
    init(iccData: Data, profile: iccProfile, connection : Connection, a2b: iccTransform, b2a: iccTransform) {
        self.iccData = iccData
        self.profile = profile
        self.connection = connection
        self.a2b = a2b
        self.b2a = b2a
    }
}

extension ICCColorSpace : CustomStringConvertible {
    
    var description: String {
        if let desc = profile[.ProfileDescription]?.text {
            return desc
        }
        if let desc = profile[.ProfileDescription]?.multiLocalizedUnicode {
            return desc.first(where: { $0.language == "en" && $0.country == "US" })?.2 ?? desc.first(where: { $0.language == "en" })?.2 ?? desc.first?.2 ?? "\(ICCColorSpace<Model, Connection>.self)"
        }
        return "\(ICCColorSpace<Model, Connection>.self)"
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
                
            } else if let a2bCurve = profile[.AToB2].flatMap(iccTransform.init), let b2aCurve = profile[.BToA2].flatMap(iccTransform.init) {
                
                try check(a2bCurve, b2aCurve)
                
                return (a2bCurve, b2aCurve)
                
            } else if let a2bCurve = profile[.AToB0].flatMap(iccTransform.init), let b2aCurve = profile[.BToA0].flatMap(iccTransform.init) {
                
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
        
        switch profile.header.pcs {
        case .XYZ:
            
            let connection = CIEXYZColorSpace(white: XYZColorModel(x: profile.header.illuminant.x.value, y: profile.header.illuminant.y.value, z: profile.header.illuminant.z.value), black: XYZColorModel())
            
            self.base = ICCColorSpace<Model, CIEXYZColorSpace>(iccData: iccData, profile: profile, connection: connection, a2b: a2b, b2a: b2a)
            
        case .Lab:
            
            let connection = CIELabColorSpace(CIEXYZColorSpace(white: XYZColorModel(x: profile.header.illuminant.x.value, y: profile.header.illuminant.y.value, z: profile.header.illuminant.z.value), black: XYZColorModel()))
            
            self.base = ICCColorSpace<Model, CIELabColorSpace>(iccData: iccData, profile: profile, connection: connection, a2b: a2b, b2a: b2a)
            
        default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid PCS.")
        }
    }
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
        return color
    }
    
    @_versioned
    @_inlineable
    func convertFromLinear(_ color: Model) -> Model {
        return color
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
            
        case let .matrix(matrix, curve):
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
            result *= matrix
            
        case let .LUT0(_, i, lut, o):
            
            color = i.eval(color)
            
            result = lut.eval(color)
            
            result = o.eval(result)
            
        case let .LUT1(B):
            
            result.setComponent(0, B.0.eval(color.component(0)))
            result.setComponent(1, B.1.eval(color.component(1)))
            result.setComponent(2, B.2.eval(color.component(2)))
            
        case let .LUT2(B, matrix, M):
            
            result.setComponent(0, M.0.eval(color.component(0)))
            result.setComponent(1, M.1.eval(color.component(1)))
            result.setComponent(2, M.2.eval(color.component(2)))
            
            result *= matrix
            
            result.setComponent(0, B.0.eval(color.component(0)))
            result.setComponent(1, B.1.eval(color.component(1)))
            result.setComponent(2, B.2.eval(color.component(2)))
            
        case let .LUT3(B, lut, A):
            
            for i in 0..<Model.numberOfComponents {
                color.setComponent(i, A[i].eval(color.component(i)))
            }
            
            result = lut.eval(color)
            
            result.setComponent(0, B.0.eval(result.component(0)))
            result.setComponent(1, B.1.eval(result.component(1)))
            result.setComponent(2, B.2.eval(result.component(2)))
            
        case let .LUT4(B, matrix, M, lut, A):
            
            for i in 0..<Model.numberOfComponents {
                color.setComponent(i, A[i].eval(color.component(i)))
            }
            
            result = lut.eval(color)
            
            result.setComponent(0, M.0.eval(result.component(0)))
            result.setComponent(1, M.1.eval(result.component(1)))
            result.setComponent(2, M.2.eval(result.component(2)))
            
            result *= matrix
            
            result.setComponent(0, B.0.eval(result.component(0)))
            result.setComponent(1, B.1.eval(result.component(1)))
            result.setComponent(2, B.2.eval(result.component(2)))
            
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
            
        case let .matrix(matrix, curve):
            
            color *= matrix
            
            result.setComponent(0, curve.0.eval(color.component(0)))
            result.setComponent(1, curve.1.eval(color.component(1)))
            result.setComponent(2, curve.2.eval(color.component(2)))
            
        case let .LUT0(matrix, i, lut, o):
            
            if color is XYZColorModel {
                color *= matrix
            }
            
            color = i.eval(color)
            
            result = lut.eval(color)
            
            result = o.eval(result)
            
        case let .LUT1(B):
            
            result.setComponent(0, B.0.eval(color.component(0)))
            result.setComponent(1, B.1.eval(color.component(1)))
            result.setComponent(2, B.2.eval(color.component(2)))
            
        case let .LUT2(B, matrix, M):
            
            var color = color
            
            color.setComponent(0, B.0.eval(color.component(0)))
            color.setComponent(1, B.1.eval(color.component(1)))
            color.setComponent(2, B.2.eval(color.component(2)))
            
            color *= matrix
            
            result.setComponent(0, M.0.eval(color.component(0)))
            result.setComponent(1, M.1.eval(color.component(1)))
            result.setComponent(2, M.2.eval(color.component(2)))
            
        case let .LUT3(B, lut, A):
            
            color.setComponent(0, B.0.eval(color.component(0)))
            color.setComponent(1, B.1.eval(color.component(1)))
            color.setComponent(2, B.2.eval(color.component(2)))
            
            result = lut.eval(color)
            
            for i in 0..<Model.numberOfComponents {
                result.setComponent(i, A[i].eval(result.component(i)))
            }
            
        case let .LUT4(B, matrix, M, lut, A):
            
            color.setComponent(0, B.0.eval(color.component(0)))
            color.setComponent(1, B.1.eval(color.component(1)))
            color.setComponent(2, B.2.eval(color.component(2)))
            
            color *= matrix
            
            color.setComponent(0, M.0.eval(color.component(0)))
            color.setComponent(1, M.1.eval(color.component(1)))
            color.setComponent(2, M.2.eval(color.component(2)))
            
            result = lut.eval(color)
            
            for i in 0..<Model.numberOfComponents {
                result.setComponent(i, A[i].eval(result.component(i)))
            }
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
        return self.connection._convertToXYZ(self.convertLinearToConnection(color))
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return self.convertLinearFromConnection(self.connection._convertFromXYZ(color))
    }
}

