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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(CoreImage)

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension CIContext {
    
    open func render(_ image: CIImage, to texture: MTLTexture, commandBuffer: MTLCommandBuffer?, bounds: CGRect, at atPoint: CGPoint, colorSpace: CGColorSpace?) {
        
        do {
            
            let destination = CIRenderDestination(mtlTexture: texture, commandBuffer: commandBuffer)
            destination.colorSpace = colorSpace
            
            let result = try self.startTask(toRender: image, from: bounds, to: destination, at: atPoint)
            
            if commandBuffer == nil {
                try result.waitUntilCompleted()
            }
            
        } catch let error {
            
            NSLog("%@", "\(error)")
        }
    }
}

extension CIContext {
    
    open func createImage(_ image: CIImage, from fromRect: Rect, colorSpace: ColorSpace<RGBColorModel>, fileBacked: Bool = false) -> Image<RGBA32ColorPixel>? {
        
        guard let width = Int(exactly: ceil(fromRect.width)) else { return nil }
        guard let height = Int(exactly: ceil(fromRect.height)) else { return nil }
        guard width > 0 && height > 0 else { return nil }
        
        guard let cgColorSpace = colorSpace.cgColorSpace else { return nil }
        var result = Image<RGBA32ColorPixel>(width: width, height: height, colorSpace: colorSpace, fileBacked: fileBacked)
        
        result.withUnsafeMutableBytes {
            guard let bitmap = $0.baseAddress else { return }
            self.render(image, toBitmap: bitmap, rowBytes: width * 4, bounds: CGRect(fromRect), format: .RGBA8, colorSpace: cgColorSpace)
        }
        
        return result
    }
    
    open func createTexture(_ image: CIImage, from fromRect: Rect, colorSpace: ColorSpace<RGBColorModel>? = nil, fileBacked: Bool = false) -> Texture<RGBA32ColorPixel>? {
        
        guard let width = Int(exactly: ceil(fromRect.width)) else { return nil }
        guard let height = Int(exactly: ceil(fromRect.height)) else { return nil }
        guard width > 0 && height > 0 else { return nil }
        
        var result = Texture<RGBA32ColorPixel>(width: width, height: height, fileBacked: fileBacked)
        
        result.withUnsafeMutableBytes {
            guard let bitmap = $0.baseAddress else { return }
            self.render(image, toBitmap: bitmap, rowBytes: width * 4, bounds: CGRect(fromRect), format: .RGBA8, colorSpace: colorSpace?.cgColorSpace)
        }
        
        return result
    }
}

#if canImport(CoreVideo)

extension CIContext {
    
    @available(macOS 10.11, tvOS 9.0, *)
    open func createCVPixelBuffer(_ image: CIImage, from fromRect: CGRect, colorSpace: CGColorSpace? = nil) -> CVPixelBuffer? {
        
        guard let width = Int(exactly: ceil(fromRect.width)) else { return nil }
        guard let height = Int(exactly: ceil(fromRect.height)) else { return nil }
        guard width > 0 && height > 0 else { return nil }
        
        var _buffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32BGRA, nil, &_buffer)
        
        guard status == kCVReturnSuccess, let buffer = _buffer else { return nil }
        
        self.render(image, to: buffer, bounds: fromRect, colorSpace: colorSpace)
        
        return buffer
    }
}

#endif

#endif
