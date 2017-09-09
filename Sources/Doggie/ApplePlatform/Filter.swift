//
//  Filter.swift
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

#if os(iOS) || os(tvOS) || os(watchOS)
    import CoreImage
#endif

#if os(macOS)
    import QuartzCore
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    
    extension CIFilter {
        
        public subscript(key: String) -> Any? {
            get {
                return self.value(forKey: key)
            }
            set {
                self.setValue(newValue, forKey: key)
            }
        }
        
        public var keys: [String] {
            return self.inputKeys as [String]
        }
    }
    
    extension CIFilter {
        
        public static var EffectInvert: CIFilter {
            let filter = CIFilter(name: "CIColorInvert")!
            filter.setDefaults()
            return filter
        }
        public static var EffectChrome: CIFilter {
            let filter = CIFilter(name: "CIPhotoEffectChrome")!
            filter.setDefaults()
            return filter
        }
        public static var EffectFade: CIFilter {
            let filter = CIFilter(name: "CIPhotoEffectFade")!
            filter.setDefaults()
            return filter
        }
        public static var EffectInstant: CIFilter {
            let filter = CIFilter(name: "CIPhotoEffectInstant")!
            filter.setDefaults()
            return filter
        }
        public static var EffectMono: CIFilter {
            let filter = CIFilter(name: "CIPhotoEffectMono")!
            filter.setDefaults()
            return filter
        }
        public static var EffectNoir: CIFilter {
            let filter = CIFilter(name: "CIPhotoEffectNoir")!
            filter.setDefaults()
            return filter
        }
        public static var EffectProcess: CIFilter {
            let filter = CIFilter(name: "CIPhotoEffectProcess")!
            filter.setDefaults()
            return filter
        }
        public static var EffectTonal: CIFilter {
            let filter = CIFilter(name: "CIPhotoEffectTonal")!
            filter.setDefaults()
            return filter
        }
        public static var EffectTransfer: CIFilter {
            let filter = CIFilter(name: "CIPhotoEffectTransfer")!
            filter.setDefaults()
            return filter
        }
        public static var SRGBToneCurveToLinear: CIFilter {
            let filter = CIFilter(name: "CISRGBToneCurveToLinear")!
            filter.setDefaults()
            return filter
        }
        public static var LinearToSRGBToneCurve: CIFilter {
            let filter = CIFilter(name: "CILinearToSRGBToneCurve")!
            filter.setDefaults()
            return filter
        }
        public static func ExposureAdjust(ev: CGFloat = 0.0) -> CIFilter {
            let filter = CIFilter(name: "CIExposureAdjust")!
            filter.setDefaults()
            filter["inputEV"] = ev
            return filter
        }
        public static func ColorClamp(
            min: CIVector = CIVector(x: 0, y: 0, z: 0, w: 0),
            max: CIVector = CIVector(x: 1, y: 1, z: 1, w: 1)) -> CIFilter {
            let filter = CIFilter(name: "CIColorClamp")!
            filter.setDefaults()
            filter["inputMinComponents"] = min
            filter["inputMaxComponents"] = max
            return filter
        }
        public static func ColorControls(
            saturation: CGFloat = 1,
            brightness: CGFloat = 0,
            contrast: CGFloat = 1) -> CIFilter {
            let filter = CIFilter(name: "CIColorControls")!
            filter.setDefaults()
            filter["inputSaturation"] = saturation
            filter["inputBrightness"] = brightness
            filter["inputContrast"] = contrast
            return filter
        }
        public static func ColorMatrix(
            red: CIVector = CIVector(x: 1, y: 0, z: 0, w: 0),
            green: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
            blue: CIVector = CIVector(x: 0, y: 0, z: 1, w: 0),
            alpha: CIVector = CIVector(x: 0, y: 0, z: 0, w: 1),
            bias: CIVector = CIVector(x: 0, y: 0, z: 0, w: 0)) -> CIFilter {
            let filter = CIFilter(name: "CIColorMatrix")!
            filter.setDefaults()
            filter["inputRVector"] = red
            filter["inputGVector"] = green
            filter["inputBVector"] = blue
            filter["inputAVector"] = alpha
            filter["inputBiasVector"] = bias
            return filter
        }
        public static func ColorPolynomial(
            red: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
            green: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
            blue: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
            alpha: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0)) -> CIFilter {
            let filter = CIFilter(name: "CIColorPolynomial")!
            filter.setDefaults()
            filter["inputRedCoefficients"] = red
            filter["inputGreenCoefficients"] = green
            filter["inputBlueCoefficients"] = blue
            filter["inputAlphaCoefficients"] = alpha
            return filter
        }
        public static func GammaAdjust(power: CGFloat = 0.0) -> CIFilter {
            let filter = CIFilter(name: "CIGammaAdjust")!
            filter.setDefaults()
            filter["inputPower"] = power
            return filter
        }
        public static func HueAdjust(angle: CGFloat = 0.0) -> CIFilter {
            let filter = CIFilter(name: "CIHueAdjust")!
            filter.setDefaults()
            filter["inputAngle"] = angle
            return filter
        }
        public static func TemperatureTint(
            neutral: CIVector = CIVector(x: 6500, y: 0),
            target: CIVector = CIVector(x: 6500, y: 0)) -> CIFilter {
            let filter = CIFilter(name: "CITemperatureAndTint")!
            filter.setDefaults()
            filter["inputNeutral"] = neutral
            filter["inputTargetNeutral"] = target
            return filter
        }
        public static func ToneCurve(
            _ p0: CIVector = CIVector(x: 0, y: 0),
            _ p1: CIVector = CIVector(x: 0.25, y: 0.25),
            _ p2: CIVector = CIVector(x: 0.5, y: 0.5),
            _ p3: CIVector = CIVector(x: 0.75, y: 0.75),
            _ p4: CIVector = CIVector(x: 1, y: 1)) -> CIFilter {
            let filter = CIFilter(name: "CIToneCurve")!
            filter.setDefaults()
            filter["inputPoint0"] = p0
            filter["inputPoint1"] = p1
            filter["inputPoint2"] = p2
            filter["inputPoint3"] = p3
            filter["inputPoint4"] = p4
            return filter
        }
        public static func Vibrance(amount: CGFloat = 0.0) -> CIFilter {
            let filter = CIFilter(name: "CIVibrance")!
            filter.setDefaults()
            filter["inputAmount"] = amount
            return filter
        }
        public static func ColorPosterize(levels: CGFloat = 6.0) -> CIFilter {
            let filter = CIFilter(name: "CIColorPosterize")!
            filter.setDefaults()
            filter["inputLevels"] = levels
            return filter
        }
        public static func Vignette(radius: CGFloat = 1.0, intensity: CGFloat = 0.0) -> CIFilter {
            let filter = CIFilter(name: "CIVignette")!
            filter.setDefaults()
            filter["inputRadius"] = radius
            filter["inputIntensity"] = intensity
            return filter
        }
    }
    
    open class SDFilter {
        
        open var strength: Double {
            didSet {
                strength = max(0, min(1, strength))
            }
        }
        
        open let name: String
        fileprivate var params: [String : Any]
        
        public init(name: String, withInputParameters params: [String : Any]) {
            self.strength = 1
            self.name = name
            self.params = params
        }
        
        public init(filter: CIFilter) {
            self.strength = 0
            self.name = filter.name
            self.params = filter.attributes
        }
        
        open subscript(key: String) -> Any? {
            get {
                return params[key]
            }
            set {
                params[key] = newValue
            }
        }
    }
    
    public extension CGImage {
        
        func applyingFilter(_ filterName: String, withInputParameters params: [String : Any]) -> CIImage {
            return CIImage(cgImage: self).applyingFilter(filterName, parameters: params)
        }
    }
    
    public extension CIImage {
        
        func apply(_ filter: SDFilter) -> CIImage {
            if filter.strength == 0 {
                return self
            }
            if filter.strength == 1 {
                return self.applyingFilter(filter.name, parameters: filter.params)
            }
            return self.applyingFilter("CIDissolveTransition", parameters: ["inputTargetImage": self.applyingFilter(filter.name, parameters: filter.params), kCIAttributeTypeTime: filter.strength])
        }
        
        func apply(_ filters: [SDFilter]) -> CIImage {
            return filters.reduce(self) { $0.apply($1) }
        }
    }
    
    // MARK: Barcode
    
    public func AztecCodeGenerator(_ string: String, correction level: Float = 23, compact: Bool = false, encoding: String.Encoding = String.Encoding.isoLatin1) -> CIImage! {
        if let data = string.data(using: encoding), let code = CIFilter(name: "CIAztecCodeGenerator") {
            code.setDefaults()
            code["inputMessage"] = data
            code["inputCorrectionLevel"] = level
            code["inputCompactStyle"] = compact
            return code.outputImage
        }
        return nil
    }
    
    public enum QRCorrectionLevel {
        case low
        case medium
        case quartile
        case high
    }
    
    public func QRCodeGenerator(_ string: String, correction level: QRCorrectionLevel = .medium, encoding: String.Encoding = String.Encoding.utf8) -> CIImage! {
        if let data = string.data(using: encoding), let code = CIFilter(name: "CIQRCodeGenerator") {
            code.setDefaults()
            code["inputMessage"] = data
            switch level {
            case .low:
                code["inputCorrectionLevel"] = "L"
            case .medium:
                code["inputCorrectionLevel"] = "M"
            case .quartile:
                code["inputCorrectionLevel"] = "Q"
            case .high:
                code["inputCorrectionLevel"] = "H"
            }
            return code.outputImage
        }
        return nil
    }
    
    public func Code128BarcodeGenerator(_ string: String) -> CIImage! {
        if let data = string.data(using: String.Encoding.ascii), let code = CIFilter(name: "CICode128BarcodeGenerator") {
            code.setDefaults()
            code["inputMessage"] = data
            return code.outputImage
        }
        return nil
    }
    
#endif
