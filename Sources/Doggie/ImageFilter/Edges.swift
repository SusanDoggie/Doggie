//
//  Edges.swift
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
public func Edges<Model>(_ image: Image<ColorPixel<Model>>, _ intensity: Double) -> Image<ColorPixel<RGBColorModel>> {
    
    let width = image.width
    let height = image.height
    
    let _intensity = 1 / intensity
    
    var result = Image<ColorPixel<RGBColorModel>>(width: width, height: height, colorSpace: .default)
    
    guard width > 0 && height > 0 else { return result }
    
    image.withUnsafeBufferPointer { source in
        
        guard var source = source.baseAddress else { return }
        
        result.withUnsafeMutableBufferPointer { destination in
            
            guard var destination = destination.baseAddress else { return }
            
            let r0 = 0..<width
            let r1 = 0..<height
            
            for j in r1 {
                
                var _source = source
                
                for i in r0 {
                    
                    let s01 = r1 ~= j - 1 ? _source - width : _source
                    let s21 = r1 ~= j + 1 ? _source + width : _source
                    let s10 = r0 ~= i - 1 ? _source - 1 : _source
                    let s12 = r0 ~= i + 1 ? _source + 1 : _source
                    let s00 = r0 ~= i - 1 ? s01 - 1 : s01
                    let s02 = r0 ~= i + 1 ? s01 + 1 : s01
                    let s20 = r0 ~= i - 1 ? s21 - 1 : s21
                    let s22 = r0 ~= i + 1 ? s21 + 1 : s21
                    
                    let h0 = s02.pointee - s00.pointee
                    let h1 = s12.pointee - s10.pointee
                    let h2 = s22.pointee - s20.pointee
                    
                    let v0 = s20.pointee - s00.pointee
                    let v1 = s21.pointee - s01.pointee
                    let v2 = s22.pointee - s02.pointee
                    
                    var c0 = 0.25 * (h0 + h2)
                    c0 += 0.5 * h1
                    
                    var c1 = 0.25 * (v0 + v2)
                    c1 += 0.5 * v1
                    
                    let x_max = max(c0.opacity, c0.color.max())
                    let x_min = min(c0.opacity, c0.color.min())
                    let y_max = max(c1.opacity, c1.color.max())
                    let y_min = min(c1.opacity, c1.color.min())
                    
                    let x = x_min < 0 && -x_min > x_max ? x_min : x_max
                    let y = y_min < 0 && -y_min > y_max ? y_min : y_max
                    
                    let magnitude = sqrt(x * x + y * y)
                    let phase = atan2(y, x)
                    
                    destination.pointee = ColorPixel(hue: phase * 0.5 / .pi, saturation: 1, brightness: pow(magnitude, _intensity))
                    
                    destination += 1
                    _source += 1
                }
                
                source += width
            }
        }
    }
    
    return result
}

@inlinable
public func Edges<Model>(_ image: Image<FloatColorPixel<Model>>, _ intensity: Float) -> Image<FloatColorPixel<RGBColorModel>> {
    
    let width = image.width
    let height = image.height
    
    let _intensity = Double(1 / intensity)
    
    var result = Image<FloatColorPixel<RGBColorModel>>(width: width, height: height, colorSpace: .default)
    
    guard width > 0 && height > 0 else { return result }
    
    image.withUnsafeBufferPointer { source in
        
        guard var source = source.baseAddress else { return }
        
        result.withUnsafeMutableBufferPointer { destination in
            
            guard var destination = destination.baseAddress else { return }
            
            let r0 = 0..<width
            let r1 = 0..<height
            
            for j in r1 {
                
                var _source = source
                
                for i in r0 {
                    
                    let s01 = r1 ~= j - 1 ? _source - width : _source
                    let s21 = r1 ~= j + 1 ? _source + width : _source
                    let s10 = r0 ~= i - 1 ? _source - 1 : _source
                    let s12 = r0 ~= i + 1 ? _source + 1 : _source
                    let s00 = r0 ~= i - 1 ? s01 - 1 : s01
                    let s02 = r0 ~= i + 1 ? s01 + 1 : s01
                    let s20 = r0 ~= i - 1 ? s21 - 1 : s21
                    let s22 = r0 ~= i + 1 ? s21 + 1 : s21
                    
                    let h0 = s02.pointee - s00.pointee
                    let h1 = s12.pointee - s10.pointee
                    let h2 = s22.pointee - s20.pointee
                    
                    let v0 = s20.pointee - s00.pointee
                    let v1 = s21.pointee - s01.pointee
                    let v2 = s22.pointee - s02.pointee
                    
                    var c0 = 0.25 * (h0 + h2)
                    c0 += 0.5 * h1
                    
                    var c1 = 0.25 * (v0 + v2)
                    c1 += 0.5 * v1
                    
                    let x_max = max(c0.opacity, c0.color.max())
                    let x_min = min(c0.opacity, c0.color.min())
                    let y_max = max(c1.opacity, c1.color.max())
                    let y_min = min(c1.opacity, c1.color.min())
                    
                    let x = x_min < 0 && -x_min > x_max ? x_min : x_max
                    let y = y_min < 0 && -y_min > y_max ? y_min : y_max
                    
                    let magnitude = sqrt(x * x + y * y)
                    let phase = atan2(y, x)
                    
                    destination.pointee = FloatColorPixel(hue: phase * 0.5 / .pi, saturation: 1, brightness: pow(magnitude, _intensity))
                    
                    destination += 1
                    _source += 1
                }
                
                source += width
            }
        }
    }
    
    return result
}
