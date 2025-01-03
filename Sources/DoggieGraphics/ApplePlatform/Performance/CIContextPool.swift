//
//  CIContextPool.swift
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

#if canImport(CoreImage) && canImport(Metal)

private struct CIContextOptions: Hashable {
    
    var colorSpace: ColorSpace<RGBColorModel>?
    
    var outputPremultiplied: Bool
    
    var workingFormat: CIFormat
}

public class CIContextPool {
    
    public static let `default`: CIContextPool = CIContextPool()
    
    public let commandQueue: MTLCommandQueue?
    
    private let lck = NSLock()
    private var table: [CIContextOptions: CIContext] = [:]
    
    public init() {
        self.commandQueue = MTLCreateSystemDefaultDevice()?.makeCommandQueue()
    }
    
    public init(device: MTLDevice) {
        self.commandQueue = device.makeCommandQueue()
    }
    
    public init(commandQueue: MTLCommandQueue) {
        self.commandQueue = commandQueue
    }
}

extension CIContextPool {
    
    private func make_context(options: CIContextOptions) -> CIContext? {
        
        let _options: [CIContextOption: Any]
        
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
            
        } else if let device = commandQueue?.device {
            
            return CIContext(mtlDevice: device, options: _options)
            
        } else {
            
            return CIContext(options: _options)
        }
    }
    
    public func makeContext(colorSpace: ColorSpace<RGBColorModel>? = nil, outputPremultiplied: Bool = true, workingFormat: CIFormat = .BGRA8) -> CIContext? {
        
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
    
    public func clearCaches() {
        
        lck.lock()
        defer { lck.unlock() }
        
        for context in table.values {
            context.clearCaches()
        }
    }
}

#endif
