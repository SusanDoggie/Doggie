//
//  CIContext.swift
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

extension CIContext {
    
    open func createImage(_ image: CIImage, from fromRect: Rect, colorSpace: ColorSpace<RGBColorModel>) -> Image<RGBA32ColorPixel>? {
        
        let width = Int(ceil(fromRect.width))
        let height = Int(ceil(fromRect.height))
        
        guard let cgColorSpace = colorSpace.cgColorSpace else { return nil }
        var result = Image<RGBA32ColorPixel>(width: width, height: height, colorSpace: colorSpace)
        
        result.withUnsafeMutableBytes {
            guard let bitmap = $0.baseAddress else { return }
            self.render(image, toBitmap: bitmap, rowBytes: width * 4, bounds: CGRect(fromRect), format: .RGBA8, colorSpace: cgColorSpace)
        }
        
        return result
    }
}

#if canImport(CoreVideo)

extension CIContext {
    
    open func createCVPixelBuffer(_ image: CIImage, from fromRect: CGRect, colorSpace: CGColorSpace? = nil) -> CVPixelBuffer? {
        
        let width = Int(ceil(fromRect.width))
        let height = Int(ceil(fromRect.height))
        
        var _buffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32RGBA, nil, &_buffer)
        
        guard status == kCVReturnSuccess, let buffer = _buffer else { return nil }
        
        self.render(image, to: buffer, bounds: fromRect, colorSpace: colorSpace)
        
        return buffer
    }
}

#endif

#endif
