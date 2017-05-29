//
//  DrawGradient.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

import Foundation

public enum GradientSpreadMode {
    
    case none
    case pad
    case reflect
    case `repeat`
}

public struct GradientStop<Model : ColorModelProtocol> {
    
    public var offset: Double
    public var color: Color<Model>
    
    @_inlineable
    public init(offset: Double, color: Color<Model>) {
        self.offset = offset
        self.color = color
    }
}

extension ImageContext {
    
    @_versioned
    @_inlineable
    func _shading(_ shader: (Point) throws -> ColorPixel<Model>) rethrows {
        
        if let next = self.next {
            try next._shading(shader)
            return
        }
        
        if _image.width == 0 || _image.height == 0 || _transform.determinant.almostZero() {
            return
        }
        
        let transform = self._transform.inverse
        
        try _image.withUnsafeMutableBufferPointer { _image in
            
            if var _destination = _image.baseAddress {
                
                try clip.withUnsafeBufferPointer { _clip in
                    
                    if var _clip = _clip.baseAddress {
                        
                        var _p = Point(x: 0, y: 0)
                        let _p1 = Point(x: 1, y: 0) * transform
                        let _p2 = Point(x: 0, y: 1) * transform
                        
                        for _ in 0..<height {
                            var p = _p
                            for _ in 0..<width {
                                
                                let _alpha = _clip.pointee
                                
                                if _alpha > 0 {
                                    
                                    var pixel = try shader(p)
                                    pixel.opacity *= _alpha
                                    
                                    if pixel.opacity > 0 {
                                        _destination.pointee.blend(source: pixel, blendMode: _blendMode, compositingMode: _compositingMode)
                                    }
                                }
                                
                                _destination += 1
                                _clip += 1
                                p += _p1
                            }
                            _p += _p2
                        }
                    }
                }
            }
        }
        
    }
}

extension ImageContext {
    
    @_inlineable
    public func axialShading(start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, shading: (Double) throws -> ColorPixel<Model>) rethrows {
        
        if start.almostEqual(end) {
            return
        }
        
        let startColor = try shading(0)
        let endColor = try shading(1)
        
        try self._shading { point in
            
            let a = start - point
            let b = end - start
            let u = b.x * a.x + b.y * a.y
            let v = b.x * b.x + b.y * b.y
            
            let t = -u / v
            
            if 0...1 ~= t {
                
                return try shading(t)
                
            } else if t > 1 {
                
                switch endSpread {
                case .none: return endColor.with(opacity: 0)
                case .pad: return endColor
                case .reflect:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return try shading(Int(_t) & 1 == 0 ? s : 1 - s)
                case .repeat:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return try shading(s)
                }
                
            } else {
                
                switch startSpread {
                case .none: return startColor.with(opacity: 0)
                case .pad: return startColor
                case .reflect:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return try shading(Int(_t) & 1 == 0 ? -s : 1 + s)
                case .repeat:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return try shading(1 + s)
                }
            }
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func radialShading(start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, shading: (Double) throws -> ColorPixel<Model>) rethrows {
        
        if start.almostEqual(end) && startRadius.almostEqual(endRadius) {
            return
        }
        
        let startColor = try shading(0)
        let endColor = try shading(1)
        
        try self._shading { point in
            
            let p0 = point - start
            let p1 = start - end
            let r0 = startRadius
            let r1 = endRadius - startRadius
            
            let a = p1.x * p1.x + p1.y * p1.y - r1 * r1
            let b = 2 * (p0.x * p1.x + p0.y * p1.y - r0 * r1)
            let c = p0.x * p0.x + p0.y * p0.y - r0 * r0
            
            let t: [Double]
            
            if a.almostZero() {
                if b.almostZero() {
                    t = []
                } else {
                    t = [-c / b]
                }
            } else {
                t = degree2roots(b / a, c / a)
            }
            
            func _filter(_ t: Double) -> Bool {
                return r0 + t * r1 >= 0 && (t >= 0 || startSpread != .none) && (t <= 1 || endSpread != .none)
            }
            
            if let t = t.filter(_filter).max() {
                
                if 0...1 ~= t {
                    
                    return try shading(t)
                    
                } else if t > 1 {
                    
                    switch endSpread {
                    case .none: return endColor.with(opacity: 0)
                    case .pad: return endColor
                    case .reflect:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return try shading(Int(_t) & 1 == 0 ? s : 1 - s)
                    case .repeat:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return try shading(s)
                    }
                    
                } else {
                    
                    switch startSpread {
                    case .none: return startColor.with(opacity: 0)
                    case .pad: return startColor
                    case .reflect:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return try shading(Int(_t) & 1 == 0 ? -s : 1 + s)
                    case .repeat:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return try shading(1 + s)
                    }
                }
            }
            
            return ColorPixel()
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        let stops = stops.sorted { $0.offset }.map { ($0.offset, ColorPixel($0.color.convert(to: colorSpace))) }
        
        switch stops.count {
        case 0: break
        case 1: axialShading(start: start, end: end, startSpread: startSpread, endSpread: endSpread) { _ in stops[0].1 }
        default:
            axialShading(start: start, end: end, startSpread: startSpread, endSpread: endSpread) { t in
                
                if t <= stops[0].0 {
                    return stops[0].1
                }
                if t >= stops.last!.0 {
                    return stops.last!.1
                }
                
                for (lhs, rhs) in zip(stops, stops.dropFirst()) where lhs.0 != rhs.0 && t >= lhs.0 && t <= rhs.0 {
                    
                    let s = (t - lhs.0) / (rhs.0 - lhs.0)
                    return lhs.1 * (1 - s) + rhs.1 * s
                }
                
                return stops[0].1
            }
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        let stops = stops.sorted { $0.offset }.map { ($0.offset, ColorPixel($0.color.convert(to: colorSpace))) }
        
        switch stops.count {
        case 0: break
        case 1: radialShading(start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread) { _ in stops[0].1 }
        default:
            radialShading(start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread) { t in
                
                if t <= stops[0].0 {
                    return stops[0].1
                }
                if t >= stops.last!.0 {
                    return stops.last!.1
                }
                
                for (lhs, rhs) in zip(stops, stops.dropFirst()) where lhs.0 != rhs.0 && t >= lhs.0 && t <= rhs.0 {
                    
                    let s = (t - lhs.0) / (rhs.0 - lhs.0)
                    return lhs.1 * (1 - s) + rhs.1 * s
                }
                
                return stops[0].1
            }
        }
    }
}

extension ImageContext {
    
    @_versioned
    @_inlineable
    func _drawGradient(_ destination: UnsafeMutablePointer<ColorPixel<Model>>, _ clip: UnsafePointer<Double>, _ patch: CubicBezierPatch, _ c0: ColorPixel<Model>, _ c1: ColorPixel<Model>, _ c2: ColorPixel<Model>, _ c3: ColorPixel<Model>) {
        
        let (m0, n0) = Bezier(patch.m00, patch.m01, patch.m02, patch.m03).split(0.5)
        let (m1, n1) = Bezier(patch.m10, patch.m11, patch.m12, patch.m13).split(0.5)
        let (m2, n2) = Bezier(patch.m20, patch.m21, patch.m22, patch.m23).split(0.5)
        let (m3, n3) = Bezier(patch.m30, patch.m31, patch.m32, patch.m33).split(0.5)
        
        let (s0, t0) = Bezier(m0[0], m1[0], m2[0], m3[0]).split(0.5)
        let (s1, t1) = Bezier(m0[1], m1[1], m2[1], m3[1]).split(0.5)
        let (s2, t2) = Bezier(m0[2], m1[2], m2[2], m3[2]).split(0.5)
        let (s3, t3) = Bezier(m0[3], m1[3], m2[3], m3[3]).split(0.5)
        
        let (u0, v0) = Bezier(n0[0], n1[0], n2[0], n3[0]).split(0.5)
        let (u1, v1) = Bezier(n0[1], n1[1], n2[1], n3[1]).split(0.5)
        let (u2, v2) = Bezier(n0[2], n1[2], n2[2], n3[2]).split(0.5)
        let (u3, v3) = Bezier(n0[3], n1[3], n2[3], n3[3]).split(0.5)
        
        let p0 = CubicBezierPatch(s0[0], s1[0], s2[0], s3[0],
                                  s0[1], s1[1], s2[1], s3[1],
                                  s0[2], s1[2], s2[2], s3[2],
                                  s0[3], s1[3], s2[3], s3[3])
        
        let p1 = CubicBezierPatch(t0[0], t1[0], t2[0], t3[0],
                                  t0[1], t1[1], t2[1], t3[1],
                                  t0[2], t1[2], t2[2], t3[2],
                                  t0[3], t1[3], t2[3], t3[3])
        
        let p2 = CubicBezierPatch(u0[0], u1[0], u2[0], u3[0],
                                  u0[1], u1[1], u2[1], u3[1],
                                  u0[2], u1[2], u2[2], u3[2],
                                  u0[3], u1[3], u2[3], u3[3])
        
        let p3 = CubicBezierPatch(v0[0], v1[0], v2[0], v3[0],
                                  v0[1], v1[1], v2[1], v3[1],
                                  v0[2], v1[2], v2[2], v3[2],
                                  v0[3], v1[3], v2[3], v3[3])
        
        let c4 = 0.5 * (c0 + c1)
        let c5 = 0.5 * (c0 + c2)
        let c6 = 0.5 * (c1 + c3)
        let c7 = 0.5 * (c2 + c3)
        let c8 = 0.25 * (c0 + c1 + c2 + c3)
        
        @inline(__always)
        func _draw(_ patch: CubicBezierPatch, _ c0: ColorPixel<Model>, _ c1: ColorPixel<Model>, _ c2: ColorPixel<Model>, _ c3: ColorPixel<Model>) {
            
            let d0 = patch.m00 - patch.m03
            let d1 = patch.m30 - patch.m33
            let d2 = patch.m00 - patch.m30
            let d3 = patch.m03 - patch.m33
            
            if abs(d0.x) < 1 && abs(d0.y) < 1 && abs(d1.x) < 1 && abs(d1.y) < 1 && abs(d2.x) < 1 && abs(d2.y) < 1 && abs(d3.x) < 1 && abs(d3.y) < 1 {
                
                let width = self.width
                let height = self.height
                
                let q0 = Bezier(patch.m00, patch.m01, patch.m02, patch.m03).eval(0.5)
                let q1 = Bezier(patch.m10, patch.m11, patch.m12, patch.m13).eval(0.5)
                let q2 = Bezier(patch.m20, patch.m21, patch.m22, patch.m23).eval(0.5)
                let q3 = Bezier(patch.m30, patch.m31, patch.m32, patch.m33).eval(0.5)
                
                let _q = Bezier(q0, q1, q2, q3).eval(0.5)
                
                let _x = Int(_q.x)
                let _y = Int(_q.y)
                
                if 0..<width ~= _x && 0..<height ~= _y {
                    
                    let index = _y * width + _x
                    
                    let _alpha = clip[index]
                    
                    if _alpha > 0 {
                        
                        var pixel = c8
                        pixel.opacity *= _alpha
                        
                        if pixel.opacity > 0 {
                            destination[index].blend(source: pixel, blendMode: _blendMode, compositingMode: _compositingMode)
                        }
                    }
                }
                
            } else {
                _drawGradient(destination, clip, patch, c0, c1, c2, c3)
            }
        }
        
        _draw(p0, c0, c4, c5, c8)
        _draw(p1, c5, c8, c2, c7)
        _draw(p2, c4, c1, c8, c6)
        _draw(p3, c8, c6, c7, c3)
        
    }
    
    @_inlineable
    public func drawGradient<C>(_ patch: CubicBezierPatch, color c0: Color<C>, _ c1: Color<C>, _ c2: Color<C>, _ c3: Color<C>) {
        
        if let next = self.next {
            next.drawGradient(patch, color: c0, c1, c2, c3)
            return
        }
        
        let width = self.width
        let height = self.height
        let transform = self._transform
        
        if width == 0 || height == 0 || transform.determinant.almostZero() {
            return
        }
        
        _image.withUnsafeMutableBufferPointer { _image in
            
            if let _destination = _image.baseAddress {
                
                clip.withUnsafeBufferPointer { _clip in
                    
                    if let _clip = _clip.baseAddress {
                        
                        _drawGradient(_destination, _clip,
                                      CubicBezierPatch(patch.m00 * transform, patch.m01 * transform, patch.m02 * transform, patch.m03 * transform,
                                                       patch.m10 * transform, patch.m11 * transform, patch.m12 * transform, patch.m13 * transform,
                                                       patch.m20 * transform, patch.m21 * transform, patch.m22 * transform, patch.m23 * transform,
                                                       patch.m30 * transform, patch.m31 * transform, patch.m32 * transform, patch.m33 * transform),
                                      ColorPixel(c0.convert(to: colorSpace)),
                                      ColorPixel(c1.convert(to: colorSpace)),
                                      ColorPixel(c2.convert(to: colorSpace)),
                                      ColorPixel(c3.convert(to: colorSpace)))
                    }
                }
            }
        }
        
    }
}
