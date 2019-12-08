//
//  ICCColorSpace.swift
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

@usableFromInline
let PCSXYZ = CIEXYZColorSpace(white: _D50)

@usableFromInline
protocol PCSColorModel : ColorModelProtocol {
    
    var luminance: Double { get set }
    
    static func * (lhs: Self, rhs: Matrix) -> Self
    
    static func *= (lhs: inout Self, rhs: Matrix)
}

extension XYZColorModel : PCSColorModel {
    
}

extension LabColorModel : PCSColorModel {
    
    @inlinable
    var luminance: Double {
        get {
            return lightness
        }
        set {
            lightness = newValue
        }
    }
    
    @inlinable
    static func * (lhs: LabColorModel, rhs: Matrix) -> LabColorModel {
        return LabColorModel(lightness: lhs.lightness * rhs.a + lhs.a * rhs.b + lhs.b * rhs.c + rhs.d, a: lhs.lightness * rhs.e + lhs.a * rhs.f + lhs.b * rhs.g + rhs.h, b: lhs.lightness * rhs.i + lhs.a * rhs.j + lhs.b * rhs.k + rhs.l)
    }
    
    @inlinable
    static func *= (lhs: inout LabColorModel, rhs: Matrix) {
        lhs = lhs * rhs
    }
}

@frozen
@usableFromInline
struct ICCColorSpace<Model : ColorModelProtocol, Connection : ColorSpaceBaseProtocol, A2BTransform: iccTransform, B2ATransform: iccTransform> : ColorSpaceBaseProtocol where Connection.Model : PCSColorModel {
    
    @usableFromInline
    let _iccData: Data
    
    @usableFromInline
    let profile: iccProfile
    
    @usableFromInline
    let connection : Connection
    
    @usableFromInline
    let cieXYZ : CIEXYZColorSpace
    
    @usableFromInline
    let a2b: A2BTransform
    
    @usableFromInline
    let b2a: B2ATransform
    
    @usableFromInline
    let chromaticAdaptationMatrix: Matrix
    
    init(iccData: Data, profile: iccProfile, model: Model.Type, connection : Connection, cieXYZ : CIEXYZColorSpace, a2b: A2BTransform, b2a: B2ATransform, chromaticAdaptationMatrix: Matrix) {
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
    
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine("ICCColorSpace")
        hasher.combine(_iccData)
    }
    
    @inlinable
    static func ==(lhs: ICCColorSpace, rhs: ICCColorSpace) -> Bool {
        return lhs.isStorageEqual(rhs) || lhs._iccData == rhs._iccData
    }
    
    @inlinable
    func isStorageEqual(_ other: _ColorSpaceBaseProtocol) -> Bool {
        guard let other = other as? ICCColorSpace else { return false }
        return self._iccData.isStorageEqual(other._iccData)
    }
}

extension ICCColorSpace {
    
    @usableFromInline
    var iccData: Data? {
        return _iccData
    }
}

extension ICCColorSpace {
    
    @usableFromInline
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
        case .YCbCr: self._base = try ColorSpace<YCbCrColorModel>(iccData: iccData, profile: profile)
        case .Yxy: self._base = try ColorSpace<YxyColorModel>(iccData: iccData, profile: profile)
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
        case .colorA: self._base = try ColorSpace<DeviceAColorModel>(iccData: iccData, profile: profile)
        case .colorB: self._base = try ColorSpace<DeviceBColorModel>(iccData: iccData, profile: profile)
        case .colorC: self._base = try ColorSpace<DeviceCColorModel>(iccData: iccData, profile: profile)
        case .colorD: self._base = try ColorSpace<DeviceDColorModel>(iccData: iccData, profile: profile)
        case .colorE: self._base = try ColorSpace<DeviceEColorModel>(iccData: iccData, profile: profile)
        case .colorF: self._base = try ColorSpace<DeviceFColorModel>(iccData: iccData, profile: profile)
        default: throw AnyColorSpace.ICCError.unsupported(message: "ColorSpace: \(profile.header.colorSpace)")
        }
    }
}

extension iccLUTTransform {
    
    var _iccTransform: iccTransform {
        switch self {
        case let .LUT0(lut): return lut
        case let .LUT1(lut): return lut
        case let .LUT2(lut): return lut
        case let .LUT3(lut): return lut
        case let .LUT4(lut): return lut
        }
    }
}

extension ColorSpace {
    
    static func check(_ a2bCurve: iccLUTTransform, _ b2aCurve: iccLUTTransform) throws {
        
        switch a2bCurve {
        case let .LUT0(lut):
            if lut.clut.inputChannels != Model.numberOfComponents || lut.clut.outputChannels != 3 {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
            if lut.input.channels != Model.numberOfComponents {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
            if lut.output.channels != 3 {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
        case .LUT1, .LUT2:
            if Model.numberOfComponents != 3 {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
        case let .LUT3(lut):
            if lut.lut.inputChannels != Model.numberOfComponents || lut.lut.outputChannels != 3 {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
            if lut.A.count != Model.numberOfComponents {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
        case let .LUT4(lut):
            if lut.lut.inputChannels != Model.numberOfComponents || lut.lut.outputChannels != 3 {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
            if lut.A.count != Model.numberOfComponents {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
        }
        
        switch b2aCurve {
        case let .LUT0(lut):
            if lut.clut.inputChannels != 3 || lut.clut.outputChannels != Model.numberOfComponents {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
            if lut.input.channels != 3 {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
            if lut.output.channels != Model.numberOfComponents {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
        case .LUT1, .LUT2:
            if Model.numberOfComponents != 3 {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
        case let .LUT3(lut):
            if lut.lut.inputChannels != 3 || lut.lut.outputChannels != Model.numberOfComponents {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
            if lut.A.count != Model.numberOfComponents {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
        case let .LUT4(lut):
            if lut.lut.inputChannels != 3 || lut.lut.outputChannels != Model.numberOfComponents {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
            if lut.A.count != Model.numberOfComponents {
                throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT size.")
            }
        }
    }
    
    static func ABCurve(profile: iccProfile) throws -> (iccLUTTransform, iccLUTTransform)? {
        
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
    
    init(iccData: Data, profile: iccProfile) throws {
        
        let a2b: iccTransform
        let b2a: iccTransform
        
        switch Model.numberOfComponents {
        case 1:
            
            if let curve = profile[.GrayTRC] {
                
                let kTRC = curve.curve ?? .identity
                
                a2b = iccMonochromeTransform(curve: kTRC)
                b2a = iccMonochromeTransform(curve: kTRC.inverse)
                
            } else if let (a2bCurve, b2aCurve) = try ColorSpace.ABCurve(profile: profile) {
                
                a2b = a2bCurve._iccTransform
                b2a = b2aCurve._iccTransform
                
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
                
                a2b = iccMatrixTransform(matrix: matrix, curve: (rTRC, gTRC, bTRC))
                b2a = iccMatrixTransform(matrix: matrix.inverse, curve: (rTRC.inverse, gTRC.inverse, bTRC.inverse))
                
            } else if let (a2bCurve, b2aCurve) = try ColorSpace.ABCurve(profile: profile) {
                
                a2b = a2bCurve._iccTransform
                b2a = b2aCurve._iccTransform
                
            } else {
                throw AnyColorSpace.ICCError.invalidFormat(message: "LUT not found.")
            }
            
        default:
            
            if let (a2bCurve, b2aCurve) = try ColorSpace.ABCurve(profile: profile) {
                
                a2b = a2bCurve._iccTransform
                b2a = b2aCurve._iccTransform
                
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
        
        func _createICCColorSpace3<A2BTransform: iccTransform, B2ATransform: iccTransform>(_ a2b: A2BTransform, _ b2a: B2ATransform) throws -> _ColorSpaceBaseProtocol {
            switch profile.header.pcs {
            case .XYZ: return ICCColorSpace(iccData: iccData, profile: profile, model: Model.self, connection: PCSXYZ, cieXYZ: cieXYZ, a2b: a2b, b2a: b2a, chromaticAdaptationMatrix: chromaticAdaptationMatrix)
            case .Lab: return ICCColorSpace(iccData: iccData, profile: profile, model: Model.self, connection: CIELabColorSpace(PCSXYZ), cieXYZ: cieXYZ, a2b: a2b, b2a: b2a, chromaticAdaptationMatrix: chromaticAdaptationMatrix)
            default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid PCS.")
            }
        }
        
        func _createICCColorSpace2<A2BTransform: iccTransform>(_ a2b: A2BTransform) throws -> _ColorSpaceBaseProtocol {
            switch b2a {
            case let b2a as iccMonochromeTransform: return try _createICCColorSpace3(a2b, b2a)
            case let b2a as iccMatrixTransform: return try _createICCColorSpace3(a2b, b2a)
            case let b2a as iccLUT0Transform: return try _createICCColorSpace3(a2b, b2a)
            case let b2a as iccLUT1Transform: return try _createICCColorSpace3(a2b, b2a)
            case let b2a as iccLUT2Transform: return try _createICCColorSpace3(a2b, b2a)
            case let b2a as iccLUT3Transform: return try _createICCColorSpace3(a2b, b2a)
            case let b2a as iccLUT4Transform: return try _createICCColorSpace3(a2b, b2a)
            default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT.")
            }
        }
        
        func _createICCColorSpace() throws -> _ColorSpaceBaseProtocol {
            switch a2b {
            case let a2b as iccMonochromeTransform: return try _createICCColorSpace2(a2b)
            case let a2b as iccMatrixTransform: return try _createICCColorSpace2(a2b)
            case let a2b as iccLUT0Transform: return try _createICCColorSpace2(a2b)
            case let a2b as iccLUT1Transform: return try _createICCColorSpace2(a2b)
            case let a2b as iccLUT2Transform: return try _createICCColorSpace2(a2b)
            case let a2b as iccLUT3Transform: return try _createICCColorSpace2(a2b)
            case let a2b as iccLUT4Transform: return try _createICCColorSpace2(a2b)
            default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid LUT.")
            }
        }
        
        self.base = try _createICCColorSpace()
    }
    
    static func _PCSXYZ_black_point(a2b: iccTransform, b2a: iccTransform) -> XYZColorModel {
        
        let color: Model
        var black = XYZColorModel()
        
        switch b2a {
        case is iccMonochromeTransform: return XYZColorModel()
        default: color = b2a.convertFromLinear(b2a.convertLinearFromConnection(black))
        }
        
        switch a2b {
        case is iccMonochromeTransform: return XYZColorModel()
        default: black = a2b.convertLinearToConnection(a2b.convertToLinear(color))
        }
        
        black = a2b.denormalize(black)
        
        black.setNormalizedComponent(0, black.x)
        black.setNormalizedComponent(1, black.y)
        black.setNormalizedComponent(2, black.z)
        
        return black
    }
    
    static func _PCSLab_black_point(a2b: iccTransform, b2a: iccTransform) -> XYZColorModel {
        
        let color: Model
        var black = LabColorModel(lightness: 0, a: 0.5, b: 0.5)
        
        switch b2a {
        case is iccMonochromeTransform: return XYZColorModel()
        default: color = b2a.convertFromLinear(b2a.convertLinearFromConnection(black))
        }
        
        switch a2b {
        case is iccMonochromeTransform: return XYZColorModel()
        default: black = a2b.convertLinearToConnection(a2b.convertToLinear(color))
        }
        
        black.setNormalizedComponent(0, black.lightness)
        black.setNormalizedComponent(1, black.a)
        black.setNormalizedComponent(2, black.b)
        
        return CIELabColorSpace(PCSXYZ).convertToXYZ(black)
    }
    
}

extension ICCColorSpace {
    
    @inlinable
    @inline(__always)
    func _convertToLinear(_ color: Model) -> Model {
        return a2b.convertToLinear(color)
    }
    
    @inlinable
    @inline(__always)
    func _convertFromLinear(_ color: Model) -> Model {
        return b2a.convertFromLinear(color)
    }
    
    @inlinable
    @inline(__always)
    func _convertLinearToConnection(_ color: Model) -> Connection.Model {
        
        switch a2b {
        case is iccMonochromeTransform:
            
            var result = Connection.Model()
            
            let normalizeMatrix = self.connection.cieXYZ.normalizeMatrix
            let white = self.connection.cieXYZ.white * normalizeMatrix * color[0] * normalizeMatrix.inverse
            result = self.connection.convertFromXYZ(white)
            
            return result
            
        default: return a2b.convertLinearToConnection(color)
        }
    }
    
    @inlinable
    @inline(__always)
    func _convertLinearFromConnection(_ color: Connection.Model) -> Model {
        return b2a.convertLinearFromConnection(color)
    }
    
    @inlinable
    @inline(__always)
    func convertToLinear(_ color: Model) -> Model {
        
        var color = color
        
        for i in 0..<Model.numberOfComponents {
            color[i] = color.normalizedComponent(i)
        }
        
        if let xyz = color as? XYZColorModel {
            color = a2b.normalize(xyz) as! Model
        }
        
        var result = _convertToLinear(color)
        
        if let xyz = result as? XYZColorModel {
            result = a2b.denormalize(xyz) as! Model
        }
        
        for i in 0..<Model.numberOfComponents {
            result.setNormalizedComponent(i, result[i])
        }
        
        return result
    }
    
    @inlinable
    @inline(__always)
    func convertFromLinear(_ color: Model) -> Model {
        
        var color = color
        
        for i in 0..<Model.numberOfComponents {
            color[i] = color.normalizedComponent(i)
        }
        
        if let xyz = color as? XYZColorModel {
            color = b2a.normalize(xyz) as! Model
        }
        
        var result = _convertFromLinear(color)
        
        if let xyz = result as? XYZColorModel {
            result = b2a.denormalize(xyz) as! Model
        }
        
        for i in 0..<Model.numberOfComponents {
            result.setNormalizedComponent(i, result[i])
        }
        
        return result
    }
    
    @inlinable
    @inline(__always)
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        
        var color = color
        
        for i in 0..<Model.numberOfComponents {
            color[i] = color.normalizedComponent(i)
        }
        
        if let xyz = color as? XYZColorModel {
            color = a2b.normalize(xyz) as! Model
        }
        
        var result = _convertLinearToConnection(color)
        
        if let xyz = result as? XYZColorModel {
            result = a2b.denormalize(xyz) as! Connection.Model
        }
        
        result.setNormalizedComponent(0, result[0])
        result.setNormalizedComponent(1, result[1])
        result.setNormalizedComponent(2, result[2])
        
        return self.connection.convertToXYZ(result) * chromaticAdaptationMatrix.inverse
    }
    
    @inlinable
    @inline(__always)
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        
        var color = self.connection.convertFromXYZ(color * chromaticAdaptationMatrix)
        
        color[0] = color.normalizedComponent(0)
        color[1] = color.normalizedComponent(1)
        color[2] = color.normalizedComponent(2)
        
        if let xyz = color as? XYZColorModel {
            color = b2a.normalize(xyz) as! Connection.Model
        }
        
        var result = _convertLinearFromConnection(color)
        
        if let xyz = result as? XYZColorModel {
            result = b2a.denormalize(xyz) as! Model
        }
        
        for i in 0..<Model.numberOfComponents {
            result.setNormalizedComponent(i, result[i])
        }
        
        return result
    }
    
    @inlinable
    @inline(__always)
    func convertToXYZ(_ color: Model) -> XYZColorModel {
        
        var color = color
        
        for i in 0..<Model.numberOfComponents {
            color[i] = color.normalizedComponent(i)
        }
        
        if let xyz = color as? XYZColorModel {
            color = a2b.normalize(xyz) as! Model
        }
        
        var result = _convertLinearToConnection(_convertToLinear(color))
        
        if let xyz = result as? XYZColorModel {
            result = a2b.denormalize(xyz) as! Connection.Model
        }
        
        result.setNormalizedComponent(0, result[0])
        result.setNormalizedComponent(1, result[1])
        result.setNormalizedComponent(2, result[2])
        
        return self.connection.convertToXYZ(result) * chromaticAdaptationMatrix.inverse
    }
    
    @inlinable
    @inline(__always)
    func convertFromXYZ(_ color: XYZColorModel) -> Model {
        
        var color = self.connection.convertFromXYZ(color * chromaticAdaptationMatrix)
        
        color[0] = color.normalizedComponent(0)
        color[1] = color.normalizedComponent(1)
        color[2] = color.normalizedComponent(2)
        
        if let xyz = color as? XYZColorModel {
            color = b2a.normalize(xyz) as! Connection.Model
        }
        
        var result = _convertFromLinear(_convertLinearFromConnection(color))
        
        if let xyz = result as? XYZColorModel {
            result = b2a.denormalize(xyz) as! Model
        }
        
        for i in 0..<Model.numberOfComponents {
            result.setNormalizedComponent(i, result[i])
        }
        
        return result
    }
}

