//
//  CGPattern.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

public func CGPatternCreate(
    version: UInt32,
    bounds: CGRect,
    matrix: CGAffineTransform,
    xStep: CGFloat,
    yStep: CGFloat,
    tiling: CGPatternTiling,
    isColored: Bool,
    callbacks: @escaping (CGContext) -> Void
) -> CGPattern? {
    
    typealias CGPatternCallback = (CGContext) -> Void
    
    let info = UnsafeMutablePointer<CGPatternCallback>.allocate(capacity: 1)
    info.initialize(to: callbacks)
    
    let callback = CGPatternCallbacks(version: version, drawPattern: { (info, context) in
        
        guard let callbacks = info?.assumingMemoryBound(to: CGPatternCallback.self).pointee else { return }
        
        callbacks(context)
        
    }, releaseInfo: { info in
        
        guard let info = info?.assumingMemoryBound(to: CGPatternCallback.self) else { return }
        info.deinitialize(count: 1)
        info.deallocate()
    })
    
    return CGPattern(info: info, bounds: bounds, matrix: matrix, xStep: xStep, yStep: yStep, tiling: tiling, isColored: isColored, callbacks: [callback])
}

#endif
