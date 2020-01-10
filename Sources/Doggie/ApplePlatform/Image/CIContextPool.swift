//
//  CIContextPool.swift
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

#if canImport(CoreImage) && canImport(Metal)

private struct CIContextOptions : Hashable {
    
    var colorSpace: ColorSpace<RGBColorModel>?
    
    var outputPremultiplied: Bool
    
    var workingFormat: CIFormat
}

open class CIContextPool {
    
    public static let `default`: CIContextPool = CIContextPool()
    
    public let device: MTLDevice?
    public let commandQueue: MTLCommandQueue?
    
    private let lck = SDLock()
    private var table: [CIContextOptions: CIContext] = [:]
    
    public init() {
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device?.makeCommandQueue()
    }
    
    @available(macOS 10.11, iOS 9.0, tvOS 9.0, *)
    public init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public init(commandQueue: MTLCommandQueue) {
        self.device = commandQueue.device
        self.commandQueue = commandQueue
    }
}

extension CIContextPool {
    
    private func make_context(options: CIContextOptions) -> CIContext? {
        
        let _options: [CIContextOption : Any]
        
        if let colorSpace = options.colorSpace {
            
            guard let cgColorSpace = colorSpace.cgColorSpace else { return nil }
            
            _options = [
                .workingColorSpace: cgColorSpace,
                .outputColorSpace: cgColorSpace,
                .outputPremultiplied: options.outputPremultiplied,
                .workingFormat: options.workingFormat,
            ]
            
        } else {
            
            _options = [
                .workingColorSpace: CGColorSpaceCreateDeviceRGB(),
                .outputColorSpace: CGColorSpaceCreateDeviceRGB(),
                .outputPremultiplied: options.outputPremultiplied,
                .workingFormat: options.workingFormat,
            ]
        }
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *), let commandQueue = commandQueue {
            
            return CIContext(mtlCommandQueue: commandQueue, options: _options)
            
        } else if #available(macOS 10.11, iOS 9.0, tvOS 9.0, *), let device = device {
            
            return CIContext(mtlDevice: device, options: _options)
            
        } else {
            
            return CIContext(options: _options)
        }
    }
    
    open func request_context(colorSpace: ColorSpace<RGBColorModel>? = nil, outputPremultiplied: Bool = true, workingFormat: CIFormat = .RGBAh) -> CIContext? {
        
        lck.lock()
        defer { lck.unlock() }
        
        let options = CIContextOptions(
            colorSpace: colorSpace,
            outputPremultiplied: outputPremultiplied,
            workingFormat: workingFormat
        )
        
        if table[options] == nil {
            table[options] = make_context(options: options)
        }
        
        return table[options]
    }
}

extension CIContextPool {
    
    open func clearCaches() {
        
        lck.lock()
        defer { lck.unlock() }
        
        for context in table.values {
            context.clearCaches()
        }
    }
}

#endif
