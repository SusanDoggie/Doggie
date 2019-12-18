//
//  CGPathProcessorKernel.swift
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

@available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
final class CGPathProcessorKernel: CIImageProcessorKernel {
    
    enum Error : Swift.Error {
        
        case unknown
        
        case unsupportedFormat
    }
    
    private struct Info {
        
        let path: CGPath
        
        let rule: CGPathFillRule
        
        let shouldAntialias: Bool
    }
    
    class func apply(withExtent extent: CGRect, path: CGPath, rule: CGPathFillRule, shouldAntialias: Bool) throws -> CIImage {
        let image = try self.apply(withExtent: extent, inputs: nil, arguments: ["info": Info(path: path, rule: rule, shouldAntialias: shouldAntialias)])
        return image.applyingFilter("CIMaximumComponent", parameters: [:])
    }
    
    override class var outputFormat: CIFormat {
        return .R8
    }
    
    override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String : Any]?, output: CIImageProcessorOutput) throws {
        
        guard let info = arguments?["info"] as? Info else { throw Error.unknown }
        
        let width = Int(output.region.width)
        let height = Int(output.region.height)
        
        guard let context = CGContext(data: output.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: output.bytesPerRow, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue) else { throw Error.unknown }
        
        context.translateBy(x: -output.region.minX, y: -output.region.minY)
        
        context.setBlendMode(.copy)
        context.setShouldAntialias(info.shouldAntialias)
        
        context.addPath(info.path)
        context.fillPath(using: info.rule)
    }
}

#endif
