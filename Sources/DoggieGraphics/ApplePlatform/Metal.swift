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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(Metal)

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension MTLDevice {
    
    public func makeTexture<T>(_ buffer: MappedBuffer<T>, descriptor: MTLTextureDescriptor, bytesPerRow: Int) -> MTLTexture? {
        
        let alignment = self.minimumLinearTextureAlignment(for: descriptor.pixelFormat)
        
        var options: MTLResourceOptions
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            options = descriptor.resourceOptions
            
        } else {
            
            options = []
            
            #if os(macOS) || targetEnvironment(macCatalyst)
            
            switch descriptor.storageMode {
            case .shared: options.insert(.storageModeShared)
            case .managed: options.insert(.storageModeManaged)
            case .private: options.insert(.storageModePrivate)
            default: break
            }
            
            #else
            
            switch descriptor.storageMode {
            case .shared: options.insert(.storageModeShared)
            case .private: options.insert(.storageModePrivate)
            case .memoryless: options.insert(.storageModeMemoryless)
            default: break
            }
            
            #endif
            
            switch descriptor.cpuCacheMode {
            case .writeCombined: options.insert(.cpuCacheModeWriteCombined)
            default: break
            }
        }
        
        guard bytesPerRow % alignment == 0 else { return nil }
        guard let buffer = self.makeBuffer(buffer, options: options) else { return nil }
        
        return buffer.makeTexture(descriptor: descriptor, offset: 0, bytesPerRow: bytesPerRow)
    }
    
    private func _makeTexture<T>(_ buffer: MappedBuffer<T>, descriptor: MTLTextureDescriptor, options: MTLResourceOptions) -> MTLTexture? {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            descriptor.resourceOptions = options
            
        } else {
            
            #if os(macOS) || targetEnvironment(macCatalyst)
            
            if options.contains(.storageModeShared) {
                descriptor.storageMode = .shared
            } else if options.contains(.storageModeManaged) {
                descriptor.storageMode = .managed
            } else if options.contains(.storageModePrivate) {
                descriptor.storageMode = .private
            }
            
            #else
            
            if options.contains(.storageModeShared) {
                descriptor.storageMode = .shared
            } else if options.contains(.storageModePrivate) {
                descriptor.storageMode = .private
            } else if options.contains(.storageModeMemoryless) {
                descriptor.storageMode = .memoryless
            }
            
            #endif
            
            if options.contains(.cpuCacheModeWriteCombined) {
                descriptor.cpuCacheMode = .writeCombined
            }
        }
        
        let bytesPerRow = descriptor.width * MemoryLayout<T>.stride
        return self.makeTexture(buffer, descriptor: descriptor, bytesPerRow: bytesPerRow)
    }
    
    public func makeTexture<Image: RawPixelProtocol>(_ image: Image, usage: MTLTextureUsage = .shaderRead, options: MTLResourceOptions = []) -> MTLTexture? where Image.RawPixel == RGBA32ColorPixel {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: image.width, height: image.height, mipmapped: false)
        descriptor.usage = usage
        
        return self._makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
    
    public func makeTexture<Image: RawPixelProtocol>(_ image: Image, usage: MTLTextureUsage = .shaderRead, options: MTLResourceOptions = []) -> MTLTexture? where Image.RawPixel == BGRA32ColorPixel {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: image.width, height: image.height, mipmapped: false)
        descriptor.usage = usage
        
        return self._makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
    
    public func makeTexture<Image: RawPixelProtocol>(_ image: Image, usage: MTLTextureUsage = .shaderRead, options: MTLResourceOptions = []) -> MTLTexture? where Image.RawPixel == RGBA64ColorPixel {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Unorm, width: image.width, height: image.height, mipmapped: false)
        descriptor.usage = usage
        
        return self._makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
    
    #if swift(>=5.3)
    
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public func makeTexture<Image: RawPixelProtocol>(_ image: Image, usage: MTLTextureUsage = .shaderRead, options: MTLResourceOptions = []) -> MTLTexture? where Image.RawPixel == Float16ColorPixel<RGBColorModel> {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Float, width: image.width, height: image.height, mipmapped: false)
        descriptor.usage = usage
        
        return self._makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
    
    #endif
    
    public func makeTexture<Image: RawPixelProtocol>(_ image: Image, usage: MTLTextureUsage = .shaderRead, options: MTLResourceOptions = []) -> MTLTexture? where Image.RawPixel == Float32ColorPixel<RGBColorModel> {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba32Float, width: image.width, height: image.height, mipmapped: false)
        descriptor.usage = usage
        
        return self._makeTexture(image.pixels, descriptor: descriptor, options: options)
    }
}

#endif
