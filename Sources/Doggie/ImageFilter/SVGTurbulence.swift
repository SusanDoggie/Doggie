//
//  SVGTurbulence.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

public enum SVGTurbulenceType : CaseIterable {
    
    case fractalNoise
    case turbulence
}

@inlinable
@inline(__always)
public func SVGTurbulence<T>(_ width: Int, _ height: Int, _ type: SVGTurbulenceType, _ stitchTile: Rect?, _ transform: SDTransform, _ seed: Int, _ baseFrequency: Double, _ numOctaves: Int, _ fileBacked: Bool = false) -> Image<T> where T.Model == RGBColorModel {
    return Image(texture: SVGTurbulence(width, height, type, stitchTile, transform, seed, baseFrequency, numOctaves, fileBacked), colorSpace: ColorSpace<RGBColorModel>.sRGB.linearTone)
}

@inlinable
@inline(__always)
public func SVGTurbulence<T>(_ width: Int, _ height: Int, _ type: SVGTurbulenceType, _ stitchTile: Rect?, _ transform: SDTransform, _ seed: Int, _ baseFrequency: Double, _ numOctaves: Int, _ fileBacked: Bool = false) -> Texture<T> where T.Model == RGBColorModel {
    
    var result = Texture<T>(width: width, height: height, fileBacked: fileBacked)
    
    result.withUnsafeMutableBufferPointer {
        
        guard var ptr = $0.baseAddress else { return }
        
        let noise = SVGNoise(seed)
        
        switch type {
        case .fractalNoise:
            
            for y in 0..<height {
                for x in 0..<width {
                    
                    let point = Point(x: x, y: y) * transform
                    
                    let red = noise.turbulence(0, point, baseFrequency, baseFrequency, numOctaves, true, stitchTile) * 0.5 + 0.5
                    let green = noise.turbulence(1, point, baseFrequency, baseFrequency, numOctaves, true, stitchTile) * 0.5 + 0.5
                    let blue = noise.turbulence(2, point, baseFrequency, baseFrequency, numOctaves, true, stitchTile) * 0.5 + 0.5
                    let opacity = noise.turbulence(3, point, baseFrequency, baseFrequency, numOctaves, true, stitchTile) * 0.5 + 0.5
                    
                    ptr.pointee = T(red: red, green: green, blue: blue, opacity: opacity)
                    
                    ptr += 1
                }
            }
            
        case .turbulence:
            
            for y in 0..<height {
                for x in 0..<width {
                    
                    let point = Point(x: x, y: y) * transform
                    
                    let red = noise.turbulence(0, point, baseFrequency, baseFrequency, numOctaves, false, stitchTile)
                    let green = noise.turbulence(1, point, baseFrequency, baseFrequency, numOctaves, false, stitchTile)
                    let blue = noise.turbulence(2, point, baseFrequency, baseFrequency, numOctaves, false, stitchTile)
                    let opacity = noise.turbulence(3, point, baseFrequency, baseFrequency, numOctaves, false, stitchTile)
                    
                    ptr.pointee = T(red: red, green: green, blue: blue, opacity: opacity)
                    
                    ptr += 1
                }
            }
        }
    }
    
    return result
}
