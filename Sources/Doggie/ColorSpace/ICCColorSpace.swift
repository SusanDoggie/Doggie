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
@_fixed_layout
struct ICCColorSpace<Model : ColorModelProtocol, Connection : ColorSpaceBaseProtocol> : ColorSpaceBaseProtocol where Connection.Model : PCSColorModel {
    
    @_versioned
    let _iccData: Data
    
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
    var iccData: Data? {
        return _iccData
    }
}

extension ICCColorSpace {
    
    @_versioned
    var localizedName: String? {
        
        if let description = profile[.ProfileDescription] {
            
            if let desc = description.text {
                return desc
            }
            if let desc = description.textDescription {
                return desc.ascii ?? desc.unicode
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
        
        case endOfData
        case invalidFormat(message: String)
        case unsupported(message: String)
    }
    
    public init(iccData: Data) throws {
        
        let profile = try iccProfile(iccData)
        
        switch profile.header.colorSpace {
            
        case .XYZ: self._base = try ColorSpace<XYZColorModel>(iccData: iccData, profile: profile)
        case .Lab: self._base = try ColorSpace<LabColorModel>(iccData: iccData, profile: profile)
        case .Luv: self._base = try ColorSpace<LuvColorModel>(iccData: iccData, profile: profile)
        case .YCbCr: self._base = try ColorSpace<Device3ColorModel>(iccData: iccData, profile: profile)
        case .Yxy: self._base = try ColorSpace<Device3ColorModel>(iccData: iccData, profile: profile)
        case .Rgb: self._base = try ColorSpace<RGBColorModel>(iccData: iccData, profile: profile)
        case .Gray: self._base = try ColorSpace<GrayColorModel>(iccData: iccData, profile: profile)
        case .Hsv: self._base = try ColorSpace<Device3ColorModel>(iccData: iccData, profile: profile)
        case .Hls: self._base = try ColorSpace<Device3ColorModel>(iccData: iccData, profile: profile)
        case .Cmyk: self._base = try ColorSpace<CMYKColorModel>(iccData: iccData, profile: profile)
        case .Cmy: self._base = try ColorSpace<CMYColorModel>(iccData: iccData, profile: profile)
            
        case .Named: throw AnyColorSpace.ICCError.unsupported(message: "ColorSpace: \(profile.header.colorSpace)")
            
        case .color2: self._base = try ColorSpace<Device2ColorModel>(iccData: iccData, profile: profile)
        case .color3: self._base = try ColorSpace<Device3ColorModel>(iccData: iccData, profile: profile)
        case .color4: self._base = try ColorSpace<Device4ColorModel>(iccData: iccData, profile: profile)
        case .color5: self._base = try ColorSpace<Device5ColorModel>(iccData: iccData, profile: profile)
        case .color6: self._base = try ColorSpace<Device6ColorModel>(iccData: iccData, profile: profile)
        case .color7: self._base = try ColorSpace<Device7ColorModel>(iccData: iccData, profile: profile)
        case .color8: self._base = try ColorSpace<Device8ColorModel>(iccData: iccData, profile: profile)
        case .color9: self._base = try ColorSpace<Device9ColorModel>(iccData: iccData, profile: profile)
        case .color10: self._base = try ColorSpace<Device10ColorModel>(iccData: iccData, profile: profile)
        case .color11: self._base = try ColorSpace<Device11ColorModel>(iccData: iccData, profile: profile)
        case .color12: self._base = try ColorSpace<Device12ColorModel>(iccData: iccData, profile: profile)
        case .color13: self._base = try ColorSpace<Device13ColorModel>(iccData: iccData, profile: profile)
        case .color14: self._base = try ColorSpace<Device14ColorModel>(iccData: iccData, profile: profile)
        case .color15: self._base = try ColorSpace<Device15ColorModel>(iccData: iccData, profile: profile)
        default: throw AnyColorSpace.ICCError.unsupported(message: "ColorSpace: \(profile.header.colorSpace)")
        }
    }
}

extension ColorSpace {
    
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
            
            if let a2bCurve = profile[.AToB1].flatMap({ $0.transform }), let b2aCurve = profile[.BToA1].flatMap({ $0.transform }) {
                try check(a2bCurve, b2aCurve)
                return (a2bCurve, b2aCurve)
            }
            if let a2bCurve = profile[.AToB0].flatMap({ $0.transform }), let b2aCurve = profile[.BToA0].flatMap({ $0.transform }) {
                try check(a2bCurve, b2aCurve)
                return (a2bCurve, b2aCurve)
            }
            if let a2bCurve = profile[.AToB2].flatMap({ $0.transform }), let b2aCurve = profile[.BToA2].flatMap({ $0.transform }){
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
                
                let kTRC = curve.curve ?? .identity
                
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
                
                let rTRC = profile[.RedTRC].flatMap { $0.curve } ?? .identity
                let gTRC = profile[.GreenTRC].flatMap { $0.curve } ?? .identity
                let bTRC = profile[.BlueTRC].flatMap { $0.curve } ?? .identity
                
                let matrix = Matrix(a: red.x.representingValue, b: green.x.representingValue, c: blue.x.representingValue, d: 0,
                                    e: red.y.representingValue, f: green.y.representingValue, g: blue.y.representingValue, h: 0,
                                    i: red.z.representingValue, j: green.z.representingValue, k: blue.z.representingValue, l: 0)
                
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
        
        let white: XYZColorModel
        let black: XYZColorModel
        
        if let _white = profile[.MediaWhitePoint]?.XYZArray?.first {
            
             white = XYZColorModel(x: _white.x.representingValue, y: _white.y.representingValue, z: _white.z.representingValue)
            
            if let _black = profile[.MediaBlackPoint]?.XYZArray?.first {
                
                 black = XYZColorModel(x: _black.x.representingValue, y: _black.y.representingValue, z: _black.z.representingValue)
                
            } else {
                
                var _black: XYZColorModel
                
                switch profile.header.pcs {
                case .XYZ: _black = ColorSpace._PCSXYZ_black_point(a2b: a2b, b2a: b2a)
                case .Lab: _black = ColorSpace._PCSLab_black_point(a2b: a2b, b2a: b2a)
                default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid PCS.")
                }
                
                black = _black * PCSXYZ.chromaticAdaptationMatrix(to: CIEXYZColorSpace(white: white), .default)
            }
            
        } else {
            throw AnyColorSpace.ICCError.invalidFormat(message: "MediaWhitePoint not found.")
        }
        
        let cieXYZ: CIEXYZColorSpace
        if let luminance = profile[.Luminance]?.XYZArray?.first?.y {
            cieXYZ = CIEXYZColorSpace(white: white, black: black, luminance: luminance.representingValue)
        } else {
            cieXYZ = CIEXYZColorSpace(white: white, black: black)
        }
        
        let _PCSXYZ = CIEXYZColorSpace(white: PCSXYZ.white, black: black * CIEXYZColorSpace(white: white).chromaticAdaptationMatrix(to: PCSXYZ, .default))
        
        let chromaticAdaptationMatrix = cieXYZ.chromaticAdaptationMatrix(to: _PCSXYZ, .default)
        
        switch profile.header.pcs {
        case .XYZ: self.base = ICCColorSpace<Model, CIEXYZColorSpace>(iccData: iccData, profile: profile, connection: PCSXYZ, cieXYZ: cieXYZ, a2b: a2b, b2a: b2a, chromaticAdaptationMatrix: chromaticAdaptationMatrix)
        case .Lab: self.base = ICCColorSpace<Model, CIELabColorSpace>(iccData: iccData, profile: profile, connection: CIELabColorSpace(PCSXYZ), cieXYZ: cieXYZ, a2b: a2b, b2a: b2a, chromaticAdaptationMatrix: chromaticAdaptationMatrix)
        default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid PCS.")
        }
    }
    
    static func _PCSXYZ_black_point(a2b: iccTransform, b2a: iccTransform) -> XYZColorModel {
        
        let color: Model
        var black = XYZColorModel()
        
        switch b2a {
        case .monochrome: return XYZColorModel()
        default: color = b2a._convertFromLinear(b2a._convertLinearFromConnection(black))
        }
        
        switch a2b {
        case .monochrome: return XYZColorModel()
        default: black = a2b._convertLinearToConnection(a2b._convertToLinear(color))
        }
        
        switch a2b {
        case .matrix, .LUT0:
            black.x *= 0.5
            black.z *= 0.5
        case .LUT1, .LUT2, .LUT3, .LUT4:
            black.y *= 2
        default: fatalError()
        }
        
        black.setNormalizedComponent(0, black.x)
        black.setNormalizedComponent(1, black.y)
        black.setNormalizedComponent(2, black.z)
        
        return black
    }
    
    static func _PCSLab_black_point(a2b: iccTransform, b2a: iccTransform) -> XYZColorModel {
        
        let color: Model
        var black = LabColorModel(lightness: 0, a: 0.5, b: 0.5)
        
        switch b2a {
        case .monochrome: return XYZColorModel()
        default: color = b2a._convertFromLinear(b2a._convertLinearFromConnection(black))
        }
        
        switch a2b {
        case .monochrome: return XYZColorModel()
        default: black = a2b._convertLinearToConnection(a2b._convertToLinear(color))
        }
        
        black.setNormalizedComponent(0, black.lightness)
        black.setNormalizedComponent(1, black.a)
        black.setNormalizedComponent(2, black.b)
        
        return CIELabColorSpace(PCSXYZ).convertToXYZ(black)
    }
    
}

extension iccTransform {
    
    @_versioned
    @inline(__always)
    func _convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        switch self {
        case let .matrix(_, curve):
            
            result[0] = curve.0.eval(color[0])
            result[1] = curve.1.eval(color[1])
            result[2] = curve.2.eval(color[2])
            
        case let .LUT0(_, curve, _, _):
            
            result = curve.eval(color)
            
        case let .LUT1(curve):
            
            result[0] = curve.0.eval(color[0])
            result[1] = curve.1.eval(color[1])
            result[2] = curve.2.eval(color[2])
            
        case let .LUT2(_, _, curve):
            
            result[0] = curve.0.eval(color[0])
            result[1] = curve.1.eval(color[1])
            result[2] = curve.2.eval(color[2])
            
        case let .LUT3(_, _, curve):
            
            for i in 0..<Model.numberOfComponents {
                result[i] = curve[i].eval(color[i])
            }
            
        case let .LUT4(_, _, _, _, curve):
            
            for i in 0..<Model.numberOfComponents {
                result[i] = curve[i].eval(color[i])
            }
            
        default: fatalError()
        }
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func _convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        switch self {
        case let .matrix(_, curve):
            
            result[0] = curve.0.eval(color[0])
            result[1] = curve.1.eval(color[1])
            result[2] = curve.2.eval(color[2])
            
        case let .LUT0(_, _, _, curve):
            
            result = curve.eval(color)
            
        case let .LUT1(curve):
            
            result[0] = curve.0.eval(color[0])
            result[1] = curve.1.eval(color[1])
            result[2] = curve.2.eval(color[2])
            
        case let .LUT2(_, _, curve):
            
            result[0] = curve.0.eval(color[0])
            result[1] = curve.1.eval(color[1])
            result[2] = curve.2.eval(color[2])
            
        case let .LUT3(_, _, curve):
            
            for i in 0..<Model.numberOfComponents {
                result[i] = curve[i].eval(color[i])
            }
            
        case let .LUT4(_, _, _, _, curve):
            
            for i in 0..<Model.numberOfComponents {
                result[i] = curve[i].eval(color[i])
            }
            
        default: fatalError()
        }
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func _convertLinearToConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: Model) -> PCSColor {
        
        var result = PCSColor()
        
        switch self {
        case let .matrix(matrix, _):
            
            result[0] = color[0]
            result[1] = color[1]
            result[2] = color[2]
            
            result *= matrix
            
        case let .LUT0(matrix, _, lut, o):
            
            result = lut.eval(color)
            
            result = o.eval(result)
            
            if result is XYZColorModel {
                result *= matrix
            }
            
        case .LUT1:
            
            result[0] = color[0]
            result[1] = color[1]
            result[2] = color[2]
            
        case let .LUT2(B, matrix, _):
            
            result[0] = color[0]
            result[1] = color[1]
            result[2] = color[2]
            
            result *= matrix
            
            result[0] = B.0.eval(result[0])
            result[1] = B.1.eval(result[1])
            result[2] = B.2.eval(result[2])
            
        case let .LUT3(B, lut, _):
            
            result = lut.eval(color)
            
            result[0] = B.0.eval(result[0])
            result[1] = B.1.eval(result[1])
            result[2] = B.2.eval(result[2])
            
        case let .LUT4(B, matrix, M, lut, _):
            
            result = lut.eval(color)
            
            result[0] = M.0.eval(result[0])
            result[1] = M.1.eval(result[1])
            result[2] = M.2.eval(result[2])
            
            result *= matrix
            
            result[0] = B.0.eval(result[0])
            result[1] = B.1.eval(result[1])
            result[2] = B.2.eval(result[2])
            
        default: fatalError()
        }
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func _convertLinearFromConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: PCSColor) -> Model {
        
        var result = Model()
        
        var color = color
        
        switch self {
        case let .matrix(matrix, _):
            
            color *= matrix
            
            result[0] = color[0]
            result[1] = color[1]
            result[2] = color[2]
            
        case let .LUT0(matrix, i, lut, _):
            
            if color is XYZColorModel {
                color *= matrix
            }
            
            color = i.eval(color)
            
            result = lut.eval(color)
            
        case .LUT1:
            
            result[0] = color[0]
            result[1] = color[1]
            result[2] = color[2]
            
        case let .LUT2(B, matrix, _):
            
            color[0] = B.0.eval(color[0])
            color[1] = B.1.eval(color[1])
            color[2] = B.2.eval(color[2])
            
            color *= matrix
            
            result[0] = color[0]
            result[1] = color[1]
            result[2] = color[2]
            
        case let .LUT3(B, lut, _):
            
            color[0] = B.0.eval(color[0])
            color[1] = B.1.eval(color[1])
            color[2] = B.2.eval(color[2])
            
            result = lut.eval(color)
            
        case let .LUT4(B, matrix, M, lut, _):
            
            color[0] = B.0.eval(color[0])
            color[1] = B.1.eval(color[1])
            color[2] = B.2.eval(color[2])
            
            color *= matrix
            
            color[0] = M.0.eval(color[0])
            color[1] = M.1.eval(color[1])
            color[2] = M.2.eval(color[2])
            
            result = lut.eval(color)
            
        default: fatalError()
        }
        
        return result
    }
}

extension ICCColorSpace {
    
    @_versioned
    @inline(__always)
    func _convertToLinear(_ color: Model) -> Model {
        
        switch a2b {
        case let .monochrome(curve):
            
            var result = Model()
            
            result[0] = curve.eval(color[0])
            
            return result
            
        default: return a2b._convertToLinear(color)
        }
    }
    
    @_versioned
    @inline(__always)
    func _convertFromLinear(_ color: Model) -> Model {
        
        switch b2a {
        case let .monochrome(curve):
            
            var result = Model()
            
            result[0] = curve.eval(color[0])
            
            return result
            
        default: return b2a._convertFromLinear(color)
        }
    }
    
    @_versioned
    @inline(__always)
    func _convertLinearToConnection(_ color: Model) -> Connection.Model {
        
        switch a2b {
        case .monochrome:
            
            var result = Connection.Model()
            
            let normalizeMatrix = self.connection.cieXYZ.normalizeMatrix
            let white = self.connection.cieXYZ.white * normalizeMatrix * color[0] * normalizeMatrix.inverse
            result = self.connection.convertFromXYZ(white)
            
            return result
            
        default: return a2b._convertLinearToConnection(color)
        }
    }
    
    @_versioned
    @inline(__always)
    func _convertLinearFromConnection(_ color: Connection.Model) -> Model {
        
        switch b2a {
        case .monochrome:
            
            var result = Model()
            
            result[0] = color.luminance
            
            return result
            
        default: return b2a._convertLinearFromConnection(color)
        }
    }
    
    @_versioned
    @_inlineable
    @_specialize(where Model == GrayColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == GrayColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIELabColorSpace)
    func convertToLinear(_ color: Model) -> Model {
        
        var color = color
        
        for i in 0..<Model.numberOfComponents {
            color[i] = color.normalizedComponent(i)
        }
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if color is XYZColorModel {
                color[0] *= 2
                color[2] *= 2
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if color is XYZColorModel {
                color[1] *= 0.5
            }
        }
        
        var result = _convertToLinear(color)
        
        switch a2b {
        case .monochrome, .matrix, .LUT0:
            if result is XYZColorModel {
                result[0] *= 0.5
                result[2] *= 0.5
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if result is XYZColorModel {
                result[1] *= 2
            }
        }
        
        for i in 0..<Model.numberOfComponents {
            result.setNormalizedComponent(i, result[i])
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    @_specialize(where Model == GrayColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == GrayColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIELabColorSpace)
    func convertFromLinear(_ color: Model) -> Model {
        
        var color = color
        
        for i in 0..<Model.numberOfComponents {
            color[i] = color.normalizedComponent(i)
        }
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if color is XYZColorModel {
                color[0] *= 2
                color[2] *= 2
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if color is XYZColorModel {
                color[1] *= 0.5
            }
        }
        
        var result = _convertFromLinear(color)
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if result is XYZColorModel {
                result[0] *= 0.5
                result[2] *= 0.5
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if result is XYZColorModel {
                result[1] *= 2
            }
        }
        
        for i in 0..<Model.numberOfComponents {
            result.setNormalizedComponent(i, result[i])
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    @_specialize(where Model == GrayColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == GrayColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIELabColorSpace)
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        
        var color = color
        
        for i in 0..<Model.numberOfComponents {
            color[i] = color.normalizedComponent(i)
        }
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if color is XYZColorModel {
                color[0] *= 2
                color[2] *= 2
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if color is XYZColorModel {
                color[1] *= 0.5
            }
        }
        
        var result = _convertLinearToConnection(color)
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if result is XYZColorModel {
                result[0] *= 0.5
                result[2] *= 0.5
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if result is XYZColorModel {
                result[1] *= 2
            }
        }
        
        result.setNormalizedComponent(0, result[0])
        result.setNormalizedComponent(1, result[1])
        result.setNormalizedComponent(2, result[2])
        
        return self.connection.convertToXYZ(result) * chromaticAdaptationMatrix.inverse
    }
    
    @_versioned
    @_inlineable
    @_specialize(where Model == GrayColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == GrayColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIELabColorSpace)
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        
        var color = self.connection.convertFromXYZ(color * chromaticAdaptationMatrix)
        
        color[0] = color.normalizedComponent(0)
        color[1] = color.normalizedComponent(1)
        color[2] = color.normalizedComponent(2)
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if color is XYZColorModel {
                color[0] *= 2
                color[2] *= 2
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if color is XYZColorModel {
                color[1] *= 0.5
            }
        }
        
        var result = _convertLinearFromConnection(color)
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if result is XYZColorModel {
                result[0] *= 0.5
                result[2] *= 0.5
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if result is XYZColorModel {
                result[1] *= 2
            }
        }
        
        for i in 0..<Model.numberOfComponents {
            result.setNormalizedComponent(i, result[i])
        }
        
        return result
    }
    
    @_versioned
    @_inlineable
    @_specialize(where Model == GrayColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == GrayColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIELabColorSpace)
    func convertToXYZ(_ color: Model) -> XYZColorModel {
        
        var color = color
        
        for i in 0..<Model.numberOfComponents {
            color[i] = color.normalizedComponent(i)
        }
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if color is XYZColorModel {
                color[0] *= 2
                color[2] *= 2
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if color is XYZColorModel {
                color[1] *= 0.5
            }
        }
        
        var result = _convertLinearToConnection(_convertToLinear(color))
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if result is XYZColorModel {
                result[0] *= 0.5
                result[2] *= 0.5
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if result is XYZColorModel {
                result[1] *= 2
            }
        }
        
        result.setNormalizedComponent(0, result[0])
        result.setNormalizedComponent(1, result[1])
        result.setNormalizedComponent(2, result[2])
        
        return self.connection.convertToXYZ(result) * chromaticAdaptationMatrix.inverse
    }
    
    @_versioned
    @_inlineable
    @_specialize(where Model == GrayColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == GrayColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == XYZColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LabColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == LuvColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == RGBColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == CMYKColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device2ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device3ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device4ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device5ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device6ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device7ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device8ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device9ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device10ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device11ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device12ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device13ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device14ColorModel, Connection == CIELabColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIEXYZColorSpace)
    @_specialize(where Model == Device15ColorModel, Connection == CIELabColorSpace)
    func convertFromXYZ(_ color: XYZColorModel) -> Model {
        
        var color = self.connection.convertFromXYZ(color * chromaticAdaptationMatrix)
        
        color[0] = color.normalizedComponent(0)
        color[1] = color.normalizedComponent(1)
        color[2] = color.normalizedComponent(2)
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if color is XYZColorModel {
                color[0] *= 2
                color[2] *= 2
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if color is XYZColorModel {
                color[1] *= 0.5
            }
        }
        
        var result = _convertFromLinear(_convertLinearFromConnection(color))
        
        switch b2a {
        case .monochrome, .matrix, .LUT0:
            if result is XYZColorModel {
                result[0] *= 0.5
                result[2] *= 0.5
            }
        case .LUT1, .LUT2, .LUT3, .LUT4:
            if result is XYZColorModel {
                result[1] *= 2
            }
        }
        
        for i in 0..<Model.numberOfComponents {
            result.setNormalizedComponent(i, result[i])
        }
        
        return result
    }
}

