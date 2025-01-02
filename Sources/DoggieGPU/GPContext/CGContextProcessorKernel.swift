//
//  CGContextProcessorKernel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(CoreImage)

final class CGContextProcessorKernel: CIImageProcessorKernel {
    
    enum Error: Swift.Error {
        
        case unknown
        
        case unsupportedFormat
    }
    
    private struct Info {
        
        let colorSpace: CGColorSpace
        
        let transform: CGAffineTransform
        
        let shouldAntialias: Bool
        
        let callback: (CGContext) throws -> Void
    }
    
    class func apply(withExtent extent: CGRect, colorSpace: CGColorSpace, transform: CGAffineTransform, shouldAntialias: Bool, callback: @escaping (CGContext) throws -> Void) throws -> CIImage {
        let image = try self.apply(withExtent: extent, inputs: nil, arguments: ["info": Info(colorSpace: colorSpace, transform: transform, shouldAntialias: shouldAntialias, callback: callback)])
        return image.matchedToWorkingSpace(from: colorSpace) ?? image
    }
    
    override class var outputFormat: CIFormat {
        return .BGRA8
    }
    
    override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
        
        guard let info = arguments?["info"] as? Info else { throw Error.unknown }
        
        let width = Int(output.region.width)
        let height = Int(output.region.height)
        
        let baseAddress = output.baseAddress
        let bytesPerRow = output.bytesPerRow
        
        memset(baseAddress, 0, bytesPerRow * height)
        
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: info.colorSpace, bitmapInfo: CGImageByteOrderInfo.order32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) else { throw Error.unknown }
        
        context.translateBy(x: -output.region.minX, y: -output.region.minY)
        
        context.concatenate(info.transform)
        context.setShouldAntialias(info.shouldAntialias)
        
        try info.callback(context)
    }
}

#endif
