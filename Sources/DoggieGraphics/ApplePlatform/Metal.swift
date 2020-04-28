//
//  Metal.swift
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

#if canImport(Metal)

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension MTLDevice {
    
    private func makeTexture<T>(_ buffer: MappedBuffer<T>, descriptor: MTLTextureDescriptor, options: MTLResourceOptions) -> MTLTexture? {
        
        let bytesPerRow = descriptor.width * MemoryLayout<T>.stride
        let alignment = self.minimumLinearTextureAlignment(for: descriptor.pixelFormat)
        
        guard bytesPerRow % alignment == 0 else { return nil }
        guard let buffer = self.makeBuffer(buffer, options: options) else { return nil }
        
        return buffer.makeTexture(descriptor: descriptor, offset: 0, bytesPerRow: bytesPerRow)
    }
    
    public func makeTexture<Image: RawPixelProtocol>(_ image: Image, usage: MTLTextureUsage = .shaderRead, options: MTLResourceOptions = []) -> MTLTexture? where Image.RawPixel == RGBA32ColorPixel {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: image.width, height: image.height, mipmapped: false)
        descriptor.usage = usage
        
        return self.makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
    
    public func makeTexture<Image: RawPixelProtocol>(_ image: Image, usage: MTLTextureUsage = .shaderRead, options: MTLResourceOptions = []) -> MTLTexture? where Image.RawPixel == BGRA32ColorPixel {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: image.width, height: image.height, mipmapped: false)
        descriptor.usage = usage
        
        return self.makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
    
    public func makeTexture<Image: RawPixelProtocol>(_ image: Image, usage: MTLTextureUsage = .shaderRead, options: MTLResourceOptions = []) -> MTLTexture? where Image.RawPixel == RGBA64ColorPixel {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Unorm, width: image.width, height: image.height, mipmapped: false)
        descriptor.usage = usage
        
        return self.makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
    
    public func makeTexture<Image: RawPixelProtocol>(_ image: Image, usage: MTLTextureUsage = .shaderRead, options: MTLResourceOptions = []) -> MTLTexture? where Image.RawPixel == Float32ColorPixel<RGBColorModel> {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba32Float, width: image.width, height: image.height, mipmapped: false)
        descriptor.usage = usage
        
        return self.makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
}

#endif