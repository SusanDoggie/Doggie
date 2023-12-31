//
//  Resampling.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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

public enum ResamplingAlgorithm: Hashable {
    
    case none
    case linear
    case cosine
    case cubic
    case hermite(Double, Double)
    case mitchell(Double, Double)
    case lanczos(UInt)
}

extension ResamplingAlgorithm {
    
    @inlinable
    @inline(__always)
    public static var `default`: ResamplingAlgorithm {
        return .linear
    }
}

@usableFromInline
protocol _ResamplingImplement {
    
    associatedtype Pixel: ScalarMultiplicative where Pixel.Scalar: BinaryFloatingPoint & ElementaryFunctions
    
    var resamplingAlgorithm: ResamplingAlgorithm { get }
    
    func read_source(_ x: Int, _ y: Int) -> Pixel
}

extension _ResamplingImplement {
    
    @inlinable
    @inline(__always)
    public func pixel(_ point: Point) -> Pixel {
        
        switch resamplingAlgorithm {
        case .none: return read_source(Int(floor(point.x)), Int(floor(point.y)))
        case .linear: return sampling2(point: point, sampler: LinearInterpolate)
        case .cosine: return sampling2(point: point, sampler: CosineInterpolate)
        case .cubic: return sampling4(point: point, sampler: CubicInterpolate)
        case let .hermite(s, e):
            
            let s = Pixel.Scalar(s)
            let e = Pixel.Scalar(e)
            
            @inline(__always)
            func _kernel(_ t: Pixel.Scalar, _ a: Pixel, _ b: Pixel, _ c: Pixel, _ d: Pixel) -> Pixel {
                return HermiteInterpolate(t, a, b, c, d, s, e)
            }
            
            return sampling4(point: point, sampler: _kernel)
            
        case let .mitchell(B, C):
            
            let _a1 = 12 - 9 * B - 6 * C
            let _b1 = -18 + 12 * B + 6 * C
            let _c1 = 6 - 2 * B
            let _a2 = -B - 6 * C
            let _b2 = 6 * B + 30 * C
            let _c2 = -12 * B - 48 * C
            let _d2 = 8 * B + 24 * C
            
            let a1 = Pixel.Scalar(_a1)
            let b1 = Pixel.Scalar(_b1)
            let c1 = Pixel.Scalar(_c1)
            let a2 = Pixel.Scalar(_a2)
            let b2 = Pixel.Scalar(_b2)
            let c2 = Pixel.Scalar(_c2)
            let d2 = Pixel.Scalar(_d2)
            
            @inline(__always)
            func _kernel(_ x: Pixel.Scalar) -> Pixel.Scalar {
                if x < 1 {
                    let u = a1 * x + b1
                    return u * x * x + c1
                }
                if x < 2 {
                    let u = a2 * x + b2
                    let v = u * x + c2
                    return v * x + d2
                }
                return 0
            }
            
            return convolve(point: point, kernel_size: 5, kernel: _kernel)
            
        case .lanczos(0): return read_source(Int(floor(point.x)), Int(floor(point.y)))
        case .lanczos(1):
            
            @inline(__always)
            func _kernel(_ x: Pixel.Scalar) -> Pixel.Scalar {
                if x == 0 {
                    return 1
                }
                if x < 1 {
                    let _x = .pi * x
                    let _sinc = .sin(_x) / _x
                    return _sinc * _sinc
                }
                return 0
            }
            
            return convolve(point: point, kernel_size: 2, kernel: _kernel)
            
        case let .lanczos(a):
            
            let a = Pixel.Scalar(a)
            
            @inline(__always)
            func _kernel(_ x: Pixel.Scalar) -> Pixel.Scalar {
                if x == 0 {
                    return 1
                }
                if x < a {
                    let _x = .pi * x
                    let _ax = _x / a
                    let u = Pixel.Scalar.sin(_x) * Pixel.Scalar.sin(_ax)
                    let v = _x * _x
                    return a * u / v
                }
                return 0
            }
            
            return convolve(point: point, kernel_size: Int(a) << 1, kernel: _kernel)
        }
    }
}

extension _ResamplingImplement {
    
    @inlinable
    @inline(__always)
    func convolve(point: Point, kernel_size: Int, kernel: (Pixel.Scalar) -> Pixel.Scalar) -> Pixel {
        
        var pixel = Pixel.zero
        var t: Pixel.Scalar = 0
        
        let _x = Int(floor(point.x))
        let _y = Int(floor(point.y))
        
        let a = kernel_size >> 1
        let b = 1 - kernel_size & 1
        let min_x = _x - a + b
        let max_x = min_x + kernel_size
        let min_y = _y - a + b
        let max_y = min_y + kernel_size
        
        for y in min_y..<max_y {
            for x in min_x..<max_x {
                let k = kernel(Pixel.Scalar(point.distance(to: Point(x: x, y: y))))
                pixel += read_source(x, y) * k
                t += k
            }
        }
        return t == 0 ? .zero : pixel / t
    }
    
    @inlinable
    @inline(__always)
    func sampling2(point: Point, sampler: (Pixel.Scalar, Pixel, Pixel) -> Pixel) -> Pixel {
        
        let _i = floor(point.x)
        let _j = floor(point.y)
        let _tx = Pixel.Scalar(point.x - _i)
        let _ty = Pixel.Scalar(point.y - _j)
        
        let _x1 = Int(_i)
        let _y1 = Int(_j)
        let _x2 = _x1 + 1
        let _y2 = _y1 + 1
        
        let _s1 = read_source(_x1, _y1)
        let _s2 = read_source(_x2, _y1)
        let _s3 = read_source(_x1, _y2)
        let _s4 = read_source(_x2, _y2)
        
        return sampler(_ty, sampler(_tx, _s1, _s2), sampler(_tx, _s3, _s4))
    }
    
    @inlinable
    @inline(__always)
    func sampling4(point: Point, sampler: (Pixel.Scalar, Pixel, Pixel, Pixel, Pixel) -> Pixel) -> Pixel {
        
        let _i = floor(point.x)
        let _j = floor(point.y)
        let _tx = Pixel.Scalar(point.x - _i)
        let _ty = Pixel.Scalar(point.y - _j)
        
        let _x2 = Int(_i)
        let _y2 = Int(_j)
        let _x3 = _x2 + 1
        let _y3 = _y2 + 1
        let _x1 = _x2 - 1
        let _y1 = _y2 - 1
        let _x4 = _x2 + 2
        let _y4 = _y2 + 2
        
        let _s1 = read_source(_x1, _y1)
        let _s2 = read_source(_x2, _y1)
        let _s3 = read_source(_x3, _y1)
        let _s4 = read_source(_x4, _y1)
        let _s5 = read_source(_x1, _y2)
        let _s6 = read_source(_x2, _y2)
        let _s7 = read_source(_x3, _y2)
        let _s8 = read_source(_x4, _y2)
        let _s9 = read_source(_x1, _y3)
        let _s10 = read_source(_x2, _y3)
        let _s11 = read_source(_x3, _y3)
        let _s12 = read_source(_x4, _y3)
        let _s13 = read_source(_x1, _y4)
        let _s14 = read_source(_x2, _y4)
        let _s15 = read_source(_x3, _y4)
        let _s16 = read_source(_x4, _y4)
        
        let _u1 = sampler(_tx, _s1, _s2, _s3, _s4)
        let _u2 = sampler(_tx, _s5, _s6, _s7, _s8)
        let _u3 = sampler(_tx, _s9, _s10, _s11, _s12)
        let _u4 = sampler(_tx, _s13, _s14, _s15, _s16)
        
        return sampler(_ty, _u1, _u2, _u3, _u4)
    }
}
