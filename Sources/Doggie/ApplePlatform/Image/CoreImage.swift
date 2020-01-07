//
//  CoreImage.swift
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

#if canImport(CoreImage)

extension CIFilter {
    
    open subscript(key: String) -> Any? {
        get {
            return self.value(forKey: key)
        }
        set {
            self.setValue(newValue, forKey: key)
        }
    }
    
    open var keys: [String] {
        return self.inputKeys as [String]
    }
}

extension CGImage {
    
    open func applyingFilter(_ filterName: String, withInputParameters params: [String : Any]) -> CIImage {
        return CIImage(cgImage: self).applyingFilter(filterName, parameters: params)
    }
}

extension CIImage {
    
    open func transformed(by transform: SDTransform) -> CIImage {
        return self.transformed(by: CGAffineTransform(transform))
    }
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
    open func clamped(to rect: Rect) -> CIImage {
        return self.clamped(to: CGRect(rect))
    }
    
    open func cropped(to rect: Rect) -> CIImage {
        return self.cropped(to: CGRect(rect))
    }
}

extension CIVector {
    
    open convenience init<C: Collection>(_ values: C) where C.Element : BinaryFloatingPoint {
        self.init(values: values.map { CGFloat($0) }, count: values.count)
    }
    
    open convenience init<T: BinaryFloatingPoint>(_ values: T ...) {
        self.init(values)
    }
    
    open convenience init(_ point: Point) {
        self.init(cgPoint: CGPoint(point))
    }
    
    open convenience init(_ point: Vector) {
        self.init(point.x, point.y, point.z)
    }
    
    open convenience init(_ size: Size) {
        self.init(size.width, size.height)
    }
    
    open convenience init(_ rect: Rect) {
        self.init(cgRect: CGRect(rect))
    }
    
    open convenience init(_ transform: SDTransform) {
        self.init(cgAffineTransform: CGAffineTransform(transform))
    }
}

// MARK: Barcode

public func AztecCodeGenerator(_ string: String, correction level: Float = 23, compact: Bool = false, encoding: String.Encoding = String.Encoding.isoLatin1) -> CIImage? {
    guard let data = string.data(using: encoding) else { return nil }
    guard let code = CIFilter(name: "CIAztecCodeGenerator") else { return nil }
    code.setDefaults()
    code["inputMessage"] = data
    code["inputCorrectionLevel"] = level
    code["inputCompactStyle"] = compact
    return code.outputImage
}

public enum QRCorrectionLevel : CaseIterable {
    case low
    case medium
    case quartile
    case high
}

public func QRCodeGenerator(_ string: String, correction level: QRCorrectionLevel = .medium, encoding: String.Encoding = String.Encoding.utf8) -> CIImage? {
    guard let data = string.data(using: encoding) else { return nil }
    guard let code = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    code.setDefaults()
    code["inputMessage"] = data
    switch level {
    case .low: code["inputCorrectionLevel"] = "L"
    case .medium: code["inputCorrectionLevel"] = "M"
    case .quartile: code["inputCorrectionLevel"] = "Q"
    case .high: code["inputCorrectionLevel"] = "H"
    }
    return code.outputImage
}

public func Code128BarcodeGenerator(_ string: String) -> CIImage? {
    guard let data = string.data(using: String.Encoding.ascii) else { return nil }
    guard let code = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }
    code.setDefaults()
    code["inputMessage"] = data
    return code.outputImage
}

#endif
