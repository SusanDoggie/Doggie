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
    
    var edges = Image<ColorPixel<RGBColorModel>>(width: width + 2, height: height + 2, colorSpace: .default)
    
    guard width > 0 && height > 0 else { return edges }
    
    let horizontal = ImageConvolution(image, horizontal: [1, 0, -1], vertical: [0.25, 0.5, 0.25])
    let vertical = ImageConvolution(image, horizontal: [0.25, 0.5, 0.25], vertical: [1, 0, -1])
    
    horizontal.withUnsafeBufferPointer { horizontal in
        
        guard var horizontal = horizontal.baseAddress else { return }
        
        vertical.withUnsafeBufferPointer { vertical in
            
            guard var vertical = vertical.baseAddress else { return }
            
            edges.withUnsafeMutableBufferPointer { destination in
                
                guard var _destination = destination.baseAddress else { return }
                
                for _ in 0..<destination.count {
                    
                    let c0 = horizontal.pointee
                    let c1 = vertical.pointee
                    
                    let x_max = max(c0.opacity, c0.color.max())
                    let x_min = min(c0.opacity, c0.color.min())
                    let y_max = max(c1.opacity, c1.color.max())
                    let y_min = min(c1.opacity, c1.color.min())
                    
                    let x = x_min < 0 && -x_min > x_max ? x_min : x_max
                    let y = y_min < 0 && -y_min > y_max ? y_min : y_max
                    
                    let magnitude = sqrt(x * x + y * y)
                    let phase = atan2(y, x)
                    
                    _destination.pointee = ColorPixel(hue: phase * 0.5 / .pi, saturation: magnitude, brightness: magnitude * intensity)
                    
                    horizontal += 1
                    vertical += 1
                    _destination += 1
                }
            }
        }
    }
    
    return edges
}

@inlinable
public func Edges<Model>(_ image: Image<FloatColorPixel<Model>>, _ intensity: Float) -> Image<FloatColorPixel<RGBColorModel>> {
    
    let width = image.width
    let height = image.height
    
    let intensity = Double(intensity)
    
    var edges = Image<FloatColorPixel<RGBColorModel>>(width: width + 2, height: height + 2, colorSpace: .default)
    
    guard width > 0 && height > 0 else { return edges }
    
    let horizontal = ImageConvolution(image, horizontal: [1, 0, -1], vertical: [0.25, 0.5, 0.25])
    let vertical = ImageConvolution(image, horizontal: [0.25, 0.5, 0.25], vertical: [1, 0, -1])
    
    horizontal.withUnsafeBufferPointer { horizontal in
        
        guard var horizontal = horizontal.baseAddress else { return }
        
        vertical.withUnsafeBufferPointer { vertical in
            
            guard var vertical = vertical.baseAddress else { return }
            
            edges.withUnsafeMutableBufferPointer { destination in
                
                guard var _destination = destination.baseAddress else { return }
                
                for _ in 0..<destination.count {
                    
                    let c0 = horizontal.pointee
                    let c1 = vertical.pointee
                    
                    let x_max = max(c0.opacity, c0.color.max())
                    let x_min = min(c0.opacity, c0.color.min())
                    let y_max = max(c1.opacity, c1.color.max())
                    let y_min = min(c1.opacity, c1.color.min())
                    
                    let x = x_min < 0 && -x_min > x_max ? x_min : x_max
                    let y = y_min < 0 && -y_min > y_max ? y_min : y_max
                    
                    let magnitude = sqrt(x * x + y * y)
                    let phase = atan2(y, x)
                    
                    _destination.pointee = FloatColorPixel(hue: phase * 0.5 / .pi, saturation: magnitude, brightness: magnitude * intensity)
                    
                    horizontal += 1
                    vertical += 1
                    _destination += 1
                }
            }
        }
    }
    
    return edges
}
