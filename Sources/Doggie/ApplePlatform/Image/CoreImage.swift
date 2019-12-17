//
//  CoreImage.swift
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

#if canImport(CoreImage) || canImport(QuartzCore)

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

extension CGImage {
    
    public func applyingFilter(_ filterName: String, withInputParameters params: [String : Any]) -> CIImage {
        return CIImage(cgImage: self).applyingFilter(filterName, parameters: params)
    }
}

extension CIImage {
    
    public func transformed(by transform: SDTransform) -> CIImage {
        return self.transformed(by: CGAffineTransform(transform))
    }
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
    public func clamped(to rect: Rect) -> CIImage {
        return self.clamped(to: CGRect(rect))
    }
    
    public func cropped(to rect: Rect) -> CIImage {
        return self.cropped(to: CGRect(rect))
    }
}

extension CIImage {
    
    public func convolve(_ matrix: [Double], _ orderX: Int, _ orderY: Int) -> CIImage? {
        
        precondition(orderX > 0, "invalid orderX.")
        precondition(orderY > 0, "invalid orderY.")
        precondition(orderX * orderY == matrix.count, "mismatch matrix count.")
        
        let matrix = Array(matrix.chunked(by: orderX).lazy.map { $0.reversed() }.joined())
        
        if orderX <= 5 && orderY <= 5 {
            
            let append_x = 5 - orderX
            let append_y = 5 - orderY
            
            var _matrix = Array(matrix.chunked(by: orderX).joined(separator: repeatElement(0, count: append_x)))
            _matrix.append(contentsOf: repeatElement(0, count: append_x + 5 * append_y))
            
            let convolved = self.applyingFilter("CIConvolution5X5", parameters: ["inputWeights": CIVector(_matrix)])
            
            return append_x == 0 && append_y == 0 ? convolved : convolved.transformed(by: CGAffineTransform(translationX: 0.5 * CGFloat(append_x), y: 0.5 * CGFloat(append_y)))
        }
        
        if orderX <= 7 && orderY <= 7 {
            
            let append_x = 7 - orderX
            let append_y = 7 - orderY
            
            var _matrix = Array(matrix.chunked(by: orderX).joined(separator: repeatElement(0, count: append_x)))
            _matrix.append(contentsOf: repeatElement(0, count: append_x + 7 * append_y))
            
            let convolved = self.applyingFilter("CIConvolution7X7", parameters: ["inputWeights": CIVector(_matrix)])
            
            return append_x == 0 && append_y == 0 ? convolved : convolved.transformed(by: CGAffineTransform(translationX: 0.5 * CGFloat(append_x), y: 0.5 * CGFloat(append_y)))
        }
        
        if orderX <= 9 && orderY <= 9, var (horizontal, vertical) = separate_convolution_filter(matrix, orderX, orderY) {
            
            let append_x = 9 - orderX
            let append_y = 9 - orderY
            
            horizontal.append(contentsOf: repeatElement(0, count: append_x))
            vertical.append(contentsOf: repeatElement(0, count: append_y))
            
            let convolved = self.applyingFilter("CIConvolution9Horizontal", parameters: ["inputWeights": CIVector(horizontal.reversed())])
                .applyingFilter("CIConvolution9Vertical", parameters: ["inputWeights": CIVector(vertical.reversed())])
            
            return append_x == 0 && append_y == 0 ? convolved : convolved.transformed(by: CGAffineTransform(translationX: 0.5 * CGFloat(append_x), y: 0.5 * CGFloat(append_y)))
        }
        
        return nil
    }
}

extension CIVector {
    
    public convenience init<C: Collection>(_ values: C) where C.Element : BinaryFloatingPoint {
        self.init(values: values.map { CGFloat($0) }, count: values.count)
    }
    
    public convenience init<T: BinaryFloatingPoint>(_ values: T ...) {
        self.init(values)
    }
    
    public convenience init(_ point: Point) {
        self.init(cgPoint: CGPoint(point))
    }
    
    public convenience init(_ point: Vector) {
        self.init(point.x, point.y, point.z)
    }
    
    public convenience init(_ size: Size) {
        self.init(size.width, size.height)
    }
    
    public convenience init(_ rect: Rect) {
        self.init(cgRect: CGRect(rect))
    }
    
    public convenience init(_ transform: SDTransform) {
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
