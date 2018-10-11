//
//  Metal.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

import Metal

@available(OSX 10.11, iOS 8.0, tvOS 9.0, *)
extension MTLDevice {
    
    public func makeBuffer<T>(_ buffer: MappedBuffer<T>, options: MTLResourceOptions = []) -> MTLBuffer? {
        var box = MappedBuffer<T>._Box(ref: buffer.base)
        let length = (buffer.count * MemoryLayout<T>.stride).align(Int(getpagesize()))
        return self.makeBuffer(bytesNoCopy: buffer.base.address, length: length, options: options, deallocator: { _, _ in box.ref = nil })
    }
}

@available(OSX 10.13, iOS 8.0, tvOS 9.0, *)
extension MTLDevice {
    
    private func makeTexture<T>(_ buffer: MappedBuffer<T>, descriptor: MTLTextureDescriptor, options: MTLResourceOptions) -> MTLTexture? {
        guard let buffer = self.makeBuffer(buffer, options: options) else { return nil }
        return buffer.makeTexture(descriptor: descriptor, offset: 0, bytesPerRow: descriptor.width * MemoryLayout<T>.stride)
    }
    
    public func makeTexture(_ image: Image<RGBA32ColorPixel>, options: MTLResourceOptions = []) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Uint, width: image.width, height: image.height, mipmapped: false)
        return self.makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
    
    public func makeTexture(_ image: Image<RGBA64ColorPixel>, options: MTLResourceOptions = []) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Uint, width: image.width, height: image.height, mipmapped: false)
        return self.makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
    
    public func makeTexture(_ image: Image<FloatColorPixel<RGBColorModel>>, options: MTLResourceOptions = []) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba32Float, width: image.width, height: image.height, mipmapped: false)
        return self.makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
    
    public func makeTexture(_ texture: Texture<RGBA32ColorPixel>, options: MTLResourceOptions = []) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Uint, width: texture.width, height: texture.height, mipmapped: false)
        return self.makeTexture(texture.pixels, descriptor: descriptor, options: options)
    }
    
    public func makeTexture(_ texture: Texture<RGBA64ColorPixel>, options: MTLResourceOptions = []) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Uint, width: texture.width, height: texture.height, mipmapped: false)
        return self.makeTexture(texture.pixels, descriptor: descriptor, options: options)
    }
    
    public func makeTexture(_ texture: Texture<FloatColorPixel<RGBColorModel>>, options: MTLResourceOptions = []) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba32Float, width: texture.width, height: texture.height, mipmapped: false)
        return self.makeTexture(texture.pixels, descriptor: descriptor, options: options)
    }
}

#endif

