//
//  DisplacementMap.swift
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

@inlinable
@inline(__always)
public func DisplacementMap<S, T>(_ source: Image<S>, _ displacement: Image<T>, _ xChannelSelector: Int, _ yChannelSelector: Int, _ scale: Double) -> Image<S> {
    return Image(texture: DisplacementMap(Texture(image: source), Texture(image: displacement), xChannelSelector, yChannelSelector, scale), resolution: displacement.resolution, colorSpace: source.colorSpace)
}

@inlinable
@inline(__always)
public func DisplacementMap<S, T>(_ texture: Texture<S>, _ displacement: Texture<T>, _ xChannelSelector: Int, _ yChannelSelector: Int, _ scale: Double) -> Texture<S> {
    
    let width = displacement.width
    let height = displacement.height
    let resamplingAlgorithm = texture.resamplingAlgorithm
    let option = texture.option
    
    var result = Texture<S>(width: width, height: height, resamplingAlgorithm: resamplingAlgorithm, option: option)
    
    result.withUnsafeMutableBufferPointer {
        
        guard var result = $0.baseAddress else { return }
        
        displacement.withUnsafeBufferPointer {
            
            guard var displacement = $0.baseAddress else { return }
            
            for y in 0..<height {
                for x in 0..<width {
                    
                    let d = displacement.pointee
                    
                    let _x = Double(x) + scale * (d.component(xChannelSelector) - 0.5)
                    let _y = Double(y) + scale * (d.component(yChannelSelector) - 0.5)
                    
                    result.pointee = S(texture.pixel(Point(x: _x, y: _y)))
                    
                    displacement += 1
                    result += 1
                }
            }
        }
    }
    
    return result
}
