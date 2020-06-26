//
//  CGShading.swift
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

#if canImport(CoreGraphics)

public func CGFunctionCreate(
    version: UInt32,
    domainDimension: Int,
    domain: UnsafePointer<CGFloat>?,
    rangeDimension: Int,
    range: UnsafePointer<CGFloat>?,
    callbacks: @escaping (UnsafePointer<CGFloat>, UnsafeMutablePointer<CGFloat>) -> Void
) -> CGFunction? {
    
    typealias CGFunctionCallback = (UnsafePointer<CGFloat>, UnsafeMutablePointer<CGFloat>) -> Void
    
    let info = UnsafeMutablePointer<CGFunctionCallback>.allocate(capacity: 1)
    info.initialize(to: callbacks)
    
    let callback = CGFunctionCallbacks(version: version, evaluate: { (info, inputs, ouputs) in
        
        guard let callbacks = info?.assumingMemoryBound(to: CGFunctionCallback.self).pointee else { return }
        
        callbacks(inputs, ouputs)
        
    }, releaseInfo: { info in
        
        guard let info = info?.assumingMemoryBound(to: CGFunctionCallback.self) else { return }
        info.deinitialize(count: 1)
        info.deallocate()
    })
    
    return CGFunction(info: info, domainDimension: domainDimension, domain: domain, rangeDimension: rangeDimension, range: range, callbacks: [callback])
}

public func CGShadingCreate(axialSpace space: CGColorSpace, start: CGPoint, end: CGPoint, extendStart: Bool, extendEnd: Bool, callbacks: @escaping (UnsafePointer<CGFloat>, UnsafeMutablePointer<CGFloat>) -> Void) -> CGShading? {
    
    guard let function = CGFunctionCreate(version: 0, domainDimension: 1, domain: [0, 1], rangeDimension: space.numberOfComponents + 1, range: nil, callbacks: callbacks) else { return nil }
    
    return CGShading(axialSpace: space, start: start, end: end, function: function, extendStart: extendStart, extendEnd: extendEnd)
}

public func CGShadingCreate(radialSpace space: CGColorSpace, start: CGPoint, startRadius: CGFloat, end: CGPoint, endRadius: CGFloat, extendStart: Bool, extendEnd: Bool, callbacks: @escaping (UnsafePointer<CGFloat>, UnsafeMutablePointer<CGFloat>) -> Void) -> CGShading? {
    
    guard let function = CGFunctionCreate(version: 0, domainDimension: 1, domain: [0, 1], rangeDimension: space.numberOfComponents + 1, range: nil, callbacks: callbacks) else { return nil }
    
    return CGShading(radialSpace: space, start: start, startRadius: startRadius, end: end, endRadius: endRadius, function: function, extendStart: extendStart, extendEnd: extendEnd)
}

#endif

